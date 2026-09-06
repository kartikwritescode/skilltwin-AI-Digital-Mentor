import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/knowledge_maintenance_repository_provider.dart';
import '../../../../core/models/knowledge_maintenance_item.dart';

final knowledgeMaintenanceProvider = FutureProvider<List<KnowledgeMaintenanceItem>>((ref) async {
  final repository = ref.watch(knowledgeMaintenanceRepositoryProvider);
  return repository.getMaintenancePlan();
});
