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
}

