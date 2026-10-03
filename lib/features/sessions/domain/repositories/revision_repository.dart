import '../../../../core/models/revision_item.dart';
import '../../../../core/models/mentor_notification.dart';

abstract class RevisionRepository {
  Future<List<RevisionItem>> getDueItems();
  Future<RevisionQueueData> getPrioritizedQueue();
  Future<void> submitRevisionResult(String conceptId, bool success);
  Future<RetrievalSubmissionResult> submitRetrieval({
    required String reviewItemId,
    required String accuracy,
    required String confidence,
    int timeSpentSeconds = 90,
  });
  Future<List<MentorNotification>> getMentorNotifications();
  Future<void> markNotificationAsRead(String id);

  // Feynman Teachback Conversation Methods
  Future<Map<String, dynamic>> getTeachbackFeedback({
    required String conceptId,
    required String userExplanation,
    required List<Map<String, String>> conversationHistory,
  });

  Future<Map<String, dynamic>> submitTeachbackSession({
    required String conceptId,
    required int turnCount,
    required double finalMasteryScore,
    required List<Map<String, String>> conversationHistory,
  });
}

