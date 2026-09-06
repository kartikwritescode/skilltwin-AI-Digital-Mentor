import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'storage_service.dart';
import 'shared_prefs_storage_service.dart';
import 'secure_storage_service.dart';

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize this in main()');
});

final storageServiceProvider = Provider<StorageService>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return SharedPrefsStorageService(prefs);
});

final secureStorageServiceProvider = Provider<StorageService>((ref) {
  return SecureStorageService(const FlutterSecureStorage());
});
