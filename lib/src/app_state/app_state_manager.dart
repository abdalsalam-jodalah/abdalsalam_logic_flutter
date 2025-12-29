// lib/src/app_state/app_state_manager.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'models/app_lifecycle_state.dart' as lifecycle;
import 'models/device_info.dart';
import 'models/device_orientation_info.dart';
import 'models/app_version_info.dart';
import 'models/storage_info.dart';
import 'models/system_settings_info.dart';
import 'models/screen_metrics_info.dart';
import 'models/vpn_info.dart';
import 'models/wifi_info.dart';
import 'models/audio_state_info.dart';
import 'models/app_runtime_info.dart';
import 'models/navigation_state.dart';
import 'models/locale_info.dart';
import 'models/auth_info.dart';
import 'models/keyboard_info.dart';
import 'models/battery_info.dart';
import 'models/network_info.dart';
import 'models/accessibility_info.dart';
import 'models/memory_info.dart';
import 'models/permissions_info.dart';
import '../core/interfaces/service_interface.dart';

/// Centralized application state management service.
///
/// Manages global application state including:
/// - App lifecycle (start, init, foreground/background, online/offline)
/// - Device information (type, OS, screen metrics, breakpoints)
/// - Navigation state (routes, history, tabs)
/// - Theme mode (light, dark, system)
/// - Locale information (current locale, RTL support)
/// - Authentication state (user info, authentication status)
///
/// Provides reactive streams for all state domains, allowing UI components
/// to listen and react to state changes automatically.
///
/// Example:
/// ```dart
/// final appStateManager = AppStateManagerImpl.create(logger);
/// await appStateManager.initialize();
///
/// // Listen to state changes
/// appStateManager.stateStream.listen((state) {
///   print('App state: ${state.lifecycle.name}');
///   print('Online: ${state.isOnline}');
/// });
///
/// // Listen to device info changes
/// appStateManager.deviceStream.listen((device) {
///   print('Device: ${device.type.name}');
///   print('Breakpoint: ${device.breakpoint.name}');
/// });
///
/// // Update authentication state
/// await appStateManager.setAuthenticated(
///   true,
///   userId: 'user123',
///   userEmail: 'user@example.com',
/// );
/// ```
abstract class AppStateManager implements ServiceInterface {
  /// Current application lifecycle state.
  lifecycle.AppStateInfo get currentState;

  /// Current device information, or `null` if not yet initialized.
  DeviceInfo? get deviceInfo;

  /// Current navigation state (routes, history, tabs).
  NavigationState get navigationState;

  /// Current theme mode (light, dark, or system).
  ThemeMode get themeMode;

  /// Current locale information.
  LocaleInfo get localeInfo;

  /// Current authentication information.
  AuthInfo get authInfo;

  /// Current keyboard information, or `null` if not yet detected.
  KeyboardInfo? get keyboardInfo;

  /// Current battery information, or `null` if not available.
  BatteryInfo? get batteryInfo;

  /// Current network information, or `null` if not yet initialized.
  NetworkInfo? get networkInfo;

  /// Current accessibility features information.
  AccessibilityInfo? get accessibilityInfo;

  /// Current memory pressure information.
  MemoryInfo? get memoryInfo;

  /// Current permissions information.
  PermissionsInfo get permissionsInfo;

  /// Current device orientation information.
  DeviceOrientationInfo get deviceOrientationInfo;

  /// Current app version information.
  AppVersionInfo get appVersionInfo;

  /// Current storage information.
  StorageInfo get storageInfo;

  /// Current system settings information.
  SystemSettingsInfo get systemSettingsInfo;

  /// Current screen metrics information.
  ScreenMetricsInfo get screenMetricsInfo;

  /// Current VPN connection information.
  VpnInfo get vpnInfo;

  /// Current WiFi connection information.
  WiFiInfo get wifiInfo;

  /// Current audio state information.
  AudioStateInfo get audioStateInfo;

  /// Current app runtime information.
  AppRuntimeInfo get appRuntimeInfo;

  /// Stream of application lifecycle state changes.
  ///
  /// Emits a new [AppStateInfo] whenever the app lifecycle, focus, or
  /// connectivity state changes.
  Stream<lifecycle.AppStateInfo> get stateStream;

  /// Stream of device information changes.
  ///
  /// Emits a new [DeviceInfo] whenever device metrics change (e.g., orientation,
  /// screen size, system UI changes).
  Stream<DeviceInfo> get deviceStream;

  /// Stream of navigation state changes.
  ///
  /// Emits a new [NavigationState] whenever navigation occurs (route changes,
  /// tab switches).
  Stream<NavigationState> get navigationStream;

  /// Stream of keyboard visibility changes.
  ///
  /// Emits a new [KeyboardInfo] whenever keyboard visibility or height changes.
  Stream<KeyboardInfo> get keyboardStream;

  /// Stream of battery status changes.
  ///
  /// Emits a new [BatteryInfo] whenever battery level, charging state, or
  /// power mode changes.
  Stream<BatteryInfo> get batteryStream;

  /// Stream of network type changes.
  ///
  /// Emits a new [NetworkInfo] whenever network type changes (WiFi, mobile, etc).
  Stream<NetworkInfo> get networkStream;

  /// Stream of accessibility features changes.
  ///
  /// Emits a new [AccessibilityInfo] whenever accessibility settings change.
  Stream<AccessibilityInfo> get accessibilityStream;

