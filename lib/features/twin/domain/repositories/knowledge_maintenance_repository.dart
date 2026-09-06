import '../../../../core/models/knowledge_maintenance_item.dart';

abstract class KnowledgeMaintenanceRepository {
  Future<List<KnowledgeMaintenanceItem>> getMaintenancePlan();
  Future<void> updateMaintenanceStatus(String itemId, MaintenanceStatus status);
}
