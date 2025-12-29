class AppVersionInfo {
  final String appName;
  final String version;
  final String buildNumber;
  final String packageName;
  final DateTime timestamp;

  const AppVersionInfo({
    required this.appName,
    required this.version,
    required this.buildNumber,
    required this.packageName,
    required this.timestamp,
  });

  factory AppVersionInfo.initial() => AppVersionInfo(
        appName: 'Unknown',
        version: '0.0.0',
        buildNumber: '0',
        packageName: 'unknown',
        timestamp: DateTime.now(),
      );

  AppVersionInfo copyWith({
    String? appName,
    String? version,
    String? buildNumber,
    String? packageName,
    DateTime? timestamp,
  }) =>
      AppVersionInfo(
        appName: appName ?? this.appName,
        version: version ?? this.version,
        buildNumber: buildNumber ?? this.buildNumber,
        packageName: packageName ?? this.packageName,
        timestamp: timestamp ?? this.timestamp,
      );

  Map<String, dynamic> toMap() => {
        'appName': appName,
        'version': version,
        'buildNumber': buildNumber,
        'packageName': packageName,
        'timestamp': timestamp.toIso8601String(),
      };

  @override
  String toString() => 'AppVersionInfo($appName v$version+$buildNumber)';
}
