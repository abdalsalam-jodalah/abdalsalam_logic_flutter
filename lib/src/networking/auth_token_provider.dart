// lib/src/networking/auth_token_provider.dart
abstract class AuthTokenProvider {
  Future<String?> getAccessToken();
  
  Future<String?> refreshToken();
  
  Future<void> onAuthFailure();
}