import 'dart:async';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/models/user.dart';

class MockAuthRepository implements AuthRepository {
  final _controller = StreamController<User?>.broadcast();
  User? _currentUser;
  bool _mockOnboarded = false;

  MockAuthRepository() {
    // For local dev convenience, start unauthenticated or authenticated
    // _currentUser = User(id: '1', email: 'user@example.com', name: 'Alex Learner');
    // _controller.add(_currentUser);
  }

  @override
  Stream<User?> get authStateChanges => _controller.stream;

  @override
  Future<User?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _currentUser;
  }

  @override
  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = User(id: '1', email: email, name: 'Alex Learner');
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<User> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = User(id: '1', email: email, name: name);
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Future<bool> isUserOnboarded() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockOnboarded;
  }
  
  // Helper for mock logic
  void setMockOnboarded(bool value) {
    _mockOnboarded = value;
  }
}
