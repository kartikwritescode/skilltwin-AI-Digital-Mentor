import '../../domain/repositories/revision_repository.dart';
import '../../../../core/models/revision_item.dart';
import '../../../../core/models/mentor_notification.dart';
import '../../../../core/networking/api_client.dart';
import 'mock_revision_repository.dart';

class RevisionRepositoryImpl implements RevisionRepository {
  final ApiClient _apiClient;
  final MockRevisionRepository _mockFallback = MockRevisionRepository();

  RevisionRepositoryImpl(this._apiClient);

  @override
  Future<List<RevisionItem>> getDueItems() async {
    try {
      final queue = await getPrioritizedQueue();
      return queue.allQueueItems;
    } catch (_) {
      return _mockFallback.getDueItems();
    }
  }

  @override
  Future<RevisionQueueData> getPrioritizedQueue() async {
    try {
      final response = await _apiClient.get('/revision/next');
      if (response.data != null && response.data is Map<String, dynamic>) {
        return RevisionQueueData.fromJson(response.data as Map<String, dynamic>);
      }
      return _mockFallback.getPrioritizedQueue();
    } catch (_) {
      return _mockFallback.getPrioritizedQueue();
    }
  }

  @override
  Future<void> submitRevisionResult(String conceptId, bool success) async {
    try {
      await _apiClient.post(
        '/revision/$conceptId/complete',
        data: {
          'is_successful': success,
          'time_spent_seconds': 120,
        },
      );
    } catch (_) {
      await _mockFallback.submitRevisionResult(conceptId, success);
    }
  }

  @override
  Future<RetrievalSubmissionResult> submitRetrieval({
    required String reviewItemId,
    required String accuracy,
    required String confidence,
    int timeSpentSeconds = 90,
  }) async {
    try {
      final response = await _apiClient.post(
        '/revision/submit',
        data: {
          'review_item_id': reviewItemId,
          'accuracy': accuracy,
          'confidence': confidence,
          'time_spent_seconds': timeSpentSeconds,
        },
      );
      if (response.data != null && response.data is Map<String, dynamic>) {
        return RetrievalSubmissionResult.fromJson(response.data as Map<String, dynamic>);
      }
      return _mockFallback.submitRetrieval(
        reviewItemId: reviewItemId,
        accuracy: accuracy,
        confidence: confidence,
        timeSpentSeconds: timeSpentSeconds,
      );
    } catch (_) {
      return _mockFallback.submitRetrieval(
        reviewItemId: reviewItemId,
        accuracy: accuracy,
        confidence: confidence,
        timeSpentSeconds: timeSpentSeconds,
      );
    }
  }

  @override
  Future<List<MentorNotification>> getMentorNotifications() async {
    try {
      final response = await _apiClient.get('/revision/notifications');
      if (response.data != null && response.data is Map<String, dynamic>) {
        final list = (response.data['notifications'] as List?)
                ?.map((e) => MentorNotification.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
        if (list.isNotEmpty) return list;
      }
      return _mockFallback.getMentorNotifications();
    } catch (_) {
      return _mockFallback.getMentorNotifications();
    }
  }

  @override
  Future<void> markNotificationAsRead(String id) async {
    try {
      // In backend notifications are marked read
      await _mockFallback.markNotificationAsRead(id);
    } catch (_) {
      await _mockFallback.markNotificationAsRead(id);
    }
  }
}
