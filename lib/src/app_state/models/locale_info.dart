// lib/src/app_state/models/locale_info.dart
import 'package:flutter/material.dart';

/// Locale and text direction information.
///
/// Tracks the current application locale, device locale, text direction
/// (LTR/RTL), and RTL language detection. Automatically detects RTL
/// languages: Arabic, Hebrew, Persian, Urdu, and Yiddish.
///
/// Example:
/// ```dart
/// final localeInfo = LocaleInfo.fromLocale(Locale('ar'));
/// print('Is RTL: ${localeInfo.isRTL}'); // true
/// print('Text direction: ${localeInfo.textDirection}'); // TextDirection.rtl
/// ```
class LocaleInfo {
  final Locale currentLocale;
  final Locale? deviceLocale;
  final TextDirection textDirection;
  final bool isRTL;
  final DateTime timestamp;

  const LocaleInfo({
    required this.currentLocale,
    this.deviceLocale,
    required this.textDirection,
    required this.isRTL,
    required this.timestamp,
  });

  LocaleInfo copyWith({
    Locale? currentLocale,
    Locale? deviceLocale,
    TextDirection? textDirection,
    bool? isRTL,
    DateTime? timestamp,
  }) {
    return LocaleInfo(
      currentLocale: currentLocale ?? this.currentLocale,
      deviceLocale: deviceLocale ?? this.deviceLocale,
      textDirection: textDirection ?? this.textDirection,
      isRTL: isRTL ?? this.isRTL,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory LocaleInfo.fromLocale(Locale? locale, {Locale? deviceLocale}) {
    final currentLocale = locale ?? const Locale('en');
    final isRTL = _isRTL(currentLocale.languageCode);
    final textDirection = isRTL ? TextDirection.rtl : TextDirection.ltr;

    return LocaleInfo(
      currentLocale: currentLocale,
      deviceLocale: deviceLocale,
      textDirection: textDirection,
      isRTL: isRTL,
      timestamp: DateTime.now(),
    );
  }

  static bool _isRTL(String languageCode) {
    const rtlLanguages = {'ar', 'he', 'fa', 'ur', 'yi', 'ji', 'iw'};
    return rtlLanguages.contains(languageCode);
  }

  Map<String, dynamic> toMap() {
    return {
      'currentLocale': currentLocale.languageCode,
      'deviceLocale': deviceLocale?.languageCode,
      'textDirection': textDirection.name,
      'isRTL': isRTL,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
