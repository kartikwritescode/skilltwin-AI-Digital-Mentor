import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/revision_item.dart';
import '../../../../core/models/mentor_notification.dart';
import '../../domain/repositories/revision_repository.dart';
import '../../data/repositories/revision_repository_provider.dart';

class RevisionState {
  final String header;
  final String mentorGuidance;
  final RevisionItem? primaryItem;
  final List<RevisionItem> upcomingItems;
  final List<RevisionItem> dueItems;
  final int totalDueCount;
  final List<MentorNotification> notifications;
  final bool isLoading;
  final bool isSubmitting;
  final RetrievalSubmissionResult? lastSubmissionResult;
  final String? error;

  RevisionState({
    this.header = '5 minutes for your future self.',
    this.mentorGuidance =
        'Consistent 5-minute retrieval is the single highest-yield cognitive investment.',
    this.primaryItem,
    this.upcomingItems = const [],
    this.dueItems = const [],
    this.totalDueCount = 0,
    this.notifications = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.lastSubmissionResult,
    this.error,
  });

  int get unreadNotificationCount =>
      notifications.where((n) => !n.isRead).length;

  RevisionState copyWith({
    String? header,
    String? mentorGuidance,
    RevisionItem? primaryItem,
    bool clearPrimaryItem = false,
    List<RevisionItem>? upcomingItems,
    List<RevisionItem>? dueItems,
    int? totalDueCount,
    List<MentorNotification>? notifications,
    bool? isLoading,
    bool? isSubmitting,
    RetrievalSubmissionResult? lastSubmissionResult,
    bool clearSubmissionResult = false,
    String? error,
  }) {
    return RevisionState(
      header: header ?? this.header,
      mentorGuidance: mentorGuidance ?? this.mentorGuidance,
      primaryItem: clearPrimaryItem ? null : (primaryItem ?? this.primaryItem),
      upcomingItems: upcomingItems ?? this.upcomingItems,
      dueItems: dueItems ?? this.dueItems,
      totalDueCount: totalDueCount ?? this.totalDueCount,
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      lastSubmissionResult: clearSubmissionResult
          ? null
          : (lastSubmissionResult ?? this.lastSubmissionResult),
      error: error,
    );
  }
}

final revisionProvider =
    StateNotifierProvider<RevisionNotifier, RevisionState>((ref) {
  final repository = ref.watch(revisionRepositoryProvider);
  return RevisionNotifier(repository);
});

class RevisionNotifier extends StateNotifier<RevisionState> {
  final RevisionRepository _repository;

  RevisionNotifier(this._repository) : super(RevisionState()) {
    loadDueItems();
    loadNotifications();
  }

  Future<void> loadDueItems() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final queueData = await _repository.getPrioritizedQueue();
      state = state.copyWith(
        header: queueData.header,
        mentorGuidance: queueData.mentorGuidance,
        primaryItem: queueData.primaryItem,
        upcomingItems: queueData.upcomingItems,
        dueItems: queueData.allQueueItems,
        totalDueCount: queueData.totalDueCount,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadNotifications() async {
    try {
      final notifs = await _repository.getMentorNotifications();
      state = state.copyWith(notifications: notifs);
    } catch (_) {
      // Keep existing notifications
    }
  }

  Future<void> markNotificationRead(String id) async {
    try {
      await _repository.markNotificationAsRead(id);
      final updated = state.notifications.map((n) {
        if (n.id == id) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();
      state = state.copyWith(notifications: updated);
    } catch (_) {}
  }

  Future<RetrievalSubmissionResult?> submitRetrieval({
    required String reviewItemId,
    required String accuracy,
    required String confidence,
    int timeSpentSeconds = 90,
  }) async {
    state = state.copyWith(isSubmitting: true);
    try {
      final result = await _repository.submitRetrieval(
        reviewItemId: reviewItemId,
        accuracy: accuracy,
        confidence: confidence,
        timeSpentSeconds: timeSpentSeconds,
      );
      state = state.copyWith(
        isSubmitting: false,
        lastSubmissionResult: result,
      );
      // Reload queue to update next items and counts
      await loadDueItems();
      return result;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return null;
    }
  }

  Future<void> submitResult(String conceptId, bool success) async {
    try {
      await _repository.submitRevisionResult(conceptId, success);
      await loadDueItems();
    } catch (_) {}
  }
}

