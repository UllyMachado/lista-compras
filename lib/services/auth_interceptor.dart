import 'dart:async';
import 'package:chopper/chopper.dart';
import 'package:flutter/foundation.dart';
import 'token_storage.dart';
import 'auth_service.dart';
import '../core/globals.dart';

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
    
    // CRITICAL PATH: Retrieve the access token from secure storage.
    // If it exists, append it as a 'Bearer' authorization header to the outbound request.
    final accessToken = await _tokenStorage.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      request = applyHeader(request, 'Authorization', 'Bearer $accessToken');
    }


    // Proceed with the request
    final response = await chain.proceed(request);

    // SILENT REFRESH MECHANISM: If the server returns a 401 Unauthorized status,
    // the current access token has likely expired. We attempt to refresh it.
    if (response.statusCode == 401) {
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
          
          // 3. Clone and modify the failed request, injecting the brand new Access Token.
          final newRequest = applyHeader(request, 'Authorization', 'Bearer ${newTokens.accessToken}');
          
          // 4. Retry the request. The user won't notice any disruption.
          return chain.proceed(newRequest);
        } catch (e) {
          // If refresh token has also expired/invalidated, clean storage and force logout.
          debugPrint('Token refresh failed: $e');
          await _tokenStorage.clearTokens();
          showErrorSnackBar('Sessão expirada. Por favor, faça login novamente.');
          _onAuthFailure();
        }
      } else {
        // No refresh token available, force logout.
        _onAuthFailure();
      }
    }
    
    return response;
  }
}

