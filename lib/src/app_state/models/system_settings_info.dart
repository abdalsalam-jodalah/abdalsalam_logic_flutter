class SystemSettingsInfo {
  final bool isLowPowerMode;
  final bool isAirplaneMode;
  final bool isDarkModeEnabled;
  final DateTime timestamp;

  const SystemSettingsInfo({
    required this.isLowPowerMode,
    required this.isAirplaneMode,
    required this.isDarkModeEnabled,
    required this.timestamp,
  });

  factory SystemSettingsInfo.initial() => SystemSettingsInfo(
        isLowPowerMode: false,
        isAirplaneMode: false,
        isDarkModeEnabled: false,
        timestamp: DateTime.now(),
      );

  SystemSettingsInfo copyWith({
    bool? isLowPowerMode,
    bool? isAirplaneMode,
    bool? isDarkModeEnabled,
    DateTime? timestamp,
  }) =>
      SystemSettingsInfo(
        isLowPowerMode: isLowPowerMode ?? this.isLowPowerMode,
        isAirplaneMode: isAirplaneMode ?? this.isAirplaneMode,
        isDarkModeEnabled: isDarkModeEnabled ?? this.isDarkModeEnabled,
        timestamp: timestamp ?? this.timestamp,
      );

  Map<String, dynamic> toMap() => {
        'isLowPowerMode': isLowPowerMode,
        'isAirplaneMode': isAirplaneMode,
        'isDarkModeEnabled': isDarkModeEnabled,
        'timestamp': timestamp.toIso8601String(),
      };

  @override
  String toString() =>
      'SystemSettingsInfo(lowPower: $isLowPowerMode, airplane: $isAirplaneMode, darkMode: $isDarkModeEnabled)';
}
