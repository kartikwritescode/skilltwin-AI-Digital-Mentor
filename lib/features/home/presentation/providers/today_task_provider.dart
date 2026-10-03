import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/home_dashboard.dart';
import '../../../../core/storage/storage_provider.dart';
import 'home_provider.dart';

enum TodayTaskStatus {
  notStarted,
  learning,
  completed;

  static TodayTaskStatus fromString(String? val) {
    switch (val?.toUpperCase()) {
      case 'COMPLETED':
        return TodayTaskStatus.completed;
      case 'LEARNING':
        return TodayTaskStatus.learning;
      case 'NOT_STARTED':
      default:
        return TodayTaskStatus.notStarted;
    }
  }

  String toDisplayString() {
    switch (this) {
      case TodayTaskStatus.completed:
        return 'COMPLETED';
      case TodayTaskStatus.learning:
        return 'LEARNING';
      case TodayTaskStatus.notStarted:
        return 'NOT_STARTED';
    }
  }
}

class TodayTaskState {
  final TodayTaskStatus status;
  final String? topicId;
  final String? topicTitle;
  final int? estimatedMinutes;
  final DateTime? completedAt;
  final String dateKey; // YYYY-MM-DD
  final bool isSubmitting;
  final String? error;
  final List<String> completedTopicIds;
  final List<DailyTaskItem> tasks;
  final int currentTaskIndex;
  final int totalTasks;

  const TodayTaskState({
    this.status = TodayTaskStatus.notStarted,
    this.topicId,
    this.topicTitle,
    this.estimatedMinutes,
    this.completedAt,
    required this.dateKey,
    this.isSubmitting = false,
    this.error,
    this.completedTopicIds = const [],
    this.tasks = const [],
    this.currentTaskIndex = 0,
    this.totalTasks = 1,
  });

  bool get isCompleted => status == TodayTaskStatus.completed;
  bool get isLearning => status == TodayTaskStatus.learning;
  bool get isNotStarted => status == TodayTaskStatus.notStarted;
  int get completedCount => completedTopicIds.length;
  int get remainingCount => (totalTasks - completedCount).clamp(0, totalTasks);

  TodayTaskState copyWith({
    TodayTaskStatus? status,
    String? topicId,
    String? topicTitle,
    int? estimatedMinutes,
    DateTime? completedAt,
    String? dateKey,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
    List<String>? completedTopicIds,
    List<DailyTaskItem>? tasks,
    int? currentTaskIndex,
    int? totalTasks,
  }) {
    return TodayTaskState(
      status: status ?? this.status,
      topicId: topicId ?? this.topicId,
      topicTitle: topicTitle ?? this.topicTitle,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      completedAt: completedAt ?? this.completedAt,
      dateKey: dateKey ?? this.dateKey,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
      completedTopicIds: completedTopicIds ?? this.completedTopicIds,
      tasks: tasks ?? this.tasks,
      currentTaskIndex: currentTaskIndex ?? this.currentTaskIndex,
      totalTasks: totalTasks ?? this.totalTasks,
    );
  }
}

class TodayTaskStateNotifier extends StateNotifier<TodayTaskState> {
  final Ref _ref;

  TodayTaskStateNotifier(this._ref)
      : super(TodayTaskState(
          dateKey: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        )) {
    _initFromStorage();
  }

  static String _formatDate(DateTime dt) =>
      DateFormat('yyyy-MM-dd').format(dt);

  void _initFromStorage() {
    try {
      final prefs = _ref.read(sharedPrefsProvider);
      final todayKey = _formatDate(DateTime.now());
      final isAllCompleted =
          prefs.getBool('skilltwin_today_completed_$todayKey') ?? false;
      final completedList =
          prefs.getStringList('skilltwin_today_completed_topics_$todayKey') ?? [];
      final topicId = prefs.getString('skilltwin_today_topic_id_$todayKey');
      final topicTitle = prefs.getString('skilltwin_today_topic_title_$todayKey');
      final completedAtStr =
          prefs.getString('skilltwin_today_completed_at_$todayKey');
      final completedAt = completedAtStr != null
          ? DateTime.tryParse(completedAtStr)
          : null;
      final isLearning =
          prefs.getBool('skilltwin_today_learning_$todayKey') ?? false;

      if (isAllCompleted) {
        state = state.copyWith(
          status: TodayTaskStatus.completed,
          topicId: topicId,
          topicTitle: topicTitle,
          completedAt: completedAt ?? DateTime.now(),
          dateKey: todayKey,
          completedTopicIds: completedList,
        );
      } else if (isLearning) {
        state = state.copyWith(
          status: TodayTaskStatus.learning,
          topicId: topicId,
          topicTitle: topicTitle,
          dateKey: todayKey,
          completedTopicIds: completedList,
        );
      } else {
        state = state.copyWith(
          status: TodayTaskStatus.notStarted,
          topicId: topicId,
          topicTitle: topicTitle,
          dateKey: todayKey,
          completedTopicIds: completedList,
        );
      }
    } catch (_) {
      // Storage access failure shouldn't crash initialization
    }
  }

