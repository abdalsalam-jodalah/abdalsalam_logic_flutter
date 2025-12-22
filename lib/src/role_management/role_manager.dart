// lib/src/role_management/role_manager.dart
import '../core/interfaces/service_interface.dart';

abstract class RoleManager extends ServiceInterface {
  Future<void> assignRole(String userId, String role);
  Future<void> removeRole(String userId, String role);
  Future<List<String>> getUserRoles(String userId);
  Future<bool> hasRole(String userId, String role);
  Future<bool> hasAnyRole(String userId, List<String> roles);
  Future<bool> hasAllRoles(String userId, List<String> roles);
}

