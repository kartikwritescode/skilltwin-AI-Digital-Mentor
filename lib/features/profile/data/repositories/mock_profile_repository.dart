import '../../domain/repositories/profile_repository.dart';
import '../../../../core/models/user.dart';

class MockProfileRepository implements ProfileRepository {
  @override
  Future<User> getUserProfile() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return User(id: '1', email: 'alex@example.com', name: 'Alex Learner');
  }

  @override
  Future<void> updateProfile(User user) async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
