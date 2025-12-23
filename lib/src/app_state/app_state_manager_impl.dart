// lib/src/app_state/app_state_manager_impl.dart
import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui' show AppExitResponse;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'app_state_manager.dart';
import 'models/app_lifecycle_state.dart' as lifecycle;
import 'models/device_info.dart' as models;
import 'models/navigation_state.dart';
import 'models/locale_info.dart';
import 'models/auth_info.dart';
import '../logging/logger_service.dart';

/// Implementation of [AppStateManager] with singleton pattern.
///
/// This implementation:
/// - Tracks app lifecycle via [WidgetsBindingObserver]
/// - Monitors connectivity changes automatically
/// - Updates device info on orientation/size changes
/// - Provides reactive streams for all state domains
/// - Uses singleton pattern to ensure single instance
///
/// **Initialization:**
/// ```dart
/// final logger = LoggerServiceImpl();
/// final appStateManager = AppStateManagerImpl.create(logger);
/// await appStateManager.initialize();
/// ```
///
/// **Usage:**
/// ```dart
/// // Listen to state changes
/// appStateManager.stateStream.listen((state) {
///   if (state.isOnline && state.isForeground) {
///     // Sync data
///   }
/// });
///
/// // Get current device info
/// final device = appStateManager.deviceInfo;
/// if (device?.isTablet == true) {
///   // Use tablet layout
/// }
///
/// // Update authentication
/// await appStateManager.setAuthenticated(
///   true,
///   userId: 'user123',
///   userEmail: 'user@example.com',
/// );
/// ```
class AppStateManagerImpl implements AppStateManager, WidgetsBindingObserver {
  static AppStateManagerImpl? _instance;
  final LoggerService _logger;
  final Connectivity _connectivity = Connectivity();

  lifecycle.AppStateInfo _currentState = lifecycle.AppStateInfo(
    lifecycle: lifecycle.AppLifecycleState.appStart,
    focus: lifecycle.AppFocusState.foreground,
    connectivity: lifecycle.ConnectivityState.offline,
    timestamp: DateTime.now(),
  );

  models.DeviceInfo? _deviceInfo;
  NavigationState _navigationState = NavigationState(
    currentRoute: '/',
    routeParams: {},
    routeHistory: ['/'],
    currentTabIndex: 0,
    tabRoutes: {0: '/'},
    timestamp: DateTime.now(),
  );

  ThemeMode _themeMode = ThemeMode.system;
  LocaleInfo _localeInfo = LocaleInfo.fromLocale(null);
  AuthInfo _authInfo = AuthInfo();

  final StreamController<lifecycle.AppStateInfo> _stateController =
      StreamController<lifecycle.AppStateInfo>.broadcast();
  final StreamController<models.DeviceInfo> _deviceController =
      StreamController<models.DeviceInfo>.broadcast();
  final StreamController<NavigationState> _navController =
      StreamController<NavigationState>.broadcast();
  final StreamController<ThemeMode> _themeController =
      StreamController<ThemeMode>.broadcast();
  final StreamController<LocaleInfo> _localeController =
      StreamController<LocaleInfo>.broadcast();
  final StreamController<AuthInfo> _authController =
      StreamController<AuthInfo>.broadcast();

  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isInitialized = false;

  AppStateManagerImpl._internal(this._logger);

  /// Creates or returns the singleton instance of [AppStateManagerImpl].
  ///
  /// [logger] is required for logging state changes and errors.
  ///
  /// Example:
  /// ```dart
  /// final appStateManager = AppStateManagerImpl.create(logger);
  /// ```
  factory AppStateManagerImpl.create(LoggerService logger) {
    _instance ??= AppStateManagerImpl._internal(logger);
    return _instance!;
  }

  @override
  lifecycle.AppStateInfo get currentState => _currentState;

  @override
  models.DeviceInfo? get deviceInfo => _deviceInfo;

  @override
  NavigationState get navigationState => _navigationState;

