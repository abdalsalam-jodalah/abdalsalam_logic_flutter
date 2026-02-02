// lib/src/networking/request_manager_impl.dart
import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import '../app_state/app_state_manager.dart';
import '../app_state/models/app_lifecycle_state.dart';
import '../core/errors/network_exception.dart';
import 'exceptions/networking_exceptions.dart';
import 'request_manager.dart';
import 'network_registry.dart';
import 'network_api.dart';
import 'auth_token_provider.dart';
import 'status_code_strategy.dart';
import 'models/network_response.dart';
import 'models/pending_request.dart';
import 'pending_request_storage.dart';

class RequestManagerImpl implements RequestManager {
  final NetworkRegistry _registry;
  final AppStateManager _appStateManager;
  final AuthTokenProvider? _authTokenProvider;
  final StatusCodeStrategy _statusCodeStrategy;
  final PendingRequestStorage _pendingRequestStorage;
  
  late Dio _dio;
  bool _isEnabled = true;
  bool _isInitialized = false;
  
  StreamSubscription<AppStateInfo>? _connectivitySubscription;
  final StreamController<int> _queueCountController = StreamController<int>.broadcast();
  
  RequestManagerImpl({
    required NetworkRegistry registry,
    required AppStateManager appStateManager,
    AuthTokenProvider? authTokenProvider,
    StatusCodeStrategy? statusCodeStrategy,
    PendingRequestStorage? pendingRequestStorage,
  })  : _registry = registry,
        _appStateManager = appStateManager,
        _authTokenProvider = authTokenProvider,
        _statusCodeStrategy = statusCodeStrategy ?? HttpStatusCodeStrategy(),
        _pendingRequestStorage = pendingRequestStorage ?? PendingRequestStorage() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio();
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.sendTimeout = const Duration(seconds: 30);
  }

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _pendingRequestStorage.initialize();
    
    _connectivitySubscription = _appStateManager.stateStream.listen(_onConnectivityChanged);
    
    _emitQueueCount();
    _isInitialized = true;
  }

  @override
  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    await _queueCountController.close();
    await _pendingRequestStorage.dispose();
    _dio.close();
    _isInitialized = false;
  }

  @override
  void enable() {
    _isEnabled = true;
  }

  @override
  void disable() {
    _isEnabled = false;
  }

  @override
  bool get isEnabled => _isEnabled;

  @override
  Stream<int> get queueCountStream => _queueCountController.stream;

  @override
  Future<NetworkResponse<TResponse>> execute<TRequest, TResponse>(
    NetworkApi<TRequest, TResponse> api,
  ) async {
    if (!_isEnabled) {
      throw NetworkManagerDisabledException(
        message: 'Request manager is disabled',
        code: 'MANAGER_DISABLED',
      );
    }

    final registeredApis = _registry.listApis();
    final isRegistered = registeredApis.any(
      (registeredApi) => registeredApi.apiTypeIdentifier == api.apiTypeIdentifier,
    );
    
    if (!isRegistered) {
      throw NetworkUnregisteredApiException(
        message: 'API ${api.apiTypeIdentifier} is not registered',
        code: 'UNREGISTERED_API',
      );
    }

    final isOnline = _appStateManager.currentState.isOnline;
    
    if (!isOnline) {
      return _handleOfflineRequest(api);
    }

    return _executeRequest(api);
  }

  Future<NetworkResponse<TResponse>> _handleOfflineRequest<TRequest, TResponse>(
    NetworkApi<TRequest, TResponse> api,
  ) async {
    if (api.queueFlag) {
      await _queueRequest(api);
      _emitQueueCount();
      return NetworkResponse<TResponse>.offline();
    } else {
      return NetworkResponse<TResponse>.offline();
    }
  }

  Future<void> _queueRequest<TRequest, TResponse>(
    NetworkApi<TRequest, TResponse> api,
  ) async {
    final pendingRequest = PendingRequest(
      id: _generateRequestId(),
      apiTypeIdentifier: api.apiTypeIdentifier,
      method: api.method,
      fullUrl: api.urlObject.fullUrl,
      requestBody: api.toRequestBody(),
      headers: api.getHeaders(),
      needAuth: api.needAuth,
      priority: api.priority,
      createdAt: DateTime.now(),
    );

    await _pendingRequestStorage.create(pendingRequest);
  }

  Future<NetworkResponse<TResponse>> _executeRequest<TRequest, TResponse>(
    NetworkApi<TRequest, TResponse> api,
  ) async {
    try {
      final options = Options(
        method: api.method.value,
        headers: api.getHeaders(),
      );

      if (api.needAuth && _authTokenProvider != null) {
        final token = await _authTokenProvider.getAccessToken();
        if (token != null) {
          options.headers ??= {};
          options.headers!['Authorization'] = 'Bearer $token';
        }
      }

      final response = await _dio.request(
        api.urlObject.fullUrl,
        options: options,
        data: api.toRequestBody(),
      );

      return _processResponse<TResponse>(response, api);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 && api.needAuth && _authTokenProvider != null) {
        return _handleAuthFailure(api, e);
      }
      throw _convertDioException(e);
    } catch (e) {
      throw NetworkException(
        message: 'Unexpected error: $e',
        code: 'UNEXPECTED_ERROR',
        originalException: e is Exception ? e : null,
      );
    }
  }

  Future<NetworkResponse<TResponse>> _handleAuthFailure<TRequest, TResponse>(
    NetworkApi<TRequest, TResponse> api,
    DioException originalError,
  ) async {
    final authProvider = _authTokenProvider;
    if (authProvider == null) {
      throw NetworkAuthFailedException(
        message: 'Authentication required but no auth provider configured',
        code: 'NO_AUTH_PROVIDER',
        originalException: originalError,
      );
    }
    
    try {
      final newToken = await authProvider.refreshToken();
      if (newToken != null) {
        return _executeRequest(api);
      } else {
        await authProvider.onAuthFailure();
        throw NetworkAuthFailedException(
          message: 'Authentication failed and token refresh unsuccessful',
          code: 'AUTH_REFRESH_FAILED',
          originalException: originalError,
        );
      }
    } catch (e) {
      await authProvider.onAuthFailure();
      throw NetworkAuthFailedException(
        message: 'Token refresh failed: $e',
        code: 'TOKEN_REFRESH_ERROR',
        originalException: e is Exception ? e : null,
      );
    }
  }

  NetworkResponse<TResponse> _processResponse<TResponse>(
    Response response,
    NetworkApi api,
  ) {
    final responseData = response.data as Map<String, dynamic>?;
    final httpStatus = response.statusCode;
    
    final isSuccess = _statusCodeStrategy.isSuccess(httpStatus, responseData);
    final internalStatus = _statusCodeStrategy.getInternalStatus(responseData);
    
    if (isSuccess) {
      final parsedModel = api.parseResponse(responseData ?? {});
      return NetworkResponse<TResponse>.success(
        data: parsedModel,
        httpStatus: httpStatus,
        internalStatus: internalStatus,
        rawResponse: responseData,
      );
    } else {
      final errorMessage = _statusCodeStrategy.getErrorMessage(httpStatus, responseData);
      return NetworkResponse<TResponse>.failure(
        error: errorMessage ?? 'Request failed',
        httpStatus: httpStatus,
        internalStatus: internalStatus,
        rawResponse: responseData,
      );
    }
  }

  NetworkException _convertDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkTimeoutException(
          message: 'Request timeout: ${error.message}',
          code: 'TIMEOUT',
          originalException: error,
        );
      case DioExceptionType.connectionError:
        return NetworkOfflineException(
          message: 'Connection error: ${error.message}',
          code: 'CONNECTION_ERROR',
          originalException: error,
        );
      case DioExceptionType.badResponse:
        return NetworkBackendException(
          message: 'Server error: ${error.response?.statusCode} ${error.response?.statusMessage}',
          code: error.response?.statusCode.toString() ?? 'SERVER_ERROR',
          originalException: error,
        );
      case DioExceptionType.cancel:
        return NetworkException(
          message: 'Request cancelled',
          code: 'CANCELLED',
          originalException: error,
        );
      default:
        return NetworkException(
          message: 'Network error: ${error.message}',
          code: 'NETWORK_ERROR',
          originalException: error,
        );
    }
  }

  @override
  Future<void> processQueue() async {
    if (!_appStateManager.currentState.isOnline) {
      return;
    }

    final pendingRequests = await _pendingRequestStorage.getAllSortedByPriority();
    
    for (final pendingRequest in pendingRequests) {
      try {
        await _processPendingRequest(pendingRequest);
        await _pendingRequestStorage.delete(pendingRequest.id);
      } catch (e) {
        final updatedRequest = pendingRequest.copyWith(
          retryCount: pendingRequest.retryCount + 1,
          lastRetryAt: DateTime.now(),
        );
        
        if (updatedRequest.retryCount >= 3) {
          await _pendingRequestStorage.delete(pendingRequest.id);
        } else {
          await _pendingRequestStorage.update(updatedRequest);
        }
      }
    }
    
    _emitQueueCount();
  }

  Future<void> _processPendingRequest(PendingRequest pendingRequest) async {
    final options = Options(
      method: pendingRequest.method.value,
      headers: pendingRequest.headers,
    );

    if (pendingRequest.needAuth && _authTokenProvider != null) {
      final token = await _authTokenProvider.getAccessToken();
      if (token != null) {
        options.headers ??= {};
        options.headers!['Authorization'] = 'Bearer $token';
      }
    }

    await _dio.request(
      pendingRequest.fullUrl,
      options: options,
      data: pendingRequest.requestBody,
    );
  }

  @override
  Future<int> getPendingCount() async {
    return await _pendingRequestStorage.getCount();
  }

  @override
  Future<void> clearQueue() async {
    await _pendingRequestStorage.clear();
    _emitQueueCount();
  }

  void _onConnectivityChanged(AppStateInfo state) {
    if (state.isOnline) {
      processQueue().catchError((e) {
        // Ignore queue processing errors in background
      });
    }
  }

  void _emitQueueCount() {
    _emitQueueCountAsync().catchError((e) {
      // Ignore errors when emitting count
    });
  }

  Future<void> _emitQueueCountAsync() async {
    try {
      final count = await getPendingCount();
      if (!_queueCountController.isClosed) {
        _queueCountController.add(count);
      }
    } catch (e) {
      // Ignore errors when emitting count
    }
  }

  String _generateRequestId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999999)}';
  }
}