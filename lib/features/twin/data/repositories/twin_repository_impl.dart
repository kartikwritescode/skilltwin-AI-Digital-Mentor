import '../../../../core/networking/api_client.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/models/learner_concept.dart';
import '../../../../core/models/evidence.dart';
import '../../../../core/models/twin_dashboard.dart';
import '../../domain/repositories/twin_repository.dart';

class TwinRepositoryImpl implements TwinRepository {
  final ApiClient _apiClient;

  TwinRepositoryImpl(this._apiClient);

  @override
  Future<TwinDashboardData> getTwinDashboard() async {
    try {
      final response = await _apiClient.get('/twin/dashboard');
      if (response.data is Map<String, dynamic>) {
        return TwinDashboardData.fromJson(response.data as Map<String, dynamic>);
      }
      return const TwinDashboardData(userId: '');
    } catch (e) {
      if (e is ServerFailure && e.message.toLowerCase().contains('not found')) {
        return const TwinDashboardData(userId: '', hasSufficientData: false);
      }
      rethrow;
    }
  }

  @override
  Future<List<LearnerConcept>> getLearnerState() async {
    try {
      final response = await _apiClient.get('/twin/concepts');
      if (response.data is List) {
        return (response.data as List)
            .map((e) => LearnerConcept.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<Evidence>> getEvidenceHistory() async {
    try {
      final response = await _apiClient.get('/twin/evidence');
      if (response.data is List) {
        return (response.data as List)
            .map((e) => Evidence.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<LearnerConcept> getConceptById(String conceptId) async {
    final response = await _apiClient.get('/concepts/$conceptId');
    return LearnerConcept.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<Map<String, dynamic>> getTwinOverview() async {
    try {
      final response = await _apiClient.get('/twin');
      return Map<String, dynamic>.from(response.data as Map);
    } catch (_) {
      return {};
    }
  }

  @override
  Future<Map<String, dynamic>> getGraphTopology() async {
    try {
      final response = await _apiClient.get('/concepts/graph/topology');
      return Map<String, dynamic>.from(response.data as Map);
    } catch (_) {
      return {};
    }
  }
}