  @override
  ThemeMode get themeMode => _themeMode;

  @override
  LocaleInfo get localeInfo => _localeInfo;

  @override
  AuthInfo get authInfo => _authInfo;

  @override
  Stream<lifecycle.AppStateInfo> get stateStream => _stateController.stream;

  @override
  Stream<models.DeviceInfo> get deviceStream => _deviceController.stream;

  @override
  Stream<NavigationState> get navigationStream => _navController.stream;

  @override
  Stream<ThemeMode> get themeStream => _themeController.stream;

  @override
  Stream<LocaleInfo> get localeStream => _localeController.stream;

  @override
  Stream<AuthInfo> get authStream => _authController.stream;

  /// Initializes the app state manager.
  ///
  /// This method:
  /// - Registers as a [WidgetsBindingObserver] to track app lifecycle
  /// - Initializes device information (type, OS, screen metrics)
  /// - Starts connectivity monitoring
  /// - Initializes locale information
  /// - Transitions to [AppLifecycleState.appInit]
  ///
  /// Should be called once during app startup, typically in your app's
  /// initialization sequence.
  ///
  /// Example:
  /// ```dart
  /// final appStateManager = AppStateManagerImpl.create(logger);
  /// await appStateManager.initialize();
  /// ```
  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      _logger.warning('AppStateManager already initialized');
      return;
    }

    _logger.info('Initializing AppStateManager');

    try {
      WidgetsBinding.instance.addObserver(this);

      await _initializeDeviceInfo();
      await _initializeConnectivity();
      await _initializeLocale();

      _updateState(lifecycle.AppLifecycleState.appInit);

      _isInitialized = true;
      _logger.info('AppStateManager initialized successfully');
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to initialize AppStateManager',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    if (!_isInitialized) return;

    _logger.info('Disposing AppStateManager');

    WidgetsBinding.instance.removeObserver(this);
    await _connectivitySubscription?.cancel();

    await _stateController.close();
    await _deviceController.close();
    await _navController.close();
    await _themeController.close();
    await _localeController.close();
    await _authController.close();

    _isInitialized = false;
    _logger.info('AppStateManager disposed');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState flutterState) {
    switch (flutterState) {
      case AppLifecycleState.resumed:
        _updateFocus(lifecycle.AppFocusState.foreground);
        _handleAppResume();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _updateFocus(lifecycle.AppFocusState.background);
        break;
      case AppLifecycleState.detached:
        _updateState(lifecycle.AppLifecycleState.appKill);
        break;
      case AppLifecycleState.hidden:
        _updateFocus(lifecycle.AppFocusState.background);
        break;
    }
  }

  @override
  void didChangeAccessibilityFeatures() {}

  @override
  void didChangeLocales(List<Locale>? locales) {}

  @override
  void didChangeMetrics() {
    _updateDeviceInfoOnMetricsChange();
  }

  @override
  void didChangePlatformBrightness() {}

  @override
  void didChangeTextScaleFactor() {
    _updateDeviceInfoOnMetricsChange();
  }

  @override
  void didHaveMemoryPressure() {}

  @override
  Future<bool> didPopRoute() async => false;

  @override
  Future<bool> didPushRoute(String route) async => false;

  @override
  Future<bool> didPushRouteInformation(
    RouteInformation routeInformation,
  ) async => false;

  @override
  void didChangeViewFocus(dynamic event) {}

  @override
  Future<AppExitResponse> didRequestAppExit() async => AppExitResponse.exit;

  @override
  bool handleStartBackGesture(dynamic event) => false;

  @override
  void handleCommitBackGesture() {}

  @override
  void handleCancelBackGesture() {}

  @override
  void handleUpdateBackGestureProgress(dynamic event) {}

  Future<void> _initializeDeviceInfo() async {
    try {
      final deviceInfoPlugin = DeviceInfoPlugin();

      models.DeviceOS os;
      String? osVersion;
      String? deviceModel;
      String? deviceManufacturer;

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        os = models.DeviceOS.android;
        osVersion = androidInfo.version.release;
        deviceModel = androidInfo.model;
        deviceManufacturer = androidInfo.manufacturer;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        os = models.DeviceOS.ios;
        osVersion = iosInfo.systemVersion;
        deviceModel = iosInfo.model;
        deviceManufacturer = 'Apple';
      } else if (Platform.isWindows) {
        os = models.DeviceOS.windows;
        final windowsInfo = await deviceInfoPlugin.windowsInfo;
        osVersion = windowsInfo.displayVersion;
      } else if (Platform.isMacOS) {
        os = models.DeviceOS.macos;
        final macInfo = await deviceInfoPlugin.macOsInfo;
        osVersion = macInfo.osRelease;
      } else if (Platform.isLinux) {
        os = models.DeviceOS.linux;
        final linuxInfo = await deviceInfoPlugin.linuxInfo;
        osVersion = linuxInfo.prettyName;
      } else {
        os = models.DeviceOS.unknown;
      }

      final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
      final mediaQuery = platformDispatcher.views.first;
      final size = mediaQuery.physicalSize / mediaQuery.devicePixelRatio;

      final orientation = size.width > size.height
          ? Orientation.landscape
          : Orientation.portrait;
      final breakpoint = _determineBreakpoint(size);
      final statusBarHeight =
          mediaQuery.padding.top / mediaQuery.devicePixelRatio;
      final navigationBarHeight =
          mediaQuery.padding.bottom / mediaQuery.devicePixelRatio;
      final hasSystemNavigation = mediaQuery.systemGestureInsets.bottom > 0;
      final hasNotch =
          statusBarHeight > 24 || (Platform.isIOS && statusBarHeight > 20);

      final deviceType = _determineDeviceType(size, os);

      _deviceInfo = models.DeviceInfo(
        type: deviceType,
        os: os,
        osVersion: osVersion,
        deviceModel: deviceModel,
        deviceManufacturer: deviceManufacturer,
        screenSize: size,
        pixelRatio: mediaQuery.devicePixelRatio,
        textScaleFactor: platformDispatcher.textScaleFactor,
        orientation: orientation,
        breakpoint: breakpoint,
        isLandscapeFirst: size.width > size.height,
        systemNavigationInsets: EdgeInsets.fromViewPadding(
          mediaQuery.systemGestureInsets,
          mediaQuery.devicePixelRatio,
        ),
        systemPadding: EdgeInsets.fromViewPadding(
          mediaQuery.padding,
          mediaQuery.devicePixelRatio,
        ),
        hasSystemNavigation: hasSystemNavigation,
        hasNotch: hasNotch,
        hasPhysicalHomeButton: !hasSystemNavigation && Platform.isAndroid,
        statusBarHeight: statusBarHeight,
        navigationBarHeight: navigationBarHeight,
        timestamp: DateTime.now(),
      );

      _deviceController.add(_deviceInfo!);
      _logger.info('Device info initialized: ${deviceType.name} on ${os.name}');
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to initialize device info',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  models.DeviceType _determineDeviceType(Size screenSize, models.DeviceOS os) {
    if (kIsWeb) return models.DeviceType.web;

    final width = screenSize.width;
    final height = screenSize.height;

    if (os == models.DeviceOS.windows ||
        os == models.DeviceOS.macos ||
        os == models.DeviceOS.linux) {
      return models.DeviceType.desktop;
    }

    if (width >= 600 || height >= 600) {
      return models.DeviceType.tablet;
    }

    return models.DeviceType.phone;
  }

  models.ResponsiveBreakpoint _determineBreakpoint(Size screenSize) {
    final width = screenSize.width;

    if (width < 576) return models.ResponsiveBreakpoint.xs;
    if (width < 768) return models.ResponsiveBreakpoint.sm;
    if (width < 992) return models.ResponsiveBreakpoint.md;
    if (width < 1200) return models.ResponsiveBreakpoint.lg;
    return models.ResponsiveBreakpoint.xl;
  }

  void _updateDeviceInfoOnMetricsChange() {
    if (_deviceInfo == null) return;

    try {
      final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
      final mediaQuery = platformDispatcher.views.first;
      final size = mediaQuery.physicalSize / mediaQuery.devicePixelRatio;

      final orientation = size.width > size.height
          ? Orientation.landscape
          : Orientation.portrait;
      final breakpoint = _determineBreakpoint(size);
      final statusBarHeight =
          mediaQuery.padding.top / mediaQuery.devicePixelRatio;
      final navigationBarHeight =
          mediaQuery.padding.bottom / mediaQuery.devicePixelRatio;
      final hasSystemNavigation = mediaQuery.systemGestureInsets.bottom > 0;
      final hasNotch =
          statusBarHeight > 24 || (Platform.isIOS && statusBarHeight > 20);

      _deviceInfo = _deviceInfo!.copyWith(
        screenSize: size,
        pixelRatio: mediaQuery.devicePixelRatio,
        textScaleFactor: platformDispatcher.textScaleFactor,
        orientation: orientation,
        breakpoint: breakpoint,
        isLandscapeFirst: size.width > size.height,
        systemNavigationInsets: EdgeInsets.fromViewPadding(
          mediaQuery.systemGestureInsets,
          mediaQuery.devicePixelRatio,
        ),
        systemPadding: EdgeInsets.fromViewPadding(
          mediaQuery.padding,
          mediaQuery.devicePixelRatio,
        ),
        hasSystemNavigation: hasSystemNavigation,
        hasNotch: hasNotch,
        hasPhysicalHomeButton: !hasSystemNavigation && Platform.isAndroid,
        statusBarHeight: statusBarHeight,
        navigationBarHeight: navigationBarHeight,
        timestamp: DateTime.now(),
      );

      _deviceController.add(_deviceInfo!);
      _logger.debug(
        'Device metrics updated: ${orientation.name}, ${breakpoint.name}',
      );
    } catch (error) {
      _logger.error(
        'Failed to update device info on metrics change',
        error: error,
      );
    }
  }

  Future<void> _initializeConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      final isOnline = result != ConnectivityResult.none;

      _updateConnectivity(
        isOnline
            ? lifecycle.ConnectivityState.online
            : lifecycle.ConnectivityState.offline,
      );

      _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
        result,
      ) {
        final isOnline = result != ConnectivityResult.none;
        _updateConnectivity(
          isOnline
              ? lifecycle.ConnectivityState.online
              : lifecycle.ConnectivityState.offline,
        );
      });
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to initialize connectivity monitoring',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _updateConnectivity(lifecycle.ConnectivityState connectivity) {
    _currentState = _currentState.copyWith(
      connectivity: connectivity,
      timestamp: DateTime.now(),
    );

    _currentState = _currentState.copyWith(
      lifecycle: _combineStates(_currentState.focus, connectivity),
      timestamp: DateTime.now(),
    );

    _stateController.add(_currentState);
    _logger.debug('Connectivity updated: ${connectivity.name}');
  }

  lifecycle.AppLifecycleState _combineStates(
    lifecycle.AppFocusState focus,
    lifecycle.ConnectivityState connectivity,
  ) {
    switch (focus) {
      case lifecycle.AppFocusState.foreground:
        return connectivity == lifecycle.ConnectivityState.online
            ? lifecycle.AppLifecycleState.appForegroundOnline
            : lifecycle.AppLifecycleState.appForegroundOffline;
      case lifecycle.AppFocusState.background:
        return connectivity == lifecycle.ConnectivityState.online
            ? lifecycle.AppLifecycleState.appBackgroundOnline
            : lifecycle.AppLifecycleState.appBackgroundOffline;
    }
  }

  void _updateFocus(lifecycle.AppFocusState focus) {
    _currentState = _currentState.copyWith(
      focus: focus,
      timestamp: DateTime.now(),
    );

    _currentState = _currentState.copyWith(
      lifecycle: _combineStates(focus, _currentState.connectivity),
      timestamp: DateTime.now(),
    );

    _stateController.add(_currentState);
    _logger.debug('Focus updated: ${focus.name}');
  }

  void _updateState(lifecycle.AppLifecycleState lifecycle) {
    _currentState = _currentState.copyWith(
      lifecycle: lifecycle,
      timestamp: DateTime.now(),
    );

    _stateController.add(_currentState);
    _logger.debug('App state updated: ${lifecycle.name}');
  }

  Future<void> _initializeLocale() async {
    try {
      final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
      final locale = platformDispatcher.locale;

      _localeInfo = LocaleInfo.fromLocale(locale, deviceLocale: locale);
      _localeController.add(_localeInfo);

      _logger.info('Locale initialized: ${locale.languageCode}');
    } catch (error) {
      _logger.error('Failed to initialize locale', error: error);
      _localeInfo = LocaleInfo.fromLocale(const Locale('en'));
    }
  }

  Future<void> _handleAppResume() async {
    try {
      await _reinitializeConnectivity();
      _logger.debug('App resumed, services validated');
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to validate services on resume',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _reinitializeConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      final isOnline = result != ConnectivityResult.none;
      _updateConnectivity(
        isOnline
            ? lifecycle.ConnectivityState.online
            : lifecycle.ConnectivityState.offline,
      );
    } catch (error) {
      _logger.error('Failed to reinitialize connectivity', error: error);
    }
  }

  @override
  Future<void> updateTheme(ThemeMode mode) async {
    _themeMode = mode;
    _themeController.add(_themeMode);
    _logger.debug('Theme updated: ${mode.name}');
  }

  @override
  Future<void> updateLocale(Locale locale, {Locale? deviceLocale}) async {
    _localeInfo = LocaleInfo.fromLocale(locale, deviceLocale: deviceLocale);
    _localeController.add(_localeInfo);
    _logger.debug('Locale updated: ${locale.languageCode}');
  }

  @override
  Future<void> updateNavigation(
    String route, {
    Map<String, dynamic>? params,
  }) async {
    _navigationState = _navigationState.pushRoute(route, params: params);
    _navController.add(_navigationState);
    _logger.debug('Navigation updated to $route');
  }

  @override
  Future<void> updateTab(int tabIndex, String route) async {
    _navigationState = _navigationState.updateTab(tabIndex, route);
    _navController.add(_navigationState);
    _logger.debug('Tab updated to $tabIndex -> $route');
  }

  @override
  Future<void> popNavigation() async {
    _navigationState = _navigationState.popRoute();
    _navController.add(_navigationState);
    _logger.debug('Navigation popped to ${_navigationState.currentRoute}');
  }

  @override
  Future<void> setAuthenticated(
    bool authenticated, {
    String? userId,
    String? userEmail,
  }) async {
    _authInfo = _authInfo.copyWith(
      isAuthenticated: authenticated,
      userId: userId,
      userEmail: userEmail,
      authenticatedAt: authenticated ? DateTime.now() : null,
    );
    _authController.add(_authInfo);
    _logger.info('Authentication state changed: $authenticated');
  }

  @override
  Future<void> setUnauthenticated() async {
    _authInfo = AuthInfo();
    _authController.add(_authInfo);
    _logger.info('User unauthenticated');
  }

  @override
  Map<String, dynamic> getFullState() {
    return {
      'appState': _currentState.toMap(),
      'deviceInfo': _deviceInfo?.toMap(),
      'navigationState': _navigationState.toMap(),
      'authInfo': _authInfo.toMap(),
      'themeMode': _themeMode.name,
      'localeInfo': _localeInfo.toMap(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