  /// Synchronizes state when Home dashboard is fetched from backend.
  void syncWithDashboard(HomeDashboardData data) {
    final todayKey = _formatDate(DateTime.now());
    if (state.dateKey != todayKey) {
      // Day has rolled over
      state = TodayTaskState(dateKey: todayKey);
      _initFromStorage();
    }

    // 1. Gather all completed topic IDs from backend + local cache
    final mergedCompleted = Set<String>.from(state.completedTopicIds);
    for (final task in data.todayTasks) {
      if (task.isCompleted) {
        mergedCompleted.add(task.topicId);
      }
    }

    // 2. Identify the first incomplete task in today's queue
    final queue = data.todayTasks;
    DailyTaskItem? activeTask;
    int activeIdx = 0;

    for (int i = 0; i < queue.length; i++) {
      final t = queue[i];
      if (!mergedCompleted.contains(t.topicId) && !t.isCompleted) {
        activeTask = t;
        activeIdx = i;
        break;
      }
    }

    final totalTasks = queue.isNotEmpty ? queue.length : (data.todayTasksTotal > 0 ? data.todayTasksTotal : 1);
    final isTargetCompleted = (data.todayTargetTopicId != null &&
        data.todayTargetTopicId!.isNotEmpty &&
        mergedCompleted.contains(data.todayTargetTopicId));
    final isLocalCompletedToday = (state.isCompleted && state.dateKey == todayKey);

    final allCompleted = (queue.isNotEmpty && activeTask == null) ||
        data.isTodayCompleted ||
        (data.todayStatus.toUpperCase() == 'COMPLETED' && queue.isEmpty) ||
        isLocalCompletedToday ||
        (queue.isEmpty && isTargetCompleted);

    if (allCompleted) {
      final lastTopicId = queue.isNotEmpty
          ? queue.last.topicId
          : (data.todayTargetTopicId ?? state.topicId);
      final lastTopicTitle = queue.isNotEmpty
          ? queue.last.title
          : (data.todayTargetTopicTitle ?? state.topicTitle);

      state = state.copyWith(
        status: TodayTaskStatus.completed,
        topicId: lastTopicId,
        topicTitle: lastTopicTitle,
        estimatedMinutes: data.todayEstimatedMinutes,
        completedAt: state.completedAt ?? DateTime.now(),
        completedTopicIds: mergedCompleted.toList(),
        tasks: queue,
        totalTasks: totalTasks,
        currentTaskIndex: totalTasks,
      );
      _persistLocally(true, mergedCompleted.toList(), state.topicId, state.topicTitle);
    } else if (activeTask != null) {
      final isCurrentLearning = activeTask.isLearning || (state.isLearning && state.topicId == activeTask.topicId);
      state = state.copyWith(
        status: isCurrentLearning ? TodayTaskStatus.learning : TodayTaskStatus.notStarted,
        topicId: activeTask.topicId,
        topicTitle: activeTask.title,
        estimatedMinutes: activeTask.estimatedMinutes,
        completedTopicIds: mergedCompleted.toList(),
        tasks: queue,
        totalTasks: totalTasks,
        currentTaskIndex: activeIdx,
      );
      _persistLocally(false, mergedCompleted.toList(), activeTask.topicId, activeTask.title);
    } else {
      // Fallback for single task or empty queue
      final isCurrentLearning = (data.todayStatus.toUpperCase() == 'LEARNING' || state.isLearning);
      state = state.copyWith(
        status: isCurrentLearning ? TodayTaskStatus.learning : TodayTaskStatus.notStarted,
        topicId: data.todayTargetTopicId ?? state.topicId,
        topicTitle: data.todayTargetTopicTitle ?? state.topicTitle,
        estimatedMinutes: data.todayEstimatedMinutes ?? state.estimatedMinutes,
        completedTopicIds: mergedCompleted.toList(),
        tasks: queue,
        totalTasks: totalTasks,
      );
      if (state.topicId != null) {
        _persistLocally(false, mergedCompleted.toList(), state.topicId, state.topicTitle);
      }
    }
  }

