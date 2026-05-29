import 'package:dio/dio.dart';
import '../core/config.dart';

class AuthTokenResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;

  AuthTokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory AuthTokenResponse.fromJson(Map<String, dynamic> json) {
    return AuthTokenResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String,
      expiresIn: json['expires_in'] as int,
    );
  }
}

class AuthService {
  final Dio _dio;
  final String baseUrl;

  AuthService({String? baseUrl})
      : baseUrl = baseUrl ?? AppConfig.apiBaseUrl,
        _dio = Dio(BaseOptions(
          baseUrl: baseUrl ?? AppConfig.apiBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
        ));

  Future<AuthTokenResponse> login(String email, String password) async {
    final response = await _dio.post('/api/auth/login', data: {
      'email': email,
      'password': password,
    });
    return AuthTokenResponse.fromJson(response.data);
  }

  Future<AuthTokenResponse> refresh(String refreshToken) async {
    final response = await _dio.post('/api/auth/refresh', data: {
      'refreshToken': refreshToken,
    });
    return AuthTokenResponse.fromJson(response.data);
  }
}
