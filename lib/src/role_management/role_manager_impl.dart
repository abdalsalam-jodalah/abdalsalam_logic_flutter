// lib/src/role_management/role_manager_impl.dart
import '../storage/storage_service.dart';
import 'role_manager.dart';

class RoleManagerImpl implements RoleManager {
  final StorageService _storageService;

  RoleManagerImpl(this._storageService);

  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> assignRole(String userId, String role) async {
    try {
      final roles = await getUserRoles(userId);
      if (!roles.contains(role)) {
        roles.add(role);
        await _storageService.set('user_roles_$userId', roles);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> removeRole(String userId, String role) async {
    try {
      final roles = await getUserRoles(userId);
      roles.remove(role);
      await _storageService.set('user_roles_$userId', roles);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<String>> getUserRoles(String userId) async {
    try {
      final roles = await _storageService.get<List<String>>('user_roles_$userId');
      return roles ?? [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> hasRole(String userId, String role) async {
    final roles = await getUserRoles(userId);
    return roles.contains(role);
  }

  @override
  Future<bool> hasAnyRole(String userId, List<String> roles) async {
    final userRoles = await getUserRoles(userId);
    return roles.any((role) => userRoles.contains(role));
  }

  @override
  Future<bool> hasAllRoles(String userId, List<String> roles) async {
    final userRoles = await getUserRoles(userId);
    return roles.every((role) => userRoles.contains(role));
  }
}

