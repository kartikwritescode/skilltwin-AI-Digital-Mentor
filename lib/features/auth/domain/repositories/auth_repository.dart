import '../../../../core/models/user.dart';

abstract class AuthRepository {
  Future<User?> getCurrentUser();
  Future<User> login(String email, String password);
  Future<User> signup({
    required String email,
    required String password,
    required String name,
  });
  Future<void> logout();
  Stream<User?> get authStateChanges;
  
  /// Checks if the user has completed their initial goal setting
  Future<bool> isUserOnboarded();
}
