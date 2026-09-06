import '../../../../core/networking/api_client.dart';
import '../../../../core/models/learner_concept.dart';
import '../../../../core/models/evidence.dart';
import '../../domain/repositories/twin_repository.dart';
import 'mock_twin_repository.dart';

class TwinRepositoryImpl implements TwinRepository {
  final ApiClient _apiClient;
  final MockTwinRepository _fallback = MockTwinRepository();

  TwinRepositoryImpl(this._apiClient);

  @override
  Future<List<LearnerConcept>> getLearnerState() async {
    try {
      final response = await _apiClient.get('/twin/concepts');
      return (response.data as List).map((e) => LearnerConcept.fromJson(e)).toList();
    } catch (_) {
      return _fallback.getLearnerState();
    }
  }

  @override
  Future<List<Evidence>> getEvidenceHistory() async {
    try {
      final response = await _apiClient.get('/twin/evidence');
      return (response.data as List).map((e) => Evidence.fromJson(e)).toList();
    } catch (_) {
      return _fallback.getEvidenceHistory();
    }
  }

  @override
  Future<LearnerConcept> getConceptById(String conceptId) async {
    try {
      final response = await _apiClient.get('/concepts/$conceptId');
      return LearnerConcept.fromJson(response.data);
    } catch (_) {
      return _fallback.getConceptById(conceptId);
    }
  }

  @override
  Future<Map<String, dynamic>> getTwinOverview() async {
    try {
      final response = await _apiClient.get('/twin');
      return Map<String, dynamic>.from(response.data);
    } catch (_) {
      return _fallback.getTwinOverview();
    }
  }
}
