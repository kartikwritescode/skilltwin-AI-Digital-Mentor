import '../../../../core/models/user.dart';

abstract class ProfileRepository {
  Future<User> getUserProfile();
  Future<void> updateProfile(User user);
  Future<void> updatePreferences(Map<String, dynamic> preferences);
}
