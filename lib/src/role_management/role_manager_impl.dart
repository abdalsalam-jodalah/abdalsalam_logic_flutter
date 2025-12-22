// lib/src/role_management/role_manager_impl.dart
import '../logging/logger_service.dart';
import '../storage/storage_service.dart';
import 'role_manager.dart';

class RoleManagerImpl implements RoleManager {
  final LoggerService _logger;
  final StorageService _storageService;

  RoleManagerImpl(
    this._logger,
    this._storageService,
  );

  @override
  Future<void> initialize() async {
    _logger.info('Role manager initialized');
  }

  @override
  Future<void> dispose() async {
    _logger.info('Role manager disposed');
  }

  @override
  Future<void> assignRole(String userId, String role) async {
    try {
      final roles = await getUserRoles(userId);
      if (!roles.contains(role)) {
        roles.add(role);
        await _storageService.set('user_roles_$userId', roles);
        _logger.info('Role $role assigned to user $userId');
      }
    } catch (e) {
      _logger.error('Failed to assign role', error: e);
      rethrow;
    }
  }

  @override
  Future<void> removeRole(String userId, String role) async {
    try {
      final roles = await getUserRoles(userId);
      roles.remove(role);
      await _storageService.set('user_roles_$userId', roles);
      _logger.info('Role $role removed from user $userId');
    } catch (e) {
      _logger.error('Failed to remove role', error: e);
      rethrow;
    }
  }

  @override
  Future<List<String>> getUserRoles(String userId) async {
    try {
      final roles = await _storageService.get<List<String>>('user_roles_$userId');
      return roles ?? [];
    } catch (e) {
      _logger.error('Failed to get user roles', error: e);
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

