import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../data/datasources/local/token_local_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../globals.dart';

/// Dio Interceptor that injects the Bearer token into every request
/// and handles automatic token refresh on 401 responses.
class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  final AuthService _authService;
  final VoidCallback _onAuthFailure;
  final Dio _dio;

  AuthInterceptor(this._tokenStorage, this._authService, this._onAuthFailure, this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final accessToken = await _tokenStorage.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          // 1. Send refresh request to the authentication controller.
          final newTokens = await _authService.refresh(refreshToken);
          
          // 2. Persist the newly acquired Access and Refresh tokens back to Secure Storage.
          await _tokenStorage.saveTokens(
            newTokens.accessToken,
            newTokens.refreshToken,
          );
          
          // 3. Retry the request. The user won't notice any disruption.
          final requestOptions = err.requestOptions;
          requestOptions.headers['Authorization'] = 'Bearer ${newTokens.accessToken}';
          
          final response = await _dio.fetch(requestOptions);
          return handler.resolve(response);
        } catch (e) {
          // If refresh token has also expired/invalidated, clean storage and force logout.
          debugPrint('Token refresh failed: $e');
          await _tokenStorage.clearTokens();
          showErrorSnackBar('Sessão expirada. Por favor, faça login novamente.');
          _onAuthFailure();
          return handler.next(err);
        }
      } else {
        // No refresh token available, force logout.
        _onAuthFailure();
        return handler.next(err);
      }
    }
    
    return handler.next(err);
  }
}
