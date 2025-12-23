// lib/src/app_state/app_state_manager.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'models/app_lifecycle_state.dart' as lifecycle;
import 'models/device_info.dart';
import 'models/navigation_state.dart';
import 'models/locale_info.dart';
import 'models/auth_info.dart';
import '../core/interfaces/service_interface.dart';

abstract class AppStateManager implements ServiceInterface {
  lifecycle.AppStateInfo get currentState;
  DeviceInfo? get deviceInfo;
  NavigationState get navigationState;
  ThemeMode get themeMode;
  LocaleInfo get localeInfo;
  AuthInfo get authInfo;

  Stream<lifecycle.AppStateInfo> get stateStream;
  Stream<DeviceInfo> get deviceStream;
  Stream<NavigationState> get navigationStream;
  Stream<ThemeMode> get themeStream;
  Stream<LocaleInfo> get localeStream;
  Stream<AuthInfo> get authStream;

  Future<void> updateTheme(ThemeMode mode);
  Future<void> updateLocale(Locale locale, {Locale? deviceLocale});
  Future<void> updateNavigation(String route, {Map<String, dynamic>? params});
  Future<void> updateTab(int tabIndex, String route);
  Future<void> popNavigation();
  Future<void> setAuthenticated(
    bool authenticated, {
    String? userId,
    String? userEmail,
  });
  Future<void> setUnauthenticated();

  Map<String, dynamic> getFullState();
}
