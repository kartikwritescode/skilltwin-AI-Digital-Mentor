import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/mock_knowledge_maintenance_repository.dart';
import '../../domain/repositories/knowledge_maintenance_repository.dart';

final knowledgeMaintenanceRepositoryProvider = Provider<KnowledgeMaintenanceRepository>((ref) {
  return MockKnowledgeMaintenanceRepository();
});
