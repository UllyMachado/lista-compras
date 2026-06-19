import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/token_storage.dart';
import '../core/globals.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final TokenStorage _tokenStorage;
  bool _isAuthenticated = false;

  AuthProvider(this._authService, this._tokenStorage);

  bool get isAuthenticated => _isAuthenticated;

  /// AUTO-LOGIN ROUTINE: Evaluates if the user has a valid active session.
  /// This is called during the application startup process before routing takes place.
  Future<void> tryAutoLogin() async {
    // 1. Verify if refresh tokens exist in the secure storage.
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
      // 2. Validate the refresh token with the server by requesting a fresh access token.
      final response = await _authService.refresh(refreshToken);
      
      // 3. Save the new set of JWT keys to maintain session longevity.
      await _tokenStorage.saveTokens(
        response.accessToken,
        response.refreshToken,
      );
      _isAuthenticated = true;
    } catch (e) {
      // 4. If refresh token is expired/invalid, clear local secure storage.
      debugPrint('Auto-login failed: $e');
      await _tokenStorage.clearTokens();
      _isAuthenticated = false;
    }
    
    // Notify router configuration of the auth state update to route to Dashboard or Login.
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
      _isAuthenticated = false;
      showErrorSnackBar('Credenciais inválidas ou falha de rede.');
      notifyListeners();
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
