import '../../../../core/networking/api_client.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/models/learner_concept.dart';
import '../../../../core/models/evidence.dart';
import '../../../../core/models/twin_dashboard.dart';
import '../../domain/repositories/twin_repository.dart';

class TwinRepositoryImpl implements TwinRepository {
  final ApiClient _apiClient;
  static TwinDashboardData? _cachedData;
  static DateTime? _lastFetchedAt;

  TwinRepositoryImpl(this._apiClient);

  @override
  TwinDashboardData? getCachedTwinDashboard() => _cachedData;

  @override
  Future<TwinDashboardData> getTwinDashboard({bool forceRefresh = false}) async {
    // Stale-While-Revalidate: Return cache immediately if fresh and not forcing refresh
    if (!forceRefresh && _cachedData != null && _lastFetchedAt != null) {
      final age = DateTime.now().difference(_lastFetchedAt!);
      if (age < const Duration(minutes: 5)) {
        return _cachedData!;
      }
    }

    try {
      final response = await _apiClient.get('/twin/dashboard');
      if (response.data is Map<String, dynamic>) {
        final data = TwinDashboardData.fromJson(response.data as Map<String, dynamic>);
        _cachedData = data;
        _lastFetchedAt = DateTime.now();
        return data;
      }
      return _cachedData ?? const TwinDashboardData(userId: '');
    } catch (e) {
      // Offline fallback: preserve previously cached state
      if (_cachedData != null) {
        return _cachedData!;
      }
      if (e is ServerFailure && e.message.toLowerCase().contains('not found')) {
        const empty = TwinDashboardData(userId: '', hasSufficientData: false);
        _cachedData = empty;
        return empty;
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
