import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Auth state
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  @override
  String toString() =>
      'AuthState(user: ${user?.email}, isLoading: $isLoading, isAuthenticated: $isAuthenticated)';
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState()) {
    _initAuth();
  }

  Future<void> _initAuth() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, isAuthenticated: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, isAuthenticated: false);
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.login(email: email, password: password);
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('AuthException: ', ''),
        isAuthenticated: false,
      );
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? country,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.register(
        name: name,
        email: email,
        password: password,
        country: country,
      );
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('AuthException: ', ''),
        isAuthenticated: false,
      );
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.signInWithGoogle();
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('AuthException: ', ''),
      );
      return false;
    }
  }

  Future<bool> signInWithApple() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.signInWithApple();
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('AuthException: ', ''),
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.logout();
      state = const AuthState(isAuthenticated: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.forgotPassword(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('AuthException: ', ''),
      );
      return false;
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? avatarUrl,
    String? language,
    String? currency,
    String? theme,
  }) async {
    if (state.user == null) return false;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedUser = await _repository.updateProfile(
        userId: state.user!.id,
        name: name,
        avatarUrl: avatarUrl,
        language: language,
        currency: currency,
        theme: theme,
      );
      state = state.copyWith(user: updatedUser, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('AuthException: ', ''),
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

// Convenience providers
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});
