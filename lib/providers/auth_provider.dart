import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/token_storage.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final TokenStorage _tokenStorage;
  bool _isAuthenticated = false;

  AuthProvider(this._authService, this._tokenStorage);

  bool get isAuthenticated => _isAuthenticated;

  /// Attempts auto-login using stored refresh token.
  /// Called once at app startup before rendering.
  Future<void> tryAutoLogin() async {
    final hasTokens = await _tokenStorage.hasTokens();
    if (!hasTokens) {
      _isAuthenticated = false;
      notifyListeners();
      return;
    }

    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null) {
      _isAuthenticated = false;
      notifyListeners();
      return;
    }

    try {
      final response = await _authService.refresh(refreshToken);
      await _tokenStorage.saveTokens(
        response.accessToken,
        response.refreshToken,
      );
      _isAuthenticated = true;
    } catch (e) {
      debugPrint('Auto-login failed: $e');
      await _tokenStorage.clearTokens();
      _isAuthenticated = false;
    }
    notifyListeners();
  }

  /// Authenticates via the REST API and stores tokens.
  Future<bool> login(String email, String password) async {
    try {
      final response = await _authService.login(email, password);
      await _tokenStorage.saveTokens(
        response.accessToken,
        response.refreshToken,
      );
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Login failed: $e');
      return false;
    }
  }

  /// Clears all tokens and ends the session.
  Future<void> logout() async {
    await _tokenStorage.clearTokens();
    _isAuthenticated = false;
    notifyListeners();
  }
}
