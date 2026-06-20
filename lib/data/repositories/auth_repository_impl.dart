import '../datasources/remote/auth_remote_datasource.dart';
import '../datasources/local/token_local_datasource.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  final TokenStorage _tokenStorage;

  AuthRepositoryImpl(this._authService, this._tokenStorage);

  @override
  Future<AuthTokenResponse> login(String email, String password) {
    return _authService.login(email, password);
  }

  @override
  Future<AuthTokenResponse> refresh(String refreshToken) {
    return _authService.refresh(refreshToken);
  }

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) {
    return _tokenStorage.saveTokens(accessToken, refreshToken);
  }

  @override
  Future<void> clearTokens() {
    return _tokenStorage.clearTokens();
  }

  @override
  Future<String?> getAccessToken() {
    return _tokenStorage.getAccessToken();
  }

  @override
  Future<String?> getRefreshToken() {
    return _tokenStorage.getRefreshToken();
  }
}
