import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_provider.dart';
import '../../../../core/models/user.dart';

enum AuthStatus { initial, loading, authenticated, onboardingRequired, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState()) {
    restoreSession();
  }

  Future<void> restoreSession() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        final isOnboarded = await _repository.isUserOnboarded();
        state = state.copyWith(
          status: isOnboarded ? AuthStatus.authenticated : AuthStatus.onboardingRequired,
          user: user,
        );
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _repository.login(email, password);
      final isOnboarded = await _repository.isUserOnboarded();
      state = state.copyWith(
        status: isOnboarded ? AuthStatus.authenticated : AuthStatus.onboardingRequired,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Invalid credentials or network error.',
      );
    }
  }

  Future<void> signup(String email, String password, String name) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _repository.signup(email: email, password: password, name: name);
      // New users always start at onboarding
      state = state.copyWith(
        status: AuthStatus.onboardingRequired,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Signup failed. Please try again.',
      );
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
  }

  void completeOnboarding() {
    if (state.user != null) {
      state = state.copyWith(status: AuthStatus.authenticated);
    }
  }

  void updateUser(User user) {
    state = state.copyWith(user: user);
  }

  void setOnboardingComplete() => completeOnboarding();
}