  /// User initiated learning for today's session.
  void markStarted({required String topicId, String? topicTitle}) {
    final todayKey = _formatDate(DateTime.now());
    state = state.copyWith(
      status: TodayTaskStatus.learning,
      topicId: topicId,
      topicTitle: topicTitle ?? state.topicTitle,
      dateKey: todayKey,
      clearError: true,
    );
    try {
      final prefs = _ref.read(sharedPrefsProvider);
      prefs.setBool('skilltwin_today_learning_$todayKey', true);
      if (topicTitle != null) {
        prefs.setString('skilltwin_today_topic_title_$todayKey', topicTitle);
      }
      prefs.setString('skilltwin_today_topic_id_$todayKey', topicId);
    } catch (_) {}

    _ref.invalidate(homeDashboardProvider);
  }

  /// Persists confirmed completion and advances to the next task in today's queue.
  Future<void> recordCompletion({
    required String topicId,
    String? topicTitle,
    DateTime? completedAt,
  }) async {
    final now = completedAt ?? DateTime.now();
    final todayKey = _formatDate(now);

    // 1. Add topicId to completed topics set
    final updatedCompleted = List<String>.from(state.completedTopicIds);
    if (!updatedCompleted.contains(topicId)) {
      updatedCompleted.add(topicId);
    }
    // Also if state.topicId is set and matches this task, ensure it's in updatedCompleted
    if (state.topicId != null && state.topicId!.isNotEmpty && !updatedCompleted.contains(state.topicId)) {
      if (state.tasks.any((t) => t.id == topicId || t.topicId == topicId)) {
        updatedCompleted.add(state.topicId!);
      }
    }

    // 2. Find next incomplete task in queue
    DailyTaskItem? nextTask;
    int nextIdx = state.currentTaskIndex;

    if (state.tasks.isNotEmpty) {
      for (int i = 0; i < state.tasks.length; i++) {
        final t = state.tasks[i];
        if (t.topicId != topicId && t.id != topicId && !updatedCompleted.contains(t.topicId)) {
          nextTask = t;
          nextIdx = i;
          break;
        }
      }
    }

    final isAllDone = (state.tasks.isNotEmpty && nextTask == null) ||
        (state.tasks.isEmpty && updatedCompleted.isNotEmpty);

    if (isAllDone) {
      // All tasks for today completed!
      await _persistLocally(true, updatedCompleted, topicId, topicTitle, now);
      state = state.copyWith(
        status: TodayTaskStatus.completed,
        topicId: topicId,
        topicTitle: topicTitle ?? state.topicTitle,
        completedAt: now,
        dateKey: todayKey,
        isSubmitting: false,
        clearError: true,
        completedTopicIds: updatedCompleted,
        currentTaskIndex: state.totalTasks,
      );
    } else {
      // Advance to next task in today's queue!
      await _persistLocally(false, updatedCompleted, nextTask!.topicId, nextTask.title, now);
      state = state.copyWith(
        status: TodayTaskStatus.notStarted,
        topicId: nextTask.topicId,
        topicTitle: nextTask.title,
        estimatedMinutes: nextTask.estimatedMinutes,
        dateKey: todayKey,
        isSubmitting: false,
        clearError: true,
        completedTopicIds: updatedCompleted,
        currentTaskIndex: nextIdx,
      );
    }

    _ref.invalidate(homeDashboardProvider);
  }

  /// Handles completion API failure without false completion.
  void recordFailure(String errorMessage) {
    state = state.copyWith(
      isSubmitting: false,
      error: errorMessage,
      // Retains previous status (e.g. learning), does NOT mark completed
    );
  }

  Future<void> _persistLocally(
    bool allCompleted,
    List<String> completedTopicIds,
    String? currentTopicId,
    String? currentTopicTitle, [
    DateTime? completedAt,
  ]) async {
    try {
      final prefs = _ref.read(sharedPrefsProvider);
      final todayKey = _formatDate(completedAt ?? DateTime.now());
      await prefs.setBool('skilltwin_today_completed_$todayKey', allCompleted);
      await prefs.setBool('skilltwin_today_learning_$todayKey', false);
      await prefs.setStringList(
          'skilltwin_today_completed_topics_$todayKey', completedTopicIds);
      if (currentTopicId != null) {
        await prefs.setString('skilltwin_today_topic_id_$todayKey', currentTopicId);
      }
      if (currentTopicTitle != null) {
        await prefs.setString(
            'skilltwin_today_topic_title_$todayKey', currentTopicTitle);
      }
      if (completedAt != null && allCompleted) {
        await prefs.setString(
            'skilltwin_today_completed_at_$todayKey', completedAt.toIso8601String());
      }
    } catch (_) {}
  }
}

final todayTaskStateProvider =
    StateNotifierProvider<TodayTaskStateNotifier, TodayTaskState>((ref) {
  return TodayTaskStateNotifier(ref);
});
