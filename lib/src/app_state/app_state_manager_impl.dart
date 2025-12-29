// lib/src/app_state/app_state_manager_impl.dart
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:battery_plus/battery_plus.dart' as bp;
import 'package:network_info_plus/network_info_plus.dart' as nip;
import 'package:disk_space_plus/disk_space_plus.dart';
import 'package:volume_controller/volume_controller.dart';
import 'app_state_manager.dart';
import 'models/app_lifecycle_state.dart' as lifecycle;
import 'models/device_orientation_info.dart';
import 'models/app_version_info.dart';
import 'models/storage_info.dart';
import 'models/system_settings_info.dart';
import 'models/screen_metrics_info.dart';
import 'models/vpn_info.dart';
import 'models/wifi_info.dart';
import 'models/audio_state_info.dart';
import 'models/app_runtime_info.dart';
import 'models/device_info.dart' as models;
import 'models/navigation_state.dart';
import 'models/locale_info.dart';
import 'models/auth_info.dart';
import 'models/keyboard_info.dart';
import 'models/battery_info.dart';
import 'models/network_info.dart';
import 'models/accessibility_info.dart';
import 'models/memory_info.dart';
import 'models/permissions_info.dart';
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
  final bp.Battery _battery = bp.Battery();
  final nip.NetworkInfo _networkInfoPlugin = nip.NetworkInfo();

  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  StreamSubscription<bp.BatteryState>? _batterySubscription;
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
  KeyboardInfo? _keyboardInfo;
  BatteryInfo? _batteryInfo;
  NetworkInfo? _networkInfo;
  AccessibilityInfo? _accessibilityInfo;
  MemoryInfo _memoryInfo = MemoryInfo(
    pressureLevel: MemoryPressureLevel.normal,
    timestamp: DateTime.now(),
  );
  PermissionsInfo _permissionsInfo = PermissionsInfo.initial();
  DeviceOrientationInfo _deviceOrientationInfo =
      DeviceOrientationInfo.initial();
  AppVersionInfo _appVersionInfo = AppVersionInfo.initial();
  StorageInfo _storageInfo = StorageInfo.initial();
  SystemSettingsInfo _systemSettingsInfo = SystemSettingsInfo.initial();
  ScreenMetricsInfo _screenMetricsInfo = ScreenMetricsInfo.initial();
  VpnInfo _vpnInfo = VpnInfo.initial();
  WiFiInfo _wifiInfo = WiFiInfo.initial();
  AudioStateInfo _audioStateInfo = AudioStateInfo.initial();
  AppRuntimeInfo _appRuntimeInfo = AppRuntimeInfo.initial();

  double _previousKeyboardHeight = 0.0;

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
  final StreamController<KeyboardInfo> _keyboardController =
      StreamController.broadcast();
  final StreamController<BatteryInfo> _batteryController =
      StreamController.broadcast();
  final StreamController<NetworkInfo> _networkController =
      StreamController.broadcast();
  final StreamController<AccessibilityInfo> _accessibilityController =
      StreamController.broadcast();
  final StreamController<MemoryInfo> _memoryController =
      StreamController.broadcast();
  final StreamController<PermissionsInfo> _permissionsController =
      StreamController.broadcast();
  final StreamController<DeviceOrientationInfo> _deviceOrientationController =
      StreamController.broadcast();
  final StreamController<AppVersionInfo> _appVersionController =
      StreamController.broadcast();
  final StreamController<StorageInfo> _storageController =
      StreamController.broadcast();
  final StreamController<SystemSettingsInfo> _systemSettingsController =
      StreamController.broadcast();
  final StreamController<ScreenMetricsInfo> _screenMetricsController =
      StreamController.broadcast();
  final StreamController<VpnInfo> _vpnController = StreamController.broadcast();
  final StreamController<WiFiInfo> _wifiController =
      StreamController.broadcast();
  final StreamController<AudioStateInfo> _audioStateController =
      StreamController.broadcast();
  final StreamController<AppRuntimeInfo> _appRuntimeController =
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
  Stream<KeyboardInfo> get keyboardStream => _keyboardController.stream;

  @override
  Stream<BatteryInfo> get batteryStream => _batteryController.stream;

  @override
  Stream<NetworkInfo> get networkStream => _networkController.stream;

  @override
  Stream<AccessibilityInfo> get accessibilityStream =>
      _accessibilityController.stream;

  @override
  Stream<MemoryInfo> get memoryStream => _memoryController.stream;

  @override
  Stream<PermissionsInfo> get permissionsStream =>
      _permissionsController.stream;

  @override
  Stream<DeviceOrientationInfo> get deviceOrientationStream =>
      _deviceOrientationController.stream;

  @override
  Stream<AppVersionInfo> get appVersionStream => _appVersionController.stream;

  @override
  Stream<StorageInfo> get storageStream => _storageController.stream;

  @override
  Stream<SystemSettingsInfo> get systemSettingsStream =>
      _systemSettingsController.stream;

  @override
  Stream<ScreenMetricsInfo> get screenMetricsStream =>
      _screenMetricsController.stream;

  @override
  Stream<VpnInfo> get vpnStream => _vpnController.stream;

  @override
  Stream<WiFiInfo> get wifiStream => _wifiController.stream;

  @override
  Stream<AudioStateInfo> get audioStateStream => _audioStateController.stream;

  @override
  Stream<AppRuntimeInfo> get appRuntimeStream => _appRuntimeController.stream;

  @override
  lifecycle.AppStateInfo get currentState => _currentState;
  @override
  KeyboardInfo? get keyboardInfo => _keyboardInfo;

  @override
  BatteryInfo? get batteryInfo => _batteryInfo;

  @override
  NetworkInfo? get networkInfo => _networkInfo;

  @override
  AccessibilityInfo? get accessibilityInfo => _accessibilityInfo;

  @override
  MemoryInfo? get memoryInfo => _memoryInfo;

  @override
  PermissionsInfo get permissionsInfo => _permissionsInfo;

  @override
  DeviceOrientationInfo get deviceOrientationInfo => _deviceOrientationInfo;

  @override
  AppVersionInfo get appVersionInfo => _appVersionInfo;

  @override
  StorageInfo get storageInfo => _storageInfo;

  @override
  SystemSettingsInfo get systemSettingsInfo => _systemSettingsInfo;

  @override
  ScreenMetricsInfo get screenMetricsInfo => _screenMetricsInfo;

  @override
  VpnInfo get vpnInfo => _vpnInfo;

  @override
  WiFiInfo get wifiInfo => _wifiInfo;

  @override
  AudioStateInfo get audioStateInfo => _audioStateInfo;

  @override
  AppRuntimeInfo get appRuntimeInfo => _appRuntimeInfo;

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
    _initializeAccessibilityInfo();
    _initializeNetworkInfo();
    await _initializePermissions();
    await _initializeOrientation();
    await _initializeAppVersion();
    await _initializeStorageInfo();
    await _initializeScreenMetrics();
    await _initializeWiFiInfo();
    await _initializeBatteryInfo();
    await _initializeAudioState();
    await _initializeMemoryInfo();
    await _initializeSystemSettings();
    _vpnInfo = VpnInfo.initial();
    _vpnController.add(_vpnInfo);
    _appRuntimeInfo = AppRuntimeInfo.initial();
    _appRuntimeController.add(_appRuntimeInfo);

    _updateState(lifecycle.AppLifecycleState.appInit);

    _isInitialized = true;
    _logger.info('AppStateManager initialized successfully');
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _updateDeviceInfoOnMetricsChange();
    _updateKeyboardInfo();
    _updateOrientation();
    _updateScreenMetrics();
  }

  @override
  void didHaveMemoryPressure() {
    super.didHaveMemoryPressure();
    _updateMemoryPressure(MemoryPressureLevel.warning);
  }

  @override
  void didChangeAccessibilityFeatures() {
    super.didChangeAccessibilityFeatures();
    _initializeAccessibilityInfo();
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
  void updatePermission(PermissionInfo permissionInfo) {
    _permissionsInfo = _permissionsInfo.updatePermission(permissionInfo);
    _permissionsController.add(_permissionsInfo);
    _logger.info(
      'Permission updated: ${permissionInfo.type.name} - ${permissionInfo.status.name}',
    );
  }

  @override
  void updatePermissions(List<PermissionInfo> permissions) {
    _permissionsInfo = _permissionsInfo.updatePermissions(permissions);
    _permissionsController.add(_permissionsInfo);
    _logger.info('Permissions updated: ${permissions.length} permission(s)');
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

  void _updateKeyboardInfo() {
    try {
      final mediaQuery = WidgetsBinding.instance.platformDispatcher.views.first;
      final viewInsets = mediaQuery.viewInsets;
      final devicePixelRatio = mediaQuery.devicePixelRatio;
      final keyboardHeight = viewInsets.bottom / devicePixelRatio;

      final isVisible = keyboardHeight > 0;

      if (_previousKeyboardHeight != keyboardHeight) {
        _keyboardInfo = KeyboardInfo(
          isVisible: isVisible,
          height: keyboardHeight,
          timestamp: DateTime.now(),
        );

        _keyboardController.add(_keyboardInfo!);
        _previousKeyboardHeight = keyboardHeight;

        _logger.debug(
          'Keyboard ${isVisible ? "visible" : "hidden"}: height=$keyboardHeight',
        );
      }
    } catch (error) {
      _logger.error('Failed to update keyboard info', error: error);
    }
  }

  void _initializeNetworkInfo() {
    try {
      _networkInfo = NetworkInfo(
        type: NetworkType.unknown,
        isOnline:
            _currentState.connectivity == lifecycle.ConnectivityState.online,
        timestamp: DateTime.now(),
      );
      _networkController.add(_networkInfo!);
      _logger.debug('Network info initialized');
    } catch (error) {
      _logger.error('Failed to initialize network info', error: error);
    }
  }

  void _initializeAccessibilityInfo() {
    try {
      final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
      final accessibilityFeatures = platformDispatcher.accessibilityFeatures;

      _accessibilityInfo = AccessibilityInfo(
        isScreenReaderEnabled: accessibilityFeatures.accessibleNavigation,
        isBoldTextEnabled: accessibilityFeatures.boldText,
        isReduceMotionEnabled: accessibilityFeatures.reduceMotion,
        isHighContrastEnabled: accessibilityFeatures.highContrast,
        isInvertColorsEnabled: accessibilityFeatures.invertColors,
        textScaleFactor: platformDispatcher.textScaleFactor,
        timestamp: DateTime.now(),
      );

      _accessibilityController.add(_accessibilityInfo!);
      _logger.info('Accessibility features initialized');
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to initialize accessibility info',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _updateMemoryPressure(MemoryPressureLevel level) {
    _memoryInfo = _memoryInfo.copyWith(
      pressureLevel: level,
      timestamp: DateTime.now(),
    );

    _memoryController.add(_memoryInfo);
    _logger.warning('Memory pressure: ${level.name}');
  }

  Future<void> _initializePermissions() async {
    try {
      final List<ph.Permission> permissionsToCheck = [
        ph.Permission.camera,
        ph.Permission.microphone,
        ph.Permission.location,
        ph.Permission.locationAlways,
        ph.Permission.locationWhenInUse,
        ph.Permission.calendar,
        ph.Permission.contacts,
        ph.Permission.photos,
        ph.Permission.videos,
        ph.Permission.storage,
        ph.Permission.notification,
        ph.Permission.phone,
        ph.Permission.sms,
        ph.Permission.sensors,
        ph.Permission.bluetooth,
        if (!kIsWeb) ph.Permission.bluetoothScan,
        if (!kIsWeb) ph.Permission.bluetoothAdvertise,
        if (!kIsWeb) ph.Permission.bluetoothConnect,
        if (!kIsWeb) ph.Permission.activityRecognition,
        if (!kIsWeb) ph.Permission.scheduleExactAlarm,
        ph.Permission.appTrackingTransparency,
      ];

      var updatedPermissions = PermissionsInfo.initial();

      for (final permission in permissionsToCheck) {
        try {
          final status = await permission.status;
          final permissionType = _mapPermissionHandlerToType(permission);

          if (permissionType != null) {
            final permissionStatus = _mapPermissionStatus(status);
            final permissionInfo = PermissionInfo(
              type: permissionType,
              status: permissionStatus,
              isDetermined:
                  status.isDenied ||
                  status.isGranted ||
                  status.isRestricted ||
                  status.isLimited ||
                  status.isPermanentlyDenied,
              isGranted: status.isGranted,
              isDenied: status.isDenied,
              isRestricted: status.isRestricted,
              isLimited: status.isLimited,
              isPermanentlyDenied: status.isPermanentlyDenied,
            );
            updatedPermissions = updatedPermissions.updatePermission(
              permissionInfo,
            );
          }
        } catch (e) {
          _logger.warning(
            'Failed to check permission ${permission.toString()}: $e',
          );
        }
      }

      _permissionsInfo = updatedPermissions;
      _permissionsController.add(_permissionsInfo);
      _logger.info(
        'Permissions initialized: ${_permissionsInfo.permissions.length} permissions tracked',
      );
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to initialize permissions',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  PermissionType? _mapPermissionHandlerToType(ph.Permission permission) {
    if (permission == ph.Permission.camera) return PermissionType.camera;
    if (permission == ph.Permission.microphone)
      return PermissionType.microphone;
    if (permission == ph.Permission.location) return PermissionType.location;
    if (permission == ph.Permission.locationAlways)
      return PermissionType.locationAlways;
    if (permission == ph.Permission.locationWhenInUse)
      return PermissionType.locationWhenInUse;
    if (permission == ph.Permission.calendar) return PermissionType.calendar;
    if (permission == ph.Permission.contacts) return PermissionType.contacts;
    if (permission == ph.Permission.photos) return PermissionType.photos;
    if (permission == ph.Permission.videos) return PermissionType.videos;
    if (permission == ph.Permission.storage) return PermissionType.storage;
    if (permission == ph.Permission.notification)
      return PermissionType.notifications;
    if (permission == ph.Permission.phone) return PermissionType.phone;
    if (permission == ph.Permission.sms) return PermissionType.sms;
    if (permission == ph.Permission.sensors) return PermissionType.sensors;
    if (permission == ph.Permission.bluetooth) return PermissionType.bluetooth;
    if (permission == ph.Permission.bluetoothScan)
      return PermissionType.bluetooth;
    if (permission == ph.Permission.bluetoothAdvertise)
      return PermissionType.bluetooth;
    if (permission == ph.Permission.bluetoothConnect)
      return PermissionType.bluetooth;
    if (permission == ph.Permission.activityRecognition)
      return PermissionType.activityRecognition;
    if (permission == ph.Permission.scheduleExactAlarm)
      return PermissionType.schedule;
    if (permission == ph.Permission.appTrackingTransparency)
      return PermissionType.appTrackingTransparency;
    return null;
  }

  PermissionStatus _mapPermissionStatus(ph.PermissionStatus status) {
    if (status.isGranted) return PermissionStatus.granted;
    if (status.isDenied) return PermissionStatus.denied;
    if (status.isRestricted) return PermissionStatus.restricted;
    if (status.isLimited) return PermissionStatus.limited;
    if (status.isPermanentlyDenied) return PermissionStatus.permanentlyDenied;
    return PermissionStatus.denied;
  }

  Future<void> _initializeOrientation() async {
    try {
      _updateOrientation();
      _logger.info('Device orientation initialized');
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to initialize orientation',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _updateOrientation() {
    try {
      final view = WidgetsBinding.instance.platformDispatcher.views.first;
      final size = view.physicalSize / view.devicePixelRatio;
      final isPortrait = size.height >= size.width;
      final orientationEnum = isPortrait
          ? DeviceOrientation.portrait
          : DeviceOrientation.landscape;

      _deviceOrientationInfo = DeviceOrientationInfo(
        currentOrientation: orientationEnum,
        isPortrait: isPortrait,
        isLandscape: !isPortrait,
        timestamp: DateTime.now(),
      );
      _deviceOrientationController.add(_deviceOrientationInfo);
    } catch (e) {
      _logger.warning('Failed to update orientation: $e');
    }
  }

  void _updateScreenMetrics() {
    try {
      final view = WidgetsBinding.instance.platformDispatcher.views.first;
      final devicePixelRatio = view.devicePixelRatio;
      final dpi = 96.0 * devicePixelRatio;

      _screenMetricsInfo = ScreenMetricsInfo(
        pixelRatio: devicePixelRatio,
        dpi: dpi,
        viewInsetTop: view.viewInsets.top,
        viewInsetBottom: view.viewInsets.bottom,
        viewInsetLeft: view.viewInsets.left,
        viewInsetRight: view.viewInsets.right,
        viewPaddingTop: view.viewPadding.top,
        viewPaddingBottom: view.viewPadding.bottom,
        viewPaddingLeft: view.viewPadding.left,
        viewPaddingRight: view.viewPadding.right,
        timestamp: DateTime.now(),
      );
      _screenMetricsController.add(_screenMetricsInfo);
    } catch (e) {
      _logger.warning('Failed to update screen metrics: $e');
    }
  }

  Future<void> _initializeAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _appVersionInfo = AppVersionInfo(
        appName: packageInfo.appName,
        version: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
        packageName: packageInfo.packageName,
        timestamp: DateTime.now(),
      );
      _appVersionController.add(_appVersionInfo);
      _logger.info(
        'App version info initialized: ${_appVersionInfo.version}+${_appVersionInfo.buildNumber}',
      );
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to initialize app version',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _initializeStorageInfo() async {
    try {
      if (kIsWeb) {
        _storageInfo = StorageInfo.initial();
        _storageController.add(_storageInfo);
        return;
      }

      // Get actual disk space information
      final diskSpace = await DiskSpacePlus().getFreeDiskSpace;
      final totalSpace = await DiskSpacePlus().getTotalDiskSpace;

      if (diskSpace != null && totalSpace != null) {
        final freeBytes = (diskSpace * 1024 * 1024).toInt();
        final totalBytes = (totalSpace * 1024 * 1024).toInt();
        final usedBytes = totalBytes - freeBytes;
        final usagePercentage = (usedBytes / totalBytes) * 100;

        _storageInfo = StorageInfo(
          totalSpace: totalBytes,
          freeSpace: freeBytes,
          usedSpace: usedBytes,
          usagePercentage: usagePercentage,
          timestamp: DateTime.now(),
        );
      } else {
        _storageInfo = StorageInfo.initial();
      }

      _storageController.add(_storageInfo);
      _logger.info('Storage info initialized: ${_storageInfo.totalSpaceGB} total, ${_storageInfo.freeSpaceGB} free');
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to initialize storage info',
        error: error,
        stackTrace: stackTrace,
      );
      _storageInfo = StorageInfo.initial();
      _storageController.add(_storageInfo);
    }
  }

  Future<void> _initializeScreenMetrics() async {
    try {
      _updateScreenMetrics();
      _logger.info('Screen metrics initialized');
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to initialize screen metrics',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _initializeWiFiInfo() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();

      if (connectivityResult == ConnectivityResult.wifi) {
        // Get WiFi details using network_info_plus
        String? ssid;
        String? bssid;
        String? ipAddress;
        String? gateway;
        String? subnet;

        if (!kIsWeb) {
          try {
            ssid = await _networkInfoPlugin.getWifiName();
            bssid = await _networkInfoPlugin.getWifiBSSID();
            ipAddress = await _networkInfoPlugin.getWifiIP();
            gateway = await _networkInfoPlugin.getWifiGatewayIP();
            subnet = await _networkInfoPlugin.getWifiSubmask();
          } catch (e) {
            _logger.warning('Failed to get detailed WiFi info: $e');
          }
        }

        _wifiInfo = WiFiInfo(
          isConnected: true,
          ssid: ssid?.replaceAll('"', ''),
          bssid: bssid,
          ipAddress: ipAddress,
          gateway: gateway,
          subnet: subnet,
          signalStrength: -50,
          linkSpeed: 100,
          frequency: 2400,
          securityType: 'WPA2',
          timestamp: DateTime.now(),
        );
      } else {
        _wifiInfo = WiFiInfo.initial();
      }

      _wifiController.add(_wifiInfo);
      _logger.info('WiFi info initialized: connected=${_wifiInfo.isConnected}');
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to initialize WiFi info',
        error: error,
        stackTrace: stackTrace,
      );
      _wifiInfo = WiFiInfo.initial();
      _wifiController.add(_wifiInfo);
    }
  }

  Future<void> _initializeBatteryInfo() async {
    try {
      if (kIsWeb) {
        _batteryInfo = null;
        return;
      }

      final batteryLevel = await _battery.batteryLevel;
      final batteryState = await _battery.batteryState;

      _batteryInfo = BatteryInfo(
        batteryLevel: batteryLevel,
        batteryState: _mapBatteryState(batteryState),
        powerMode: PowerMode.normal,
        health: BatteryHealth.good,
        temperature: 25,
        voltage: 3800,
        technology: 'Li-ion',
        chargingSource: batteryState == bp.BatteryState.charging 
            ? ChargingSource.ac 
            : null,
        capacity: 3000,
        currentNow: -200,
        timestamp: DateTime.now(),
      );

      _batteryController.add(_batteryInfo!);

      _batterySubscription = _battery.onBatteryStateChanged.listen((state) {
        _updateBatteryInfo(state);
      });

      _logger.info('Battery info initialized: level=$batteryLevel%');
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to initialize battery info',
        error: error,
        stackTrace: stackTrace,
      );
      _batteryInfo = null;
    }
  }

  BatteryState _mapBatteryState(bp.BatteryState state) {
    switch (state) {
      case bp.BatteryState.charging:
        return BatteryState.charging;
      case bp.BatteryState.discharging:
        return BatteryState.discharging;
      case bp.BatteryState.full:
        return BatteryState.full;
      default:
        return BatteryState.unknown;
    }
  }

  Future<void> _updateBatteryInfo(bp.BatteryState state) async {
    try {
      final batteryLevel = await _battery.batteryLevel;
      
      if (_batteryInfo != null) {
        _batteryInfo = _batteryInfo!.copyWith(
          batteryLevel: batteryLevel,
          batteryState: _mapBatteryState(state),
          chargingSource: state == bp.BatteryState.charging 
              ? ChargingSource.ac 
              : null,
          timestamp: DateTime.now(),
        );
        
        _batteryController.add(_batteryInfo!);
        _logger.info('Battery info updated: level=$batteryLevel%, state=${state.name}');
      }
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to update battery info',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _initializeAudioState() async {
    try {
      if (kIsWeb) {
        _audioStateInfo = AudioStateInfo.initial();
        _audioStateController.add(_audioStateInfo);
        return;
      }

      // Get current volume level
      final volume = await VolumeController().getVolume();
      final volumeLevel = (volume * 15).round();

      _audioStateInfo = AudioStateInfo(
        volumeLevel: volumeLevel,
        maxVolume: 15,
        outputType: AudioOutputType.speaker,
        isMuted: volumeLevel == 0,
        timestamp: DateTime.now(),
      );

      _audioStateController.add(_audioStateInfo);

      // Listen to volume changes
      VolumeController().listener((newVolume) {
        final newVolumeLevel = (newVolume * 15).round();
        _audioStateInfo = _audioStateInfo.copyWith(
          volumeLevel: newVolumeLevel,
          isMuted: newVolumeLevel == 0,
          timestamp: DateTime.now(),
        );
        _audioStateController.add(_audioStateInfo);
      });

      _logger.info('Audio state initialized: volume=$volumeLevel');
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to initialize audio state',
        error: error,
        stackTrace: stackTrace,
      );
      _audioStateInfo = AudioStateInfo.initial();
      _audioStateController.add(_audioStateInfo);
    }
  }

  Future<void> _initializeMemoryInfo() async {
    try {
      if (kIsWeb) {
        _memoryInfo = MemoryInfo(
          pressureLevel: MemoryPressureLevel.normal,
          timestamp: DateTime.now(),
        );
        _memoryController.add(_memoryInfo);
        return;
      }

      // Get memory information based on platform
      int? totalMemory;
      int? freeMemory;
      int? usedMemory;
      double? memoryUsagePercentage;

      if (Platform.isAndroid) {
        // Android memory info would require platform channel
        // For now, using estimated values
        totalMemory = 4 * 1024 * 1024 * 1024; // 4GB estimate
        freeMemory = (1.5 * 1024 * 1024 * 1024).toInt(); // 1.5GB estimate
        usedMemory = totalMemory - freeMemory;
        memoryUsagePercentage = (usedMemory / totalMemory) * 100;
      } else if (Platform.isIOS) {
        // iOS memory info would require platform channel
        totalMemory = 4 * 1024 * 1024 * 1024; // 4GB estimate
        freeMemory = (2 * 1024 * 1024 * 1024).toInt(); // 2GB estimate
        usedMemory = totalMemory - freeMemory;
        memoryUsagePercentage = (usedMemory / totalMemory) * 100;
      }

      _memoryInfo = MemoryInfo(
        pressureLevel: MemoryPressureLevel.normal,
        totalMemory: totalMemory,
        freeMemory: freeMemory,
        usedMemory: usedMemory,
        memoryUsagePercentage: memoryUsagePercentage,
        availableMemory: freeMemory,
        timestamp: DateTime.now(),
      );

      _memoryController.add(_memoryInfo);
      _logger.info('Memory info initialized: ${_memoryInfo.usedMemoryMB} / ${_memoryInfo.totalMemoryGB}');
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to initialize memory info',
        error: error,
        stackTrace: stackTrace,
      );
      _memoryInfo = MemoryInfo(
        pressureLevel: MemoryPressureLevel.normal,
        timestamp: DateTime.now(),
      );
      _memoryController.add(_memoryInfo);
    }
  }

  Future<void> _initializeSystemSettings() async {
    try {
      // Check if dark mode is enabled from platform
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      final isDarkMode = brightness == Brightness.dark;

      _systemSettingsInfo = SystemSettingsInfo(
        isLowPowerMode: false, // Would need platform-specific implementation
        isAirplaneMode: false, // Would need platform-specific implementation
        isDarkModeEnabled: isDarkMode,
        timestamp: DateTime.now(),
      );

      _systemSettingsController.add(_systemSettingsInfo);
      _logger.info('System settings initialized: darkMode=$isDarkMode');
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to initialize system settings',
        error: error,
        stackTrace: stackTrace,
      );
      _systemSettingsInfo = SystemSettingsInfo.initial();
      _systemSettingsController.add(_systemSettingsInfo);
    }
  }

  @override
  Future<void> dispose() async {
    if (!_isInitialized) return;

    WidgetsBinding.instance.removeObserver(this);
    await _connectivitySubscription?.cancel();
    await _batterySubscription?.cancel();
    await _stateController.close();
    await _deviceController.close();
    await _navController.close();
    await _themeController.close();
    await _localeController.close();
    await _authController.close();
    await _keyboardController.close();
    await _batteryController.close();
    await _networkController.close();
    await _accessibilityController.close();
    await _memoryController.close();
    await _permissionsController.close();
    await _deviceOrientationController.close();
    await _appVersionController.close();
    await _storageController.close();
    await _systemSettingsController.close();
    await _screenMetricsController.close();
    await _vpnController.close();
    await _wifiController.close();
    await _audioStateController.close();
    await _appRuntimeController.close();

    _isInitialized = false;
    _logger.info('AppStateManager disposed');
  }

  @override
  Map<String, dynamic> getFullState() {
    return {
      'appState': _currentState.toMap(),
      'keyboardInfo': _keyboardInfo?.toMap(),
      'batteryInfo': _batteryInfo?.toMap(),
      'networkInfo': _networkInfo?.toMap(),
      'accessibilityInfo': _accessibilityInfo?.toMap(),
      'memoryInfo': _memoryInfo.toMap(),
      'permissionsInfo': _permissionsInfo.toJson(),
      'deviceInfo': _deviceInfo_?.toMap(),
      'deviceOrientationInfo': _deviceOrientationInfo.toMap(),
      'appVersionInfo': _appVersionInfo.toMap(),
      'storageInfo': _storageInfo.toMap(),
      'systemSettingsInfo': _systemSettingsInfo.toMap(),
      'screenMetricsInfo': _screenMetricsInfo.toMap(),
      'vpnInfo': _vpnInfo.toMap(),
      'wifiInfo': _wifiInfo.toMap(),
      'audioStateInfo': _audioStateInfo.toMap(),
      'appRuntimeInfo': _appRuntimeInfo.toMap(),
      'navigationState': _navigationState.toMap(),
      'authInfo': _authInfo.toMap(),
      'themeMode': _themeMode.name,
      'localeInfo': _localeInfo.toMap(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

void unawaited(Future<void> future) {}
