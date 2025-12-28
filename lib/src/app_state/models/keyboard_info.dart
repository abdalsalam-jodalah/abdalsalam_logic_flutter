// lib/src/app_state/models/keyboard_info.dart
class KeyboardInfo {
  final bool isVisible;
  final double height;
  final DateTime timestamp;

  const KeyboardInfo({
    required this.isVisible,
    required this.height,
    required this.timestamp,
  });

  KeyboardInfo copyWith({
    bool? isVisible,
    double? height,
    DateTime? timestamp,
  }) {
    return KeyboardInfo(
      isVisible: isVisible ?? this.isVisible,
      height: height ?? this.height,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isVisible': isVisible,
      'height': height,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
