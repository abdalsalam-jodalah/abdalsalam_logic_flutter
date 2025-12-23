// lib/src/app_state/app_state_manager.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'models/app_lifecycle_state.dart' as lifecycle;
import 'models/device_info.dart';
import 'models/navigation_state.dart';
import 'models/locale_info.dart';
import 'models/auth_info.dart';
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

  /// Updates the application theme mode.
  ///
  /// The new theme mode is broadcast via [themeStream].
  Future<void> updateTheme(ThemeMode mode);

  /// Updates the application locale.
  ///
  /// [locale] is the new locale to use. [deviceLocale] is optional and
  /// represents the device's default locale.
  ///
  /// The new locale information is broadcast via [localeStream].
  Future<void> updateLocale(Locale locale, {Locale? deviceLocale});

  /// Updates the navigation state with a new route.
  ///
  /// [route] is the new route path. [params] are optional route parameters.
  ///
  /// The route is added to the navigation history and broadcast via
  /// [navigationStream].
  Future<void> updateNavigation(String route, {Map<String, dynamic>? params});

  /// Updates the current tab and its associated route.
  ///
  /// [tabIndex] is the index of the tab. [route] is the route associated
  /// with that tab.
  ///
  /// The navigation state is updated and broadcast via [navigationStream].
  Future<void> updateTab(int tabIndex, String route);

  /// Pops the last route from navigation history.
  ///
  /// The previous route becomes the current route, and the updated state
  /// is broadcast via [navigationStream].
  Future<void> popNavigation();

  /// Sets the authentication state.
  ///
  /// [authenticated] indicates whether the user is authenticated.
  /// [userId] and [userEmail] are optional user information.
  ///
  /// The authentication state is updated and broadcast via [authStream].
  Future<void> setAuthenticated(
    bool authenticated, {
    String? userId,
    String? userEmail,
  });

  /// Clears the authentication state (logs out the user).
  ///
  /// The authentication state is reset and broadcast via [authStream].
  Future<void> setUnauthenticated();

  /// Returns a complete snapshot of all application state.
  ///
  /// Useful for debugging, analytics, or state persistence. Returns a
  /// JSON-serializable map containing all state domains.
  Map<String, dynamic> getFullState();
}
