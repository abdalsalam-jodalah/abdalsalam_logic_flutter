// lib/src/app_state/models/app_lifecycle_state.dart

/// Represents the overall lifecycle state of the application.
///
/// The lifecycle combines app focus (foreground/background) with connectivity
/// status to provide a comprehensive state representation.
enum AppLifecycleState {
  /// Application is starting up.
  appStart,

  /// Application has completed initialization.
  appInit,

  /// Application is in foreground and device is online.
  appForegroundOnline,

  /// Application is in foreground but device is offline.
  appForegroundOffline,

  /// Application is in background and device is online.
  appBackgroundOnline,

  /// Application is in background and device is offline.
  appBackgroundOffline,

  /// Application is being terminated.
  appKill,
}

/// Represents whether the application is in foreground or background.
enum AppFocusState {
  /// Application is visible and active.
  foreground,

  /// Application is hidden or minimized.
  background,
}

/// Represents the network connectivity state of the device.
enum ConnectivityState {
  /// Device has active network connection.
  online,

  /// Device has no network connection.
  offline,
}

/// Comprehensive application state information.
///
/// Combines lifecycle state, focus state, and connectivity status with a
/// timestamp for tracking state changes over time.
///
/// Example:
/// ```dart
/// final state = AppStateInfo(
///   lifecycle: AppLifecycleState.appForegroundOnline,
///   focus: AppFocusState.foreground,
///   connectivity: ConnectivityState.online,
///   timestamp: DateTime.now(),
/// );
///
/// if (state.isOnline && state.isForeground) {
///   // App is active and connected
/// }
/// ```
class AppStateInfo {
  final AppLifecycleState lifecycle;
  final AppFocusState focus;
  final ConnectivityState connectivity;
  final DateTime timestamp;

  const AppStateInfo({
    required this.lifecycle,
    required this.focus,
    required this.connectivity,
    required this.timestamp,
  });

  /// Creates a copy of this [AppStateInfo] with the given fields replaced.
  ///
  /// All fields are optional. If a field is not provided, the current value
  /// is used.
  AppStateInfo copyWith({
    AppLifecycleState? lifecycle,
    AppFocusState? focus,
    ConnectivityState? connectivity,
    DateTime? timestamp,
  }) {
    return AppStateInfo(
      lifecycle: lifecycle ?? this.lifecycle,
      focus: focus ?? this.focus,
      connectivity: connectivity ?? this.connectivity,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Converts this [AppStateInfo] to a JSON-serializable map.
  Map<String, dynamic> toMap() {
    return {
      'lifecycle': lifecycle.name,
      'focus': focus.name,
      'connectivity': connectivity.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  bool get isOnline => connectivity == ConnectivityState.online;
  bool get isOffline => connectivity == ConnectivityState.offline;
  bool get isForeground => focus == AppFocusState.foreground;
  bool get isBackground => focus == AppFocusState.background;
}
