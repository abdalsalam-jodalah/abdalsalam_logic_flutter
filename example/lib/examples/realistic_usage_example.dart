// lib/examples/realistic_usage_example.dart

import 'dart:async';
import 'dart:io';
import 'package:abdalsalam_logic_flutter/src/core/errors/app_exception.dart';
import 'package:abdalsalam_logic_flutter/src/core/errors/app_error_response.dart';
import 'package:abdalsalam_logic_flutter/src/core/errors/exception_mapper.dart';
import 'package:abdalsalam_logic_flutter/src/core/errors/network_exception.dart';
import 'package:abdalsalam_logic_flutter/src/core/errors/auth_exception.dart';
import 'package:abdalsalam_logic_flutter/src/core/errors/storage_exception.dart';
import 'package:abdalsalam_logic_flutter/src/core/errors/validation_exception.dart';
import 'package:abdalsalam_logic_flutter/src/core/errors/backend_exception.dart';
import 'package:abdalsalam_logic_flutter/src/core/errors/error_handler_impl.dart';

class UserService {
  final _errorHandler = ErrorHandlerImpl();

  Future<UserProfile> getUserProfile(String userId) async {
    try {
      // Validate input
      if (userId.isEmpty) {
        throw ValidationException(
          message: 'User ID cannot be empty',
          code: 'VALIDATION_EMPTY_USER_ID',
        );
      }

      // Simulate network call
      final userData = await _makeNetworkRequest('/users/$userId');
      
      // Simulate storage operation
      await _cacheUserData(userId, userData);
      
      return UserProfile.fromJson(userData);
      
    } on AppException {
      // Re-throw known app exceptions
      rethrow;
    } catch (e, stackTrace) {
      // Map unknown errors to AppException
      final appException = ExceptionMapper.mapException(e, stackTrace);
      throw appException;
    }
  }

  Future<void> updateUserProfile(String userId, UserProfile profile) async {
    try {
      // Validate profile data
      _validateProfile(profile);
      
      // Save to storage first
      await _saveUserProfile(userId, profile);
      
      // Then sync to server
      await _syncToServer(userId, profile);
      
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      final appException = ExceptionMapper.mapException(e, stackTrace);
      throw appException;
    }
  }

  void _validateProfile(UserProfile profile) {
    final errors = <String, String>{};
    
    if (profile.email.isEmpty || !profile.email.contains('@')) {
      errors['email'] = 'Invalid email address';
    }
    
    if (profile.name.isEmpty || profile.name.length < 2) {
      errors['name'] = 'Name must be at least 2 characters';
    }
    
    if (errors.isNotEmpty) {
      throw ValidationException(
        message: 'Profile validation failed',
        code: 'VALIDATION_PROFILE_INVALID',
        fieldErrors: errors,
      );
    }
  }

  Future<Map<String, dynamic>> _makeNetworkRequest(String endpoint) async {
    // Simulate various network failures
    await Future.delayed(Duration(milliseconds: 100));
    
    switch (endpoint) {
      case '/users/timeout':
        throw SocketException('Connection timed out');
      case '/users/offline':
        throw SocketException('Network is unreachable');
      case '/users/unauthorized':
        throw Exception('DioException: 401 Unauthorized');
      case '/users/server_error':
        throw Exception('DioException: 500 Internal Server Error');
      default:
        return {
          'id': '123',
          'name': 'John Doe',
          'email': 'john.doe@example.com',
          'avatar': 'https://example.com/avatar.jpg',
        };
    }
  }

  Future<void> _cacheUserData(String userId, Map<String, dynamic> userData) async {
    // Simulate storage operation
    await Future.delayed(Duration(milliseconds: 50));
    
    if (userId == 'storage_error') {
      throw FileSystemException('Disk full');
    }
  }

  Future<void> _saveUserProfile(String userId, UserProfile profile) async {
    // Simulate storage operation
    await Future.delayed(Duration(milliseconds: 50));
    
    if (userId == 'read_only') {
      throw StorageException(
        message: 'Storage is in read-only mode',
        code: 'STORAGE_READ_ONLY',
        isRecoverable: false,
      );
    }
  }

  Future<void> _syncToServer(String userId, UserProfile profile) async {
    // Simulate server sync
    await Future.delayed(Duration(milliseconds: 100));
    
    if (userId == 'sync_conflict') {
      throw BackendException(
        message: 'Profile has been updated by another client',
        code: 'BACKEND_SYNC_CONFLICT',
        statusCode: 409,
        isRecoverable: true,
        responseData: {
          'conflict_type': 'concurrent_update',
          'server_version': 5,
          'client_version': 3,
        },
      );
    }
  }
}

class UserController {
  final _userService = UserService();
  final _errorHandler = ErrorHandlerImpl();

