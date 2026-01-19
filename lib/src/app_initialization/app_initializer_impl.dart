// lib/src/app_initialization/app_initializer_impl.dart
import '../app_state/app_state_manager.dart';
import '../storage/storage_service.dart';
import '../networking/api_client.dart';
import '../auth/auth_service.dart';
import '../fcm/fcm_service.dart';
import 'app_initializer.dart';

class AppInitializerImpl implements AppInitializer {
  final AppStateManager _appStateManager;
  final StorageService _storageService;
  final ApiClient _apiClient;
  final AuthService _authService;
  final FcmService _fcmService;

  AppInitializerImpl(
    this._appStateManager,
    this._storageService,
    this._apiClient,
    this._authService,
    this._fcmService,
  );

  @override
  Future<void> initialize() async {
    try {
      await _appStateManager.initialize();
    } catch (e) {
      throw Exception('Failed to initialize app state manager: $e');
    }

    try {
      await initializeServices();
    } catch (e) {
      throw Exception('Failed to initialize services: $e');
    }

    try {
      await initializeStorage();
    } catch (e) {
      throw Exception('Failed to initialize storage: $e');
    }

    try {
      await initializeNetworking();
    } catch (e) {
      throw Exception('Failed to initialize networking: $e');
    }

    try {
      await initializeAuth();
    } catch (e) {
      throw Exception('Failed to initialize authentication: $e');
    }

    try {
      await initializeFCM();
    } catch (e) {
      throw Exception('Failed to initialize FCM: $e');
    }
  }

  @override
  Future<void> initializeServices() async {}

  @override
  Future<void> initializeStorage() async {
    try {
      await _storageService.initialize();
    } catch (e) {
      throw Exception('Storage service initialization failed: $e');
    }
  }

  @override
  Future<void> initializeNetworking() async {
    try {
      await _apiClient.initialize();
    } catch (e) {
      throw Exception('API client initialization failed: $e');
    }
  }

  @override
  Future<void> initializeAuth() async {
    try {
      await _authService.initialize();
    } catch (e) {
      throw Exception('Authentication service initialization failed: $e');
    }
  }

  @override
  Future<void> initializeFCM() async {
    try {
      await _fcmService.initialize();
    } catch (e) {
      throw Exception('FCM service initialization failed: $e');
    }
  }

  @override
  Future<void> dispose() async {
    await _storageService.dispose();
    await _apiClient.dispose();
    await _authService.dispose();
    await _fcmService.dispose();
  }
}


