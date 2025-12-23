// lib/src/app_state/models/app_lifecycle_state.dart
enum AppLifecycleState {
  appStart,
  appInit,
  appForegroundOnline,
  appForegroundOffline,
  appBackgroundOnline,
  appBackgroundOffline,
  appKill,
}

enum AppFocusState {
  foreground,
  background,
}

enum ConnectivityState {
  online,
  offline,
}

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

