import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/config/app_config.dart';
import '../networking/api_client.dart';
import '../networking/api_provider.dart';

class HealthStatus {
  final bool isHealthy;
  final String message;
  final int statusCode;

  HealthStatus({
    required this.isHealthy,
    required this.message,
    required this.statusCode,
  });
}

class HealthService {
  final ApiClient _apiClient;

  HealthService(this._apiClient);

  Future<HealthStatus> checkRootHealth() async {
    try {
      final response = await _apiClient.rawDio.get('${AppConfig.rootUrl}/health');
      return HealthStatus(
        isHealthy: response.statusCode == 200,
        message: response.data?.toString() ?? 'Service ready',
        statusCode: response.statusCode ?? 200,
      );
    } catch (e) {
      return HealthStatus(
        isHealthy: false,
        message: 'Backend waking up or unreachable: $e',
        statusCode: 503,
      );
    }
  }

  Future<HealthStatus> checkV1Health() async {
    try {
      final response = await _apiClient.get('/health');
      return HealthStatus(
        isHealthy: response.statusCode == 200,
        message: response.data?.toString() ?? 'API v1 healthy',
        statusCode: response.statusCode ?? 200,
      );
    } catch (e) {
      return HealthStatus(
        isHealthy: false,
        message: 'API v1 unreachable: $e',
        statusCode: 503,
      );
    }
  }
}

final healthServiceProvider = Provider<HealthService>((ref) {
  final client = ref.watch(apiClientProvider);
  return HealthService(client);
});
