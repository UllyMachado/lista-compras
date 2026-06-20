import '../../data/datasources/remote/auth_remote_datasource.dart'; // Using AuthTokenResponse

abstract class AuthRepository {
  Future<AuthTokenResponse> login(String email, String password);
  Future<AuthTokenResponse> refresh(String refreshToken);
  
  Future<void> saveTokens(String accessToken, String refreshToken);
  Future<void> clearTokens();
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
}
