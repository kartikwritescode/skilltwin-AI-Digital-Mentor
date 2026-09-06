import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/storage_provider.dart';
import 'api_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return ApiClient(storageService: secureStorage);
});