  /// Stream of memory pressure changes.
  ///
  /// Emits a new [MemoryInfo] whenever memory pressure level changes.
  Stream<MemoryInfo> get memoryStream;

  /// Stream of theme mode changes.
  ///
  /// Emits a new [ThemeMode] whenever the theme mode is updated.
  Stream<ThemeMode> get themeStream;

  /// Stream of locale information changes.
  ///
  /// Emits a new [LocaleInfo] whenever the locale is updated.
  Stream<LocaleInfo> get localeStream;

  /// Stream of authentication state changes.
  ///
  /// Emits a new [AuthInfo] whenever authentication state changes.
  Stream<AuthInfo> get authStream;

  /// Stream of permissions changes.
  ///
  /// Emits a new [PermissionsInfo] whenever permissions are updated.
  Stream<PermissionsInfo> get permissionsStream;

  /// Stream of device orientation changes.
  ///
  /// Emits a new [DeviceOrientationInfo] whenever device orientation changes.
  Stream<DeviceOrientationInfo> get deviceOrientationStream;

  /// Stream of app version changes.
  ///
  /// Emits a new [AppVersionInfo] if app version information is updated.
  Stream<AppVersionInfo> get appVersionStream;

  /// Stream of storage information changes.
  ///
  /// Emits a new [StorageInfo] whenever storage information is updated.
  Stream<StorageInfo> get storageStream;

  /// Stream of system settings changes.
  ///
  /// Emits a new [SystemSettingsInfo] whenever system settings change.
  Stream<SystemSettingsInfo> get systemSettingsStream;

  /// Stream of screen metrics changes.
  ///
  /// Emits a new [ScreenMetricsInfo] whenever screen metrics change.
  Stream<ScreenMetricsInfo> get screenMetricsStream;

  /// Stream of VPN connection changes.
  ///
  /// Emits a new [VpnInfo] whenever VPN status changes.
  Stream<VpnInfo> get vpnStream;

  /// Stream of WiFi information changes.
  ///
  /// Emits a new [WiFiInfo] whenever WiFi status changes.
  Stream<WiFiInfo> get wifiStream;

  /// Stream of audio state changes.
  ///
  /// Emits a new [AudioStateInfo] whenever audio state changes.
  Stream<AudioStateInfo> get audioStateStream;

  /// Stream of app runtime information changes.
  ///
  /// Emits a new [AppRuntimeInfo] whenever runtime information is updated.
  Stream<AppRuntimeInfo> get appRuntimeStream;

  /// Updates the navigation state with a new route.
  ///
  /// [route] is the new route path. [params] are optional route parameters.
  ///
  /// The route is added to the navigation history and broadcast via
  /// [navigationStream].
  void updateNavigation(String route, {Map<String, dynamic>? params});

  /// Updates the current tab and its associated route.
  ///
  /// [tabIndex] is the index of the tab. [route] is the route associated
  /// with that tab.
  ///
  /// The navigation state is updated and broadcast via [navigationStream].
  void updateTab(int tabIndex, String route);

  /// Updates the application theme mode.
  ///
  /// The new theme mode is broadcast via [themeStream].
  void updateTheme(ThemeMode mode);

  /// Updates the application locale.
  ///
  /// [locale] is the new locale to use, or null to use device locale.
  ///
  /// The new locale information is broadcast via [localeStream].
  void updateLocale(Locale? locale);

  /// Sets the authentication state with user information.
  ///
  /// [user] is the authenticated user object.
  /// [accessToken] is the authentication access token.
  ///
  /// The authentication state is updated and broadcast via [authStream].
  void setAuthenticated(dynamic user, String accessToken);

  /// Clears the authentication state (logs out the user).
  ///
  /// The authentication state is reset and broadcast via [authStream].
  void setUnauthenticated();

  /// Updates the full authentication information.
  ///
  /// Allows updating complete [AuthInfo] object for complex auth state changes.
  void updateAuthInfo(AuthInfo authInfo);

  /// Updates permission status for a specific permission type.
  ///
  /// [permissionInfo] contains the updated permission status.
  ///
  /// The permissions state is updated and broadcast via [permissionsStream].
  void updatePermission(PermissionInfo permissionInfo);

  /// Updates multiple permissions at once.
  ///
  /// [permissions] is a list of [PermissionInfo] objects to update.
  ///
  /// The permissions state is updated and broadcast via [permissionsStream].
  void updatePermissions(List<PermissionInfo> permissions);

  /// Refreshes all app state data by re-initializing all state domains.
  ///
  /// This will trigger a complete refresh of:
  /// - Device information
  /// - Connectivity status
  /// - WiFi information
  /// - Battery status
  /// - Storage information
  /// - Audio state
  /// - Memory information
  /// - Screen metrics
  /// - Permissions
  /// - And all other state domains
  ///
  /// All streams will emit updated values after refresh completes.
  Future<void> refreshAll();

  /// Refreshes WiFi information only.
  Future<void> refreshWiFi();

  /// Refreshes battery information only.
  Future<void> refreshBattery();

  /// Refreshes storage information only.
  Future<void> refreshStorage();

  /// Refreshes audio state only.
  Future<void> refreshAudio();

  /// Refreshes memory information only.
  Future<void> refreshMemory();

  /// Refreshes permissions only.
  Future<void> refreshPermissions();

  /// Returns a complete snapshot of all application state.
  ///
  /// Useful for debugging, analytics, or state persistence. Returns a
  /// JSON-serializable map containing all state domains.
  Map<String, dynamic> getFullState();
}
