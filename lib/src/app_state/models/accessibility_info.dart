// lib/src/app_state/models/accessibility_info.dart
class AccessibilityInfo {
  final bool isScreenReaderEnabled;
  final bool isBoldTextEnabled;
  final bool isReduceMotionEnabled;
  final bool isHighContrastEnabled;
  final bool isInvertColorsEnabled;
  final double textScaleFactor;
  final DateTime timestamp;

  const AccessibilityInfo({
    required this.isScreenReaderEnabled,
    required this.isBoldTextEnabled,
    required this.isReduceMotionEnabled,
    required this.isHighContrastEnabled,
    required this.isInvertColorsEnabled,
    required this.textScaleFactor,
    required this.timestamp,
  });

  bool get hasAccessibilityFeatures =>
      isScreenReaderEnabled ||
      isBoldTextEnabled ||
      isReduceMotionEnabled ||
      isHighContrastEnabled ||
      isInvertColorsEnabled ||
      textScaleFactor > 1.0;

  AccessibilityInfo copyWith({
    bool? isScreenReaderEnabled,
    bool? isBoldTextEnabled,
    bool? isReduceMotionEnabled,
    bool? isHighContrastEnabled,
    bool? isInvertColorsEnabled,
    double? textScaleFactor,
    DateTime? timestamp,
  }) {
    return AccessibilityInfo(
      isScreenReaderEnabled:
          isScreenReaderEnabled ?? this.isScreenReaderEnabled,
      isBoldTextEnabled: isBoldTextEnabled ?? this.isBoldTextEnabled,
      isReduceMotionEnabled:
          isReduceMotionEnabled ?? this.isReduceMotionEnabled,
      isHighContrastEnabled:
          isHighContrastEnabled ?? this.isHighContrastEnabled,
      isInvertColorsEnabled:
          isInvertColorsEnabled ?? this.isInvertColorsEnabled,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isScreenReaderEnabled': isScreenReaderEnabled,
      'isBoldTextEnabled': isBoldTextEnabled,
      'isReduceMotionEnabled': isReduceMotionEnabled,
      'isHighContrastEnabled': isHighContrastEnabled,
      'isInvertColorsEnabled': isInvertColorsEnabled,
      'textScaleFactor': textScaleFactor,
      'hasAccessibilityFeatures': hasAccessibilityFeatures,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
