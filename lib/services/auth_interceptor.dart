import 'dart:async';
import 'package:chopper/chopper.dart';
import 'package:flutter/foundation.dart';
import 'token_storage.dart';
import 'auth_service.dart';

/// Chopper Interceptor that injects the Bearer token into every request
/// and handles automatic token refresh on 401 responses.
class AuthInterceptor implements Interceptor {
  final TokenStorage _tokenStorage;
  final AuthService _authService;
  final VoidCallback _onAuthFailure;

  AuthInterceptor(this._tokenStorage, this._authService, this._onAuthFailure);

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) async {
    var request = chain.request;
    
    // Inject access token if available
    final accessToken = await _tokenStorage.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      request = applyHeader(request, 'Authorization', 'Bearer $accessToken');
    }

    // Proceed with the request
    final response = await chain.proceed(request);

    // Handle 401 Unauthorized
    if (response.statusCode == 401) {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          // Attempt to refresh the token
          final newTokens = await _authService.refresh(refreshToken);
          await _tokenStorage.saveTokens(
            newTokens.accessToken,
            newTokens.refreshToken,
          );
          
          // Retry original request with new token
          final newRequest = applyHeader(request, 'Authorization', 'Bearer ${newTokens.accessToken}');
          return chain.proceed(newRequest);
        } catch (e) {
          debugPrint('Token refresh failed: $e');
          await _tokenStorage.clearTokens();
          _onAuthFailure();
        }
      } else {
        _onAuthFailure();
      }
    }
    
    return response;
  }
}

