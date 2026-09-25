import '../../../../core/models/journey_node.dart';

abstract class JourneyRepository {
  Future<List<JourneyNode>> getJourneyNodes(String goalId);
  Future<void> updateNodeStatus(String nodeId, NodeStatus status);
  Future<void> prewarmNodeExpansion(String pathId, String nodeId);
}
