// lib/src/auth/auth_service.dart
import '../core/interfaces/service_interface.dart';

abstract class AuthService extends ServiceInterface {
  Future<String> signIn(String email, String password);
  Future<String> signUp(String email, String password, Map<String, dynamic>? additionalData);
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<String?> getCurrentUserId();
  Future<bool> isAuthenticated();
  Future<String?> getAuthToken();
  Future<void> refreshToken();
}

