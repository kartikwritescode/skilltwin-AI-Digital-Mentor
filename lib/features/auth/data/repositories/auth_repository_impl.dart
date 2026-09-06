import 'dart:async';
import '../../../../core/networking/api_client.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/models/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final StorageService _secureStorage;
  final _authStateController = StreamController<User?>.broadcast();
  User? _currentUser;

  AuthRepositoryImpl(this._apiClient, this._secureStorage);

  @override
  Stream<User?> get authStateChanges => _authStateController.stream;

  @override
  Future<User?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    
    final token = await _secureStorage.read('auth_token');
    if (token == null) return null;

    try {
      // The ApiClient should ideally handle adding the token to headers via interceptors
      // which we'll implement or assume is configured.
      final response = await _apiClient.get('/auth/me');
      _currentUser = User.fromJson(response.data);
      _authStateController.add(_currentUser);
      return _currentUser;
    } catch (e) {
      await logout();
      return null;
    }
  }

  @override
  Future<User> login(String email, String password) async {
    final response = await _apiClient.post('/auth/login', data: {
      'email': email,
      'password': password,
    });

    final user = User.fromJson(response.data['user']);
    final token = response.data['access_token'];

    await _secureStorage.write('auth_token', token);
    _currentUser = user;
    _authStateController.add(_currentUser);
    
    return user;
  }

  @override
  Future<User> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _apiClient.post('/auth/signup', data: {
      'email': email,
      'password': password,
      'name': name,
    });

    final user = User.fromJson(response.data['user']);
    final token = response.data['access_token'];

    await _secureStorage.write('auth_token', token);
    _currentUser = user;
    _authStateController.add(_currentUser);

    return user;
  }

  @override
  Future<void> logout() async {
    await _secureStorage.delete('auth_token');
    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  Future<bool> isUserOnboarded() async {
    try {
      final response = await _apiClient.get('/auth/onboarding-status');
      return response.data['is_onboarded'] ?? false;
    } catch (e) {
      // In development or if endpoint doesn't exist yet, we might return false
      return false;
    }
  }
}
