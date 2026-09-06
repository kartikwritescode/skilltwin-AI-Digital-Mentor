import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/twin_repository_provider.dart';
import '../../../../core/models/learner_concept.dart';
import '../../../../core/models/evidence.dart';

final learnerStateProvider = FutureProvider<List<LearnerConcept>>((ref) async {
  final repository = ref.watch(twinRepositoryProvider);
  return repository.getLearnerState();
});

final evidenceHistoryProvider = FutureProvider<List<Evidence>>((ref) async {
  final repository = ref.watch(twinRepositoryProvider);
  return repository.getEvidenceHistory();
});

final twinOverviewProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(twinRepositoryProvider);
  return repository.getTwinOverview();
});

final conceptDetailProvider = FutureProvider.family<LearnerConcept, String>((ref, conceptId) async {
  final repository = ref.watch(twinRepositoryProvider);
  return repository.getConceptById(conceptId);
});
