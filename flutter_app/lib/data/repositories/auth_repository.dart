import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';

class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, {this.code});

  @override
  String toString() => 'AuthException: $message';
}

class AuthRepository {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Login with email and password
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 1500));

      // Mock response - in production, replace with actual API call
      if (email.isEmpty || password.isEmpty) {
        throw const AuthException('Email and password are required');
      }

      if (password.length < 8) {
        throw const AuthException('Invalid credentials', code: 'invalid_credentials');
      }

      final user = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: email.split('@')[0].replaceAll('.', ' ').split(' ').map((s) {
          if (s.isEmpty) return s;
          return s[0].toUpperCase() + s.substring(1);
        }).join(' '),
        isVerified: true,
        createdAt: DateTime.now(),
      );

      await _saveUserSession(user, 'mock_token_${DateTime.now().millisecondsSinceEpoch}');
      return user;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(e.toString());
    }
  }

  // Register with email
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? country,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 1500));

      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        throw const AuthException('All fields are required');
      }

      final user = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: name,
        isVerified: false,
        createdAt: DateTime.now(),
      );

      await _saveUserSession(user, 'mock_token_${DateTime.now().millisecondsSinceEpoch}');
      return user;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(e.toString());
    }
  }

  // Google Sign In
  Future<UserModel> signInWithGoogle() async {
    try {
      await Future.delayed(const Duration(milliseconds: 1200));

      final user = UserModel(
        id: 'google_user_${DateTime.now().millisecondsSinceEpoch}',
        email: 'user@gmail.com',
        name: 'Google User',
        avatarUrl: 'https://lh3.googleusercontent.com/a/default-user',
        isVerified: true,
        createdAt: DateTime.now(),
      );

      await _saveUserSession(user, 'google_token_${DateTime.now().millisecondsSinceEpoch}');
      return user;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Google Sign In failed: ${e.toString()}');
    }
  }

  // Apple Sign In
  Future<UserModel> signInWithApple() async {
    try {
      await Future.delayed(const Duration(milliseconds: 1200));

      final user = UserModel(
        id: 'apple_user_${DateTime.now().millisecondsSinceEpoch}',
        email: 'user@icloud.com',
        name: 'Apple User',
        isVerified: true,
        createdAt: DateTime.now(),
      );

      await _saveUserSession(user, 'apple_token_${DateTime.now().millisecondsSinceEpoch}');
      return user;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Apple Sign In failed: ${e.toString()}');
    }
  }

  // Logout
  Future<void> logout() async {
    await _secureStorage.delete(key: AppConstants.keyAuthToken);
    await _secureStorage.delete(key: AppConstants.keyRefreshToken);
    await _secureStorage.delete(key: AppConstants.keyUserId);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyUserData);
  }

  // Forgot Password
  Future<void> forgotPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (email.isEmpty || !email.contains('@')) {
      throw const AuthException('Invalid email address');
    }
    // Simulate sending reset email
  }

  // Reset Password
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (newPassword.length < 8) {
      throw const AuthException('Password must be at least 8 characters');
    }
  }

  // Refresh Token
  Future<String?> refreshToken() async {
    try {
      final token = await _secureStorage.read(key: AppConstants.keyRefreshToken);
      if (token == null) return null;

      // Simulate token refresh
      await Future.delayed(const Duration(milliseconds: 500));
      final newToken = 'refreshed_token_${DateTime.now().millisecondsSinceEpoch}';
      await _secureStorage.write(key: AppConstants.keyAuthToken, value: newToken);
      return newToken;
    } catch (e) {
      return null;
    }
  }

  // Get current user from storage
  Future<UserModel?> getCurrentUser() async {
    try {
      final token = await _secureStorage.read(key: AppConstants.keyAuthToken);
      if (token == null) return null;

      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(AppConstants.keyUserData);
      if (userData == null) return null;

      final json = jsonDecode(userData) as Map<String, dynamic>;
      return UserModel.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.read(key: AppConstants.keyAuthToken);
    return token != null;
  }

  // Update user profile
  Future<UserModel> updateProfile({
    required String userId,
    String? name,
    String? avatarUrl,
    String? language,
    String? currency,
    String? theme,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      final currentUser = await getCurrentUser();
      if (currentUser == null) throw const AuthException('User not found');

      final updatedUser = currentUser.copyWith(
        name: name,
        avatarUrl: avatarUrl,
        language: language,
        currency: currency,
        theme: theme,
        updatedAt: DateTime.now(),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyUserData, jsonEncode(updatedUser.toJson()));
      return updatedUser;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(e.toString());
    }
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (newPassword.length < 8) {
      throw const AuthException('Password must be at least 8 characters');
    }
  }

  Future<void> _saveUserSession(UserModel user, String token) async {
    await _secureStorage.write(key: AppConstants.keyAuthToken, value: token);
    await _secureStorage.write(key: AppConstants.keyRefreshToken, value: '${token}_refresh');
    await _secureStorage.write(key: AppConstants.keyUserId, value: user.id);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserData, jsonEncode(user.toJson()));
  }
}
