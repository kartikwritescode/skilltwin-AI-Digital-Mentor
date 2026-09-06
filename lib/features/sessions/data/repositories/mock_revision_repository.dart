import '../../domain/repositories/revision_repository.dart';
import '../../../../core/models/revision_item.dart';
import '../../../../core/models/mentor_notification.dart';

class MockRevisionRepository implements RevisionRepository {
  final List<RevisionItem> _mockItems = [
    RevisionItem(
      id: 'rev_recursion',
      conceptId: 'recursion',
      title: 'Recursion',
      mastery: 0.78,
      risk: RetentionRisk.high,
      lastRetrieval: DateTime.now().subtract(const Duration(days: 9)),
      dueDate: DateTime.now(),
      mentorNote: 'Give me 4 minutes. I want to check whether the mental model is still intact.',
      whyToday: 'Memory decay threshold reached. Spaced retrieval anchors foundational invariants.',
      mentorPrompt: 'Give me 4 minutes. I want to check whether your mental model is intact.',
      estimatedMinutes: 4,
      priorityScore: 94.5,
      interval: 1,
    ),
    RevisionItem(
      id: 'rev_chain_rule',
      conceptId: 'chain_rule',
      title: 'Chain Rule',
      mastery: 0.85,
      risk: RetentionRisk.medium,
      lastRetrieval: DateTime.now().subtract(const Duration(days: 14)),
      dueDate: DateTime.now().add(const Duration(hours: 4)),
      mentorNote: 'You haven\'t used this in a while. Let\'s do a quick refresher.',
      whyToday: 'Scheduled 2-week spacing interval to consolidate gradient propagation.',
      mentorPrompt: 'State the multivariate chain rule expansion and how backpropagation decomposes it.',
      estimatedMinutes: 3,
      priorityScore: 82.0,
      interval: 2,
    ),
    RevisionItem(
      id: 'rev_precision_recall',
      conceptId: 'precision_recall',
      title: 'Precision vs Recall',
      mastery: 0.68,
      risk: RetentionRisk.high,
      lastRetrieval: DateTime.now().subtract(const Duration(days: 5)),
      dueDate: DateTime.now(),
      mentorNote: 'Address recurring confusion on false positive penalties.',
      whyToday: 'Repeated confusion on false positive vs false negative trade-offs.',
      mentorPrompt: 'Distinguish when high recall is mandatory versus high precision in medical screening.',
      estimatedMinutes: 4,
      priorityScore: 89.0,
      interval: 1,
    ),
  ];

  final List<MentorNotification> _mockNotifications = [
    MentorNotification(
      id: 'notif_rev_1',
      title: '5 minutes for your future self.',
      message:
          "Memory retention for 'Recursion' is decaying. A quick retrieval session now stops forgetting.",
      conceptId: 'recursion',
      notificationType: 'REVISION_DUE',
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
      isRead: false,
      actionUrl: '/revision',
    ),
    MentorNotification(
      id: 'notif_rev_2',
      title: 'Foundational Invariant Review',
      message:
          "Chain rule retention is nearing decay threshold. 3 minutes today solidifies backpropagation.",
      conceptId: 'chain_rule',
      notificationType: 'REVISION_DUE',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: false,
      actionUrl: '/revision',
    ),
  ];

  @override
  Future<List<RevisionItem>> getDueItems() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_mockItems);
  }

  @override
  Future<RevisionQueueData> getPrioritizedQueue() async {
    await Future.delayed(const Duration(milliseconds: 250));
    final sorted = List<RevisionItem>.from(_mockItems)
      ..sort((a, b) => b.priorityScore.compareTo(a.priorityScore));

    final primary = sorted.isNotEmpty ? sorted.first : null;
    final upcoming = sorted.length > 1 ? sorted.sublist(1, sorted.length.clamp(1, 3)) : <RevisionItem>[];

    return RevisionQueueData(
      header: '5 minutes for your future self.',
      totalDueCount: sorted.length,
      primaryItem: primary,
      upcomingItems: upcoming,
      mentorGuidance:
          'Consistent 5-minute retrieval is the single highest-yield cognitive investment.',
    );
  }

  @override
  Future<void> submitRevisionResult(String conceptId, bool success) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _mockItems.indexWhere((i) => i.conceptId == conceptId);
    if (index != -1) {
      final current = _mockItems[index];
      _mockItems[index] = RevisionItem(
        id: current.id,
        conceptId: current.conceptId,
        title: current.title,
        mastery: success ? (current.mastery + 0.1).clamp(0.0, 1.0) : current.mastery,
        risk: success ? RetentionRisk.low : RetentionRisk.high,
        lastRetrieval: DateTime.now(),
        dueDate: DateTime.now().add(Duration(days: success ? 3 : 1)),
        mentorNote: current.mentorNote,
        whyToday: current.whyToday,
        mentorPrompt: current.mentorPrompt,
        estimatedMinutes: current.estimatedMinutes,
        interval: success ? 3 : 1,
        nextReviewText: success ? 'Next review in 3 days.' : 'Next review in 1 day.',
      );
    }
  }

  @override
  Future<RetrievalSubmissionResult> submitRetrieval({
    required String reviewItemId,
    required String accuracy,
    required String confidence,
    int timeSpentSeconds = 90,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final isSuccess = accuracy == 'correct' || accuracy == 'partially_correct';
    final isConfident = confidence == 'confident';
    
    // As explicitly specified: "Then show: 'Next review in 3 days.'"
    final int interval = isSuccess ? (isConfident ? 3 : 2) : 1;
    final String nextReviewText = isSuccess && isConfident
        ? 'Next review in 3 days.'
        : 'Next review in $interval ${interval == 1 ? "day" : "days"}.';

    final updatedRisk = isSuccess ? RetentionRisk.low : RetentionRisk.high;
    final updatedScore = isSuccess ? 92.0 : 45.0;

    // Update in-memory item
    final index = _mockItems.indexWhere((i) => i.id == reviewItemId || i.conceptId == reviewItemId);
    if (index != -1) {
      final current = _mockItems[index];
      _mockItems[index] = RevisionItem(
        id: current.id,
        conceptId: current.conceptId,
        title: current.title,
        mastery: isSuccess ? 0.92 : 0.50,
        risk: updatedRisk,
        lastRetrieval: DateTime.now(),
        dueDate: DateTime.now().add(Duration(days: interval)),
        mentorNote: current.mentorNote,
        whyToday: current.whyToday,
        mentorPrompt: current.mentorPrompt,
        estimatedMinutes: current.estimatedMinutes,
        interval: interval,
        nextReviewText: nextReviewText,
      );
    }

    return RetrievalSubmissionResult(
      reviewItemId: reviewItemId,
      nextReviewText: nextReviewText,
      intervalDays: interval,
      updatedRisk: updatedRisk,
      updatedRetentionScore: updatedScore,
    );
  }

  @override
  Future<List<MentorNotification>> getMentorNotifications() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_mockNotifications);
  }

  @override
  Future<void> markNotificationAsRead(String id) async {
    final index = _mockNotifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _mockNotifications[index] = _mockNotifications[index].copyWith(isRead: true);
    }
  }
}

