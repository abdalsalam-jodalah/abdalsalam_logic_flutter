// lib/src/app_initialization/app_initializer_impl.dart
import '../app_state/app_state_manager.dart';
import '../logging/logger_service.dart';
import '../storage/storage_service.dart';
import '../networking/api_client.dart';
import '../auth/auth_service.dart';
import '../fcm/fcm_service.dart';
import 'app_initializer.dart';

class AppInitializerImpl implements AppInitializer {
  final AppStateManager _appStateManager;
  final LoggerService _logger;
  final StorageService _storageService;
  final ApiClient _apiClient;
  final AuthService _authService;
  final FcmService _fcmService;

  AppInitializerImpl(
    this._appStateManager,
    this._logger,
    this._storageService,
    this._apiClient,
    this._authService,
    this._fcmService,
  );

  @override
  Future<void> initialize() async {
    try {
      _logger.info('Starting app initialization...');
      
      await _appStateManager.initialize();
      await initializeServices();
      await initializeStorage();
      await initializeNetworking();
      await initializeAuth();
      await initializeFCM();
      
      _logger.info('App initialization completed successfully');
    } catch (e) {
      _logger.error('App initialization failed', error: e);
      rethrow;
    }
  }

  @override
  Future<void> initializeServices() async {
    _logger.info('Initializing services...');
  }

  @override
  Future<void> initializeStorage() async {
    _logger.info('Initializing storage...');
    await _storageService.initialize();
  }

  @override
  Future<void> initializeNetworking() async {
    _logger.info('Initializing networking...');
    await _apiClient.initialize();
  }

  @override
  Future<void> initializeAuth() async {
    _logger.info('Initializing auth...');
    await _authService.initialize();
  }

  @override
  Future<void> initializeFCM() async {
    _logger.info('Initializing FCM...');
    await _fcmService.initialize();
  }

  @override
  Future<void> dispose() async {
    _logger.info('Disposing app initializer...');
    await _storageService.dispose();
    await _apiClient.dispose();
    await _authService.dispose();
    await _fcmService.dispose();
  }
}


