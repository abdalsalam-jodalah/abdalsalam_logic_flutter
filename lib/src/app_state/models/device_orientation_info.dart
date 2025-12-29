enum DeviceOrientation { portrait, landscape, portraitDown, landscapeLeft, landscapeRight, unknown }

class DeviceOrientationInfo {
  final DeviceOrientation currentOrientation;
  final bool isPortrait;
  final bool isLandscape;
  final DateTime timestamp;

  const DeviceOrientationInfo({
    required this.currentOrientation,
    required this.isPortrait,
    required this.isLandscape,
    required this.timestamp,
  });

  factory DeviceOrientationInfo.initial() => DeviceOrientationInfo(
        currentOrientation: DeviceOrientation.portrait,
        isPortrait: true,
        isLandscape: false,
        timestamp: DateTime.now(),
      );

  DeviceOrientationInfo copyWith({
    DeviceOrientation? currentOrientation,
    bool? isPortrait,
    bool? isLandscape,
    DateTime? timestamp,
  }) =>
      DeviceOrientationInfo(
        currentOrientation: currentOrientation ?? this.currentOrientation,
        isPortrait: isPortrait ?? this.isPortrait,
        isLandscape: isLandscape ?? this.isLandscape,
        timestamp: timestamp ?? this.timestamp,
      );

  Map<String, dynamic> toMap() => {
        'currentOrientation': currentOrientation.name,
        'isPortrait': isPortrait,
        'isLandscape': isLandscape,
        'timestamp': timestamp.toIso8601String(),
      };

  @override
  String toString() =>
      'DeviceOrientationInfo(orientation: ${currentOrientation.name}, portrait: $isPortrait, landscape: $isLandscape)';
}
