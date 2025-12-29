class AppRuntimeInfo {
  final DateTime appLaunchTime;
  final Duration sessionDuration;
  final int sessionStartCount;
  final DateTime timestamp;

  const AppRuntimeInfo({
    required this.appLaunchTime,
    required this.sessionDuration,
    required this.sessionStartCount,
    required this.timestamp,
  });

  factory AppRuntimeInfo.initial() {
    final now = DateTime.now();
    return AppRuntimeInfo(
      appLaunchTime: now,
      sessionDuration: Duration.zero,
      sessionStartCount: 1,
      timestamp: now,
    );
  }

  String get uptime {
    final hours = sessionDuration.inHours;
    final minutes = sessionDuration.inMinutes % 60;
    final seconds = sessionDuration.inSeconds % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  AppRuntimeInfo copyWith({
    DateTime? appLaunchTime,
    Duration? sessionDuration,
    int? sessionStartCount,
    DateTime? timestamp,
  }) =>
      AppRuntimeInfo(
        appLaunchTime: appLaunchTime ?? this.appLaunchTime,
        sessionDuration: sessionDuration ?? this.sessionDuration,
        sessionStartCount: sessionStartCount ?? this.sessionStartCount,
        timestamp: timestamp ?? this.timestamp,
      );

  Map<String, dynamic> toMap() => {
        'appLaunchTime': appLaunchTime.toIso8601String(),
        'sessionDuration': sessionDuration.inSeconds,
        'uptime': uptime,
        'sessionStartCount': sessionStartCount,
        'timestamp': timestamp.toIso8601String(),
      };

  @override
  String toString() =>
      'AppRuntimeInfo(uptime: $uptime, sessionStarts: $sessionStartCount)';
}