  Future<void> handleGetUserProfile(String userId) async {
    try {
      final profile = await _userService.getUserProfile(userId);
      _showUserProfile(profile);
      
    } on ValidationException catch (e) {
      final response = _errorHandler.createErrorResponse(e);
      _showValidationError(response, e.fieldErrors);
      
    } on TimeoutException catch (e) {
      final response = _errorHandler.createErrorResponse(e);
      if (response.isRecoverable) {
        _showRetryDialog('Request timed out', () => handleGetUserProfile(userId));
      }
      
    } on OfflineException catch (e) {
      final response = _errorHandler.createErrorResponse(e);
      _showOfflineMessage(response.safeMessage);
      
    } on TokenExpiredException catch (e) {
      final response = _errorHandler.createErrorResponse(e);
      _showLoginPrompt(response.safeMessage);
      
    } on AppException catch (e) {
      final response = _errorHandler.createErrorResponse(e);
      _handleGenericError(response);
      
    } catch (e, stackTrace) {
      // This should never happen if services properly wrap exceptions
      final appException = ExceptionMapper.mapException(e, stackTrace);
      final response = _errorHandler.createErrorResponse(appException);
      _handleGenericError(response);
    }
  }

  Future<void> handleUpdateUserProfile(String userId, UserProfile profile) async {
    try {
      await _userService.updateUserProfile(userId, profile);
      _showSuccessMessage('Profile updated successfully');
      
    } on ValidationException catch (e) {
      final response = _errorHandler.createErrorResponse(e);
      _showValidationError(response, e.fieldErrors);
      
    } on StorageException catch (e) {
      final response = _errorHandler.createErrorResponse(e);
      if (response.isRecoverable) {
        _showRetryDialog('Failed to save profile', () => handleUpdateUserProfile(userId, profile));
      } else {
        _showError('Cannot save profile: ${response.safeMessage}');
      }
      
    } on BackendException catch (e) {
      final response = _errorHandler.createErrorResponse(e);
      if (e.statusCode == 409 && response.isRecoverable) {
        _showSyncConflictDialog(e.responseData);
      } else {
        _showError('Server error: ${response.safeMessage}');
      }
      
    } on AppException catch (e) {
      final response = _errorHandler.createErrorResponse(e);
      _handleGenericError(response);
    }
  }

  void _showUserProfile(UserProfile profile) {
    print('User Profile: ${profile.name} (${profile.email})');
  }

  void _showValidationError(AppErrorResponse response, Map<String, String>? fieldErrors) {
    print('Validation Error: ${response.safeMessage}');
    if (fieldErrors != null) {
      fieldErrors.forEach((field, error) {
        print('  $field: $error');
      });
    }
  }

  void _showRetryDialog(String message, VoidCallback onRetry) {
    print('Retry Dialog: $message');
    print('User can retry the operation');
  }

  void _showOfflineMessage(String message) {
    print('Offline: $message - showing cached data');
  }

  void _showLoginPrompt(String message) {
    print('Auth Required: $message - redirecting to login');
  }

  void _showSyncConflictDialog(Map<String, dynamic>? conflictData) {
    print('Sync Conflict: Profile has been updated by another device');
    if (conflictData != null) {
      print('Conflict details: $conflictData');
    }
  }

  void _handleGenericError(AppErrorResponse response) {
    switch (response.severity) {
      case AppExceptionSeverity.info:
        print('Info: ${response.safeMessage}');
        break;
      case AppExceptionSeverity.warning:
        print('Warning: ${response.safeMessage}');
        break;
      case AppExceptionSeverity.error:
        _showError('Error: ${response.safeMessage}');
        break;
      case AppExceptionSeverity.critical:
        _showCriticalError('Critical Error: ${response.safeMessage}');
        break;
    }
  }

  void _showSuccessMessage(String message) {
    print('Success: $message');
  }

  void _showError(String message) {
    print('Error: $message');
  }

  void _showCriticalError(String message) {
    print('CRITICAL ERROR: $message - app may need to be restarted');
  }
}

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String avatar;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
    };
  }
}

typedef VoidCallback = void Function();

void main() async {
  final controller = UserController();

  print('=== Testing Various Error Scenarios ===\\n');

  // Test normal flow
  await controller.handleGetUserProfile('normal_user');
  print('');

  // Test validation error
  await controller.handleGetUserProfile('');
  print('');

  // Test timeout
  await controller.handleGetUserProfile('timeout');
  print('');

  // Test offline
  await controller.handleGetUserProfile('offline');
  print('');

  // Test unauthorized
  await controller.handleGetUserProfile('unauthorized');
  print('');

  // Test server error
  await controller.handleGetUserProfile('server_error');
  print('');

  // Test storage error
  await controller.handleGetUserProfile('storage_error');
  print('');

  // Test profile update with validation error
  final invalidProfile = UserProfile(id: '1', name: '', email: 'invalid', avatar: '');
  await controller.handleUpdateUserProfile('user1', invalidProfile);
  print('');

  // Test profile update with sync conflict
  final validProfile = UserProfile(id: '1', name: 'John', email: 'john@example.com', avatar: '');
  await controller.handleUpdateUserProfile('sync_conflict', validProfile);
}