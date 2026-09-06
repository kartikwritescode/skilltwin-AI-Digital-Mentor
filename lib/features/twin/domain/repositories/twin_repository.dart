import '../../../../core/models/learner_concept.dart';
import '../../../../core/models/evidence.dart';

abstract class TwinRepository {
  Future<List<LearnerConcept>> getLearnerState();
  Future<List<Evidence>> getEvidenceHistory();
  Future<LearnerConcept> getConceptById(String conceptId);
  Future<Map<String, dynamic>> getTwinOverview();
  Future<Map<String, dynamic>> getGraphTopology();
}
