// lib/src/app_state/models/device_info.dart
import 'package:flutter/material.dart';

/// Device type classification.
enum DeviceType {
  /// Mobile phone device.
  phone,

  /// Tablet device.
  tablet,

  /// Desktop computer (Windows, macOS, Linux).
  desktop,

  /// Web browser.
  web,
}

/// Operating system platform.
enum DeviceOS {
  /// Android operating system.
  android,

  /// iOS operating system.
  ios,

  /// Windows operating system.
  windows,

  /// macOS operating system.
  macos,

  /// Linux operating system.
  linux,

  /// Web platform.
  web,

  /// Unknown or unsupported platform.
  unknown,
}

/// Responsive breakpoint for adaptive UI design.
///
/// Breakpoints are based on screen width:
/// - [xs]: < 576px (phones portrait)
/// - [sm]: 576-768px (phones landscape, small tablets)
/// - [md]: 768-992px (tablets portrait)
/// - [lg]: 992-1200px (tablets landscape)
/// - [xl]: ≥ 1200px (desktop, large tablets)
enum ResponsiveBreakpoint {
  /// Extra small screens (< 576px).
  xs,

  /// Small screens (576-768px).
  sm,

  /// Medium screens (768-992px).
  md,

  /// Large screens (992-1200px).
  lg,

  /// Extra large screens (≥ 1200px).
  xl,
}

/// Comprehensive device information and screen metrics.
///
/// Provides detailed information about the device type, operating system,
/// screen dimensions, orientation, and system UI characteristics. This
/// information is automatically updated when device metrics change (e.g.,
/// orientation changes).
///
/// Example:
/// ```dart
/// final deviceInfo = appStateManager.deviceInfo;
/// if (deviceInfo != null) {
///   print('Device: ${deviceInfo.type.name} on ${deviceInfo.os.name}');
///   print('Screen: ${deviceInfo.screenSize.width}x${deviceInfo.screenSize.height}');
///   print('Breakpoint: ${deviceInfo.breakpoint.name}');
///   print('Has notch: ${deviceInfo.hasNotch}');
/// }
/// ```
class DeviceInfo {
  final DeviceType type;
  final DeviceOS os;
  final String? osVersion;
  final String? deviceModel;
  final String? deviceManufacturer;
  final Size screenSize;
  final double pixelRatio;
  final double textScaleFactor;
  final Orientation orientation;
  final ResponsiveBreakpoint breakpoint;
  final bool isLandscapeFirst;
  final EdgeInsets systemPadding;
  final EdgeInsets systemNavigationInsets;
  final bool hasSystemNavigation;
  final bool hasNotch;
  final bool hasPhysicalHomeButton;
  final double statusBarHeight;
  final double navigationBarHeight;
  final DateTime timestamp;

  const DeviceInfo({
    required this.type,
    required this.os,
    this.osVersion,
    this.deviceModel,
    this.deviceManufacturer,
    required this.screenSize,
    required this.pixelRatio,
    required this.textScaleFactor,
    required this.orientation,
    required this.breakpoint,
    required this.isLandscapeFirst,
    required this.systemPadding,
    required this.systemNavigationInsets,
    required this.hasSystemNavigation,
    required this.hasNotch,
    required this.hasPhysicalHomeButton,
    required this.statusBarHeight,
    required this.navigationBarHeight,
    required this.timestamp,
  });

  DeviceInfo copyWith({
    DeviceType? type,
    DeviceOS? os,
    String? osVersion,
    String? deviceModel,
    String? deviceManufacturer,
    Size? screenSize,
    double? pixelRatio,
    double? textScaleFactor,
    Orientation? orientation,
    ResponsiveBreakpoint? breakpoint,
    bool? isLandscapeFirst,
    EdgeInsets? systemPadding,
    EdgeInsets? systemNavigationInsets,
    bool? hasSystemNavigation,
    bool? hasNotch,
    bool? hasPhysicalHomeButton,
    double? statusBarHeight,
    double? navigationBarHeight,
    DateTime? timestamp,
  }) {
    return DeviceInfo(
      type: type ?? this.type,
      os: os ?? this.os,
      osVersion: osVersion ?? this.osVersion,
      deviceModel: deviceModel ?? this.deviceModel,
      deviceManufacturer: deviceManufacturer ?? this.deviceManufacturer,
      screenSize: screenSize ?? this.screenSize,
      pixelRatio: pixelRatio ?? this.pixelRatio,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      orientation: orientation ?? this.orientation,
      breakpoint: breakpoint ?? this.breakpoint,
      isLandscapeFirst: isLandscapeFirst ?? this.isLandscapeFirst,
      systemPadding: systemPadding ?? this.systemPadding,
      systemNavigationInsets:
          systemNavigationInsets ?? this.systemNavigationInsets,
      hasSystemNavigation: hasSystemNavigation ?? this.hasSystemNavigation,
      hasNotch: hasNotch ?? this.hasNotch,
      hasPhysicalHomeButton:
          hasPhysicalHomeButton ?? this.hasPhysicalHomeButton,
      statusBarHeight: statusBarHeight ?? this.statusBarHeight,
      navigationBarHeight: navigationBarHeight ?? this.navigationBarHeight,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'os': os.name,
      'osVersion': osVersion,
      'deviceModel': deviceModel,
      'deviceManufacturer': deviceManufacturer,
      'screenSize': {'width': screenSize.width, 'height': screenSize.height},
      'pixelRatio': pixelRatio,
      'textScaleFactor': textScaleFactor,
      'orientation': orientation.name,
      'breakpoint': breakpoint.name,
      'isLandscapeFirst': isLandscapeFirst,
      'systemPadding': {
        'top': systemPadding.top,
        'right': systemPadding.right,
        'bottom': systemPadding.bottom,
        'left': systemPadding.left,
      },
      'systemNavigationInsets': {
        'top': systemNavigationInsets.top,
        'right': systemNavigationInsets.right,
        'bottom': systemNavigationInsets.bottom,
        'left': systemNavigationInsets.left,
      },
      'hasSystemNavigation': hasSystemNavigation,
      'hasNotch': hasNotch,
      'hasPhysicalHomeButton': hasPhysicalHomeButton,
      'statusBarHeight': statusBarHeight,
      'navigationBarHeight': navigationBarHeight,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  bool get isPhone => type == DeviceType.phone;
  bool get isTablet => type == DeviceType.tablet;
  bool get isDesktop => type == DeviceType.desktop;
  bool get isWeb => type == DeviceType.web;
  bool get isLandscape => orientation == Orientation.landscape;
  bool get isPortrait => orientation == Orientation.portrait;
}
