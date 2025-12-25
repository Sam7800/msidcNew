import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/constants.dart';

/// Authentication State
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final String? username;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.username,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    String? username,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      username: username ?? this.username,
    );
  }
}

/// Authentication Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _checkAuthStatus();
  }

  /// Check if user is already logged in
  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(Constants.prefKeyIsLoggedIn) ?? false;
      final username = prefs.getString(Constants.prefKeyUsername);

      if (isLoggedIn && username != null) {
        state = state.copyWith(
          isAuthenticated: true,
          username: username,
        );
      }
    } catch (e) {
      // Ignore errors on startup
    }
  }

  /// Login
  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Simple authentication check
    if (username == Constants.defaultUsername &&
        password == Constants.defaultPassword) {
      try {
        // Save login state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(Constants.prefKeyIsLoggedIn, true);
        await prefs.setString(Constants.prefKeyUsername, username);
        await prefs.setString(
          Constants.prefKeyLastLogin,
          DateTime.now().toIso8601String(),
        );

        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          username: username,
        );

        return true;
      } catch (e) {
        state = state.copyWith(
          error: 'Failed to save login state: $e',
          isLoading: false,
        );
        return false;
      }
    } else {
      state = state.copyWith(
        error: Constants.errorInvalidCredentials,
        isLoading: false,
      );
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(Constants.prefKeyIsLoggedIn, false);
      await prefs.remove(Constants.prefKeyUsername);

      state = const AuthState();
    } catch (e) {
      state = state.copyWith(error: 'Failed to logout: $e');
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
