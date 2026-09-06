import '../../../../core/networking/api_client.dart';
import '../../../../core/models/journey_node.dart';
import '../../domain/repositories/journey_repository.dart';
import 'mock_journey_repository.dart';

class JourneyRepositoryImpl implements JourneyRepository {
  final ApiClient _apiClient;
  final MockJourneyRepository _fallback = MockJourneyRepository();

  JourneyRepositoryImpl(this._apiClient);

  @override
  Future<List<JourneyNode>> getJourneyNodes(String goalId) async {
    try {
      final response = await _apiClient.get('/journeys/$goalId');
      if (response.data is List) {
        return (response.data as List).map((e) => JourneyNode.fromJson(e)).toList();
      } else if (response.data is Map && response.data['nodes'] is List) {
        return (response.data['nodes'] as List).map((e) => JourneyNode.fromJson(e)).toList();
      }
      return _fallback.getJourneyNodes(goalId);
    } catch (_) {
      return _fallback.getJourneyNodes(goalId);
    }
  }

  @override
  Future<void> updateNodeStatus(String nodeId, NodeStatus status) async {
    try {
      await _apiClient.patch('/journeys/nodes/$nodeId', data: {
        'status': status.name,
      });
    } catch (_) {
      await _fallback.updateNodeStatus(nodeId, status);
    }
  }

  Future<JourneyNode?> injectRemediation(String journeyId, String conceptId) async {
    try {
      final response = await _apiClient.post('/journeys/$journeyId/remediation', data: {
        'concept_id': conceptId,
      });
      return JourneyNode.fromJson(response.data);
    } catch (_) {
      return null;
    }
  }
}
