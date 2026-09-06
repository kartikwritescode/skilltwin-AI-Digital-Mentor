import '../../../../core/networking/api_client.dart';
import '../../../../core/models/user.dart';
import '../../domain/repositories/profile_repository.dart';
import 'mock_profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ApiClient _apiClient;
  final MockProfileRepository _fallback = MockProfileRepository();

  ProfileRepositoryImpl(this._apiClient);

  @override
  Future<User> getUserProfile() async {
    try {
      final response = await _apiClient.get('/profile');
      return User.fromJson(response.data);
    } catch (_) {
      return _fallback.getUserProfile();
    }
  }

  @override
  Future<void> updateProfile(User user) async {
    try {
      await _apiClient.patch('/profile', data: user.toJson());
    } catch (_) {
      await _fallback.updateProfile(user);
    }
  }

  @override
  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    try {
      await _apiClient.patch('/profile', data: {'preferences': preferences});
    } catch (_) {
      await _fallback.updatePreferences(preferences);
    }
  }
}
