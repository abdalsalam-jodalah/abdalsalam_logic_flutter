// lib/src/app_state/app_state_manager_impl.dart
import 'dart:async';
import 'dart:io' show Platform;
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

class AppStateManagerImpl
    with WidgetsBindingObserver
    implements AppStateManager {
  static AppStateManagerImpl? _instance;

  factory AppStateManagerImpl.create(LoggerService logger) {
    _instance ??= AppStateManagerImpl._internal(logger);
    return _instance!;
  }

  AppStateManagerImpl._internal(this._logger);

  static AppStateManagerImpl get instance {
    if (_instance == null) {
      throw StateError(
        'AppStateManagerImpl not initialized. Call create() first.',
      );
    }
    return _instance!;
  }

  final LoggerService _logger;
  final Connectivity _connectivity = Connectivity();
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isInitialized = false;

  lifecycle.AppStateInfo _currentState = lifecycle.AppStateInfo(
    lifecycle: lifecycle.AppLifecycleState.appStart,
    focus: lifecycle.AppFocusState.foreground,
    connectivity: lifecycle.ConnectivityState.offline,
    timestamp: DateTime.now(),
  );

  models.DeviceInfo? _deviceInfo_;
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
  AuthInfo _authInfo = AuthInfo.empty();

  final StreamController<lifecycle.AppStateInfo> _stateController =
      StreamController.broadcast();
  final StreamController<models.DeviceInfo> _deviceController =
      StreamController.broadcast();
  final StreamController<NavigationState> _navController =
      StreamController.broadcast();
  final StreamController<ThemeMode> _themeController =
      StreamController.broadcast();
  final StreamController<LocaleInfo> _localeController =
      StreamController.broadcast();
  final StreamController<AuthInfo> _authController =
      StreamController.broadcast();

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

  @override
  lifecycle.AppStateInfo get currentState => _currentState;

  @override
  models.DeviceInfo? get deviceInfo => _deviceInfo_;

  @override
  NavigationState get navigationState => _navigationState;

  @override
  ThemeMode get themeMode => _themeMode;

  @override
  LocaleInfo get localeInfo => _localeInfo;

  @override
  AuthInfo get authInfo => _authInfo;

  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      _logger.warning('AppStateManager already initialized');
      return;
    }

    _logger.info('Initializing AppStateManager');

    WidgetsBinding.instance.addObserver(this);

    await _initializeDeviceInfo();
    await _initializeConnectivity();
    await _initializeLocale();

    _updateState(lifecycle.AppLifecycleState.appInit);

    _isInitialized = true;
    _logger.info('AppStateManager initialized successfully');
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _updateDeviceInfoOnMetricsChange();
  }

  Future<void> _initializeDeviceInfo() async {
    try {
      final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
      final mediaQuery = platformDispatcher.views.first;

      models.DeviceOS os;
      String osVersion = 'Unknown';
      String deviceModel = 'Unknown';

      if (kIsWeb) {
        os = models.DeviceOS.web;
        final webInfo = await _deviceInfoPlugin.webBrowserInfo;
        deviceModel = '${webInfo.browserName} ${webInfo.platform}';
      } else if (Platform.isAndroid) {
        os = models.DeviceOS.android;
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        osVersion = 'Android ${androidInfo.version.release}';
        deviceModel = '${androidInfo.manufacturer} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        os = models.DeviceOS.ios;
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        osVersion = '${iosInfo.systemName} ${iosInfo.systemVersion}';
        deviceModel = iosInfo.model;
      } else if (Platform.isWindows) {
        os = models.DeviceOS.windows;
        final windowsInfo = await _deviceInfoPlugin.windowsInfo;
        deviceModel = windowsInfo.computerName;
      } else if (Platform.isMacOS) {
        os = models.DeviceOS.macos;
        final macInfo = await _deviceInfoPlugin.macOsInfo;
        deviceModel = macInfo.model;
      } else if (Platform.isLinux) {
        os = models.DeviceOS.linux;
        final linuxInfo = await _deviceInfoPlugin.linuxInfo;
        deviceModel = linuxInfo.name;
      } else {
        os = models.DeviceOS.android;
      }

      final size = mediaQuery.physicalSize / mediaQuery.devicePixelRatio;
      final deviceType = _determineDeviceType(size);

      final orientation = size.width > size.height
          ? Orientation.landscape
          : Orientation.portrait;
      final statusBarHeight =
          mediaQuery.padding.top / mediaQuery.devicePixelRatio;
      final navigationBarHeight =
          mediaQuery.padding.bottom / mediaQuery.devicePixelRatio;
      final hasSystemNavigation = mediaQuery.systemGestureInsets.bottom > 0;
      final hasNotch =
          statusBarHeight > 24 || (Platform.isIOS && statusBarHeight > 20);
      final breakpoint = _determineBreakpoint(size);

      _deviceInfo_ = models.DeviceInfo(
        type: deviceType,
        os: os,
        osVersion: osVersion,
        deviceModel: deviceModel,
        screenSize: size,
        pixelRatio: mediaQuery.devicePixelRatio,
        textScaleFactor: platformDispatcher.textScaleFactor,
        orientation: orientation,
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
        platformBrightness: platformDispatcher.platformBrightness,
        breakpoint: breakpoint,
        isLandscapeFirst: size.width > size.height,
        timestamp: DateTime.now(),
      );

      _deviceController.add(_deviceInfo_!);
      _logger.info('Device info initialized');
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to initialize device info',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  models.DeviceType _determineDeviceType(Size size) {
    if (kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return models.DeviceType.desktop;
    }

    return size.width >= 600
        ? models.DeviceType.tablet
        : models.DeviceType.phone;
  }

  models.ResponsiveBreakpoint _determineBreakpoint(Size size) {
    final width = size.width;
    if (width < 576) return models.ResponsiveBreakpoint.xs;
    if (width < 768) return models.ResponsiveBreakpoint.sm;
    if (width < 992) return models.ResponsiveBreakpoint.md;
    if (width < 1200) return models.ResponsiveBreakpoint.lg;
    return models.ResponsiveBreakpoint.xl;
  }

  void _updateDeviceInfoOnMetricsChange() {
    if (_deviceInfo_ == null) return;

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
      final hasSystemNavigation = mediaQuery.systemGestureInsets.bottom > 0;
      final hasNotch =
          statusBarHeight > 24 ||
          (!kIsWeb && Platform.isIOS && statusBarHeight > 20);

      _deviceInfo_ = _deviceInfo_!.copyWith(
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
        hasPhysicalHomeButton:
            !kIsWeb && !hasSystemNavigation && Platform.isAndroid,
        statusBarHeight: statusBarHeight,
        platformBrightness: platformDispatcher.platformBrightness,
        timestamp: DateTime.now(),
      );

      _deviceController.add(_deviceInfo_!);
      _logger.debug(
        'Device metrics updated: ${orientation.name}, ${breakpoint.name}, ${size.width}x${size.height}',
      );
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to update device info on metrics change',
        error: error,
        stackTrace: stackTrace,
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

  void _updateState(lifecycle.AppLifecycleState lifecycleState) {
    _currentState = _currentState.copyWith(
      lifecycle: lifecycleState,
      timestamp: DateTime.now(),
    );

    _stateController.add(_currentState);
    _logger.debug('App state updated to ${lifecycleState.name}');
  }

  void _updateConnectivity(lifecycle.ConnectivityState connectivity) {
    final newLifecycle = _combineStates(_currentState.focus, connectivity);

    _currentState = _currentState.copyWith(
      lifecycle: newLifecycle,
      connectivity: connectivity,
      timestamp: DateTime.now(),
    );

    _stateController.add(_currentState);
    _logger.info('Connectivity changed to ${connectivity.name}');
  }

  void _updateFocus(lifecycle.AppFocusState focus) {
    final newLifecycle = _combineStates(focus, _currentState.connectivity);

    _currentState = _currentState.copyWith(
      lifecycle: newLifecycle,
      focus: focus,
      timestamp: DateTime.now(),
    );

    _stateController.add(_currentState);
    _logger.info('Focus changed to ${focus.name}');
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
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

  void _handleAppResume() {
    _logger.info('App resumed, validating services...');
    unawaited(_validateServicesOnResume());
  }

  Future<void> _validateServicesOnResume() async {
    try {
      await Future.wait([_reinitializeConnectivity()]);
      _logger.info('Services validated successfully on resume');
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
      _logger.debug(
        'Connectivity revalidated on resume: ${isOnline ? "online" : "offline"}',
      );
    } catch (error) {
      _logger.warning('Failed to revalidate connectivity on resume: $error');
    }
  }

  @override
  void updateNavigation(String route, {Map<String, dynamic>? params}) {
    _navigationState = _navigationState.pushRoute(route, params: params);
    _navController.add(_navigationState);
    _logger.debug('Navigation updated to $route');
  }

  @override
  void updateTab(int tabIndex, String route) {
    _navigationState = _navigationState.updateTab(tabIndex, route);
    _navController.add(_navigationState);
    _logger.debug('Tab updated to $tabIndex -> $route');
  }

  @override
  void updateTheme(ThemeMode themeMode) {
    if (_themeMode == themeMode) return;

    _themeMode = themeMode;
    _themeController.add(_themeMode);
    _logger.info('Theme changed to ${themeMode.name}');
  }

  Future<void> _initializeLocale() async {
    try {
      final deviceLocale = _getDeviceLocale();

      final initialLocale = deviceLocale ?? const Locale('en');

      _localeInfo = LocaleInfo.fromLocale(
        initialLocale,
        deviceLocale: deviceLocale,
      );
      _localeController.add(_localeInfo);

      _logger.info(
        'Locale initialized: current=${initialLocale.languageCode}, device=${deviceLocale?.languageCode}',
      );
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to initialize locale',
        error: e,
        stackTrace: stackTrace,
      );
      _localeInfo = LocaleInfo.fromLocale(const Locale('en'));
    }
  }

  Locale? _getDeviceLocale() {
    try {
      final locales = WidgetsBinding.instance.platformDispatcher.locales;
      return locales.isNotEmpty ? locales.first : null;
    } catch (e) {
      _logger.error('Failed to get device locale', error: e);
      return null;
    }
  }

  @override
  void updateLocale(Locale? locale) {
    final newLocaleInfo = LocaleInfo.fromLocale(
      locale,
      deviceLocale: _localeInfo.deviceLocale,
    );

    if (_localeInfo.currentLocale == newLocaleInfo.currentLocale) return;

    _localeInfo = newLocaleInfo;
    _localeController.add(_localeInfo);
    _logger.info('Locale changed to ${locale?.languageCode ?? 'system'}');
  }

  @override
  void updateAuthInfo(AuthInfo authInfo) {
    _authInfo = authInfo;
    _authController.add(_authInfo);
    _logger.info('Auth state updated: ${authInfo.status.name}');
  }

  @override
  void setAuthenticated(dynamic user, String accessToken) {
    _authInfo = _authInfo.copyWith(
      status: AppAuthStatus.authenticated,
      currentUser: user,
      accessToken: accessToken,
      hasValidSession: true,
      lastLoginTime: DateTime.now(),
    );
    _authController.add(_authInfo);
    _logger.info('User authenticated');
  }

  @override
  void setUnauthenticated() {
    _authInfo = AuthInfo.empty();
    _authController.add(_authInfo);
    _logger.info('User unauthenticated');
  }

  @override
  Future<void> dispose() async {
    if (!_isInitialized) return;

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
  Map<String, dynamic> getFullState() {
    return {
      'appState': _currentState.toMap(),
      'deviceInfo': _deviceInfo_?.toMap(),
      'navigationState': _navigationState.toMap(),
      'authInfo': _authInfo.toMap(),
      'themeMode': _themeMode.name,
      'localeInfo': _localeInfo.toMap(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

void unawaited(Future<void> future) {}
