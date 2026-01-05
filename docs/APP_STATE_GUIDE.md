# App State Management - Complete Guide

**Last Updated**: January 5, 2026

## Recent Improvements

- ✅ **Memory Info**: Now uses `ProcessInfo.currentRss` for real-time, accurate memory values instead of hardcoded estimates
- ✅ **Dynamic Updates**: Memory values now update dynamically as app usage changes
- ✅ **Better Logging**: Enhanced memory pressure logs show actual used/free memory values

---

## Overview

The App State Management system provides comprehensive, reactive tracking of 21+ different state domains in your Flutter application. It follows a **modular, opt-in architecture** where you only initialize and bundle the features you actually need.

## Table of Contents

- [Architecture](#architecture)
- [Modular Configuration](#modular-configuration)
- [Installation](#installation)
- [State Domains](#state-domains)
- [Usage Examples](#usage-examples)
- [Refresh System](#refresh-system)
- [Best Practices](#best-practices)

---

## Architecture

### Design Principles

1. **Modular & Opt-In**: Only initialize features you need via `AppStateConfig`
2. **Zero Impact**: Disabled features add no code/dependencies to your bundle
3. **Reactive Streams**: All state changes broadcast via StreamControllers
4. **Interface-Based**: SOLID principles with clear contracts
5. **Provider-Agnostic**: Uses StreamController directly (no dependency on provider packages)

### Core Components

```
AppStateManager (Interface)
    ↓
AppStateManagerImpl (Implementation)
    ↓
AppStateConfig (Configuration)
    ↓
21+ State Models (MobileDataInfo, WiFiInfo, BatteryInfo, etc.)
```

---

## Modular Configuration

### AppStateConfig

Control which features are enabled using boolean flags:

```dart
// Option 1: Enable ALL features (comprehensive tracking)
final config = AppStateConfig.all();

// Option 2: Minimal features (only core)
final config = AppStateConfig.minimal();

// Option 3: Custom configuration (recommended)
final config = AppStateConfig(
  // Core features (usually enabled)
  enableAppLifecycle: true,
  enableDeviceInfo: true,
  enableConnectivity: true,
  
  // Connectivity details
  enableWiFi: true,
  enableMobileData: true,
  enableVPN: false,
  
  // Device state
  enableBattery: true,
  enableOrientation: true,
  enableScreenMetrics: true,
  enableStorage: true,
  enableMemory: false,  // Disable if not needed
  enableAudio: false,    // Disable if not needed
  
  // System
  enablePermissions: true,
  enableSystemSettings: true,
  enableAccessibility: false,
  
  // App metadata
  enableAppVersion: true,
  enableAppRuntime: true,
  
  // UI state
  enableKeyboard: false,
);

// Initialize with config
final appStateManager = AppStateManagerImpl.create(logger, config: config);
await appStateManager.initialize();
```

### Required Dependencies

The package automatically handles dependencies based on your configuration. Here's what gets used for each feature:

| Feature | Required Package | Version |
|---------|-----------------|---------|
| `enableConnectivity` | connectivity_plus | ^5.0.2 |
| `enableDeviceInfo` | device_info_plus | ^9.1.1 |
| `enablePermissions` | permission_handler | ^12.0.1 |
| `enableBattery` | battery_plus | ^5.0.2 |
| `enableWiFi` / `enableMobileData` | network_info_plus | ^5.0.1 |
| `enableStorage` | disk_space_plus | ^0.2.2 |
| `enableAudio` | volume_controller | ^2.0.7 |
| `enableAppVersion` | package_info_plus | ^5.0.1 |

**Note**: Only packages for enabled features need to be in your `pubspec.yaml`.

---

## Installation

### Step 1: Add to pubspec.yaml

```yaml
dependencies:
  abdalsalam_logic_flutter:
    path: ../abdalsalam_logic_flutter  # or use git URL

  # Add only packages for features you'll enable
  connectivity_plus: ^5.0.2
  device_info_plus: ^9.1.1
  battery_plus: ^5.0.2
  network_info_plus: ^5.0.1
  disk_space_plus: ^0.2.2
  volume_controller: ^2.0.7
  permission_handler: ^12.0.1
  package_info_plus: ^5.0.1
```

### Step 2: Platform Configuration

**Android** (`android/app/src/main/AndroidManifest.xml`):

```xml
<manifest>
    <!-- Add permissions for features you'll use -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>
    <uses-permission android:name="android.permission.BATTERY_STATS"/>
    
    <!-- Add more as needed based on config -->
</manifest>
```

**iOS** (`ios/Runner/Info.plist`):

```xml
<dict>
    <!-- Add usage descriptions for permissions -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>We need location access for [your reason]</string>
    <!-- Add more as needed -->
</dict>
```

### Step 3: Initialize

```dart
import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Create logger
  final logger = LoggerServiceImpl();
  
  // Create custom config
  final config = AppStateConfig(
    enableAppLifecycle: true,
    enableDeviceInfo: true,
    enableConnectivity: true,
    enableBattery: true,
    enableWiFi: true,
    enableMobileData: true,
    enableStorage: true,
    enablePermissions: true,
    enableAppVersion: true,
  );
  
  // Initialize app state manager
  final appStateManager = AppStateManagerImpl.create(logger, config: config);
  await appStateManager.initialize();
  
  runApp(MyApp(appStateManager: appStateManager));
}
```

---

## State Domains

### 1. App Lifecycle

**Feature Flag**: `enableAppLifecycle`

Tracks app lifecycle states and focus changes.

**States**:
- `appStart` - Initial launch
- `appInit` - Initialization phase
- `appForegroundOnline` - Active and connected
- `appForegroundOffline` - Active but offline
- `appBackgroundOnline` - Background with connection
- `appBackgroundOffline` - Background without connection
- `appKill` - App termination

**Usage**:
```dart
appStateManager.stateStream.listen((state) {
  print('State: ${state.lifecycle.name}');
  print('Online: ${state.isOnline}');
  print('Foreground: ${state.isForeground}');
  
  if (state.lifecycle == AppLifecycleState.appForegroundOnline) {
    // Sync data when app becomes active and online
    syncData();
  }
});
```

### 2. Device Info

**Feature Flag**: `enableDeviceInfo`

Comprehensive device information including type, OS, screen metrics, and responsive breakpoints.

**Data Provided**:
- Device type (phone/tablet/desktop)
- OS and version
- Screen size and pixel ratio
- Orientation
- System navigation/notch detection
- Responsive breakpoints (xs/sm/md/lg/xl)

**Usage**:
```dart
final device = appStateManager.deviceInfo;
if (device != null) {
  print('Type: ${device.type.name}');
  print('OS: ${device.os.name} ${device.osVersion}');
  print('Model: ${device.deviceModel}');
  print('Screen: ${device.screenSize.width}x${device.screenSize.height}');
  print('Breakpoint: ${device.breakpoint.name}');
  print('Has Notch: ${device.hasNotch}');
  
  // Adaptive UI
  if (device.isTablet) {
    // Tablet layout
  } else if (device.breakpoint.index >= ResponsiveBreakpoint.lg.index) {
    // Desktop layout
  }
}
```

### 3. Connectivity

**Feature Flag**: `enableConnectivity`

Real-time network connectivity monitoring.

**Usage**:
```dart
appStateManager.stateStream.listen((state) {
  if (state.isOnline) {
    print('Connected to internet');
  } else {
    print('Offline');
  }
});
```

### 4. WiFi Info

**Feature Flag**: `enableWiFi`  
**Dependencies**: `connectivity_plus`, `network_info_plus`

Detailed WiFi connection information.

**Data Provided**:
- Connection status
- SSID (network name)
- BSSID (router MAC)
- IP address
- Gateway IP
- Subnet mask
- Signal strength (dBm)
- Signal quality (computed: excellent/good/fair/poor)
- Link speed (Mbps)
- Frequency (MHz)
- Security type

**Usage**:
```dart
appStateManager.wifiStream.listen((wifi) {
  if (wifi.isConnected) {
    print('WiFi: ${wifi.ssid}');
    print('IP: ${wifi.ipAddress}');
    print('Signal: ${wifi.signalQuality} (${wifi.signalStrength} dBm)');
    print('Speed: ${wifi.linkSpeed} Mbps');
    print('Frequency: ${wifi.frequency} MHz');
    print('Security: ${wifi.securityType}');
  }
});

// Manual refresh
await appStateManager.refreshWiFi();
```

### 5. Mobile Data Info

**Feature Flag**: `enableMobileData`  
**Dependencies**: `connectivity_plus`, `network_info_plus`

Cellular/mobile data connection tracking (separate from WiFi).

**Data Provided**:
- Connection status
- Data type (2G/3G/4G/5G/unknown)
- Signal strength (dBm)
- Signal quality (excellent/good/fair/poor)
- Signal percentage (0-100%)
- Operator name
- ISO country code
- Mobile network code (MNC)
- Mobile country code (MCC)

**Usage**:
```dart
appStateManager.mobileDataStream.listen((mobileData) {
  if (mobileData.isConnected) {
    print('Mobile Data: ${mobileData.dataTypeDisplay}');
    print('Operator: ${mobileData.operatorName}');
    print('Signal: ${mobileData.signalQuality}');
    print('Strength: ${mobileData.signalPercentage}%');
  }
});

// Manual refresh
await appStateManager.refreshMobileData();
```

### 6. VPN Info

**Feature Flag**: `enableVPN`

VPN connection detection (platform-dependent).

**Usage**:
```dart
final vpn = appStateManager.vpnInfo;
if (vpn.isConnected) {
  print('VPN active');
}
```

### 7. Battery Info

**Feature Flag**: `enableBattery`  
**Dependencies**: `battery_plus`

Real-time battery monitoring with live updates.

**Data Provided**:
- Battery level (0-100%)
- Battery state (charging/discharging/full/unknown)
- Power mode
- Battery health
- Temperature (°C)
- Voltage (mV)
- Technology (Li-ion, etc.)
- Charging source (AC/USB/wireless)
- Capacity (mAh)
- Current (μA)

**Usage**:
```dart
appStateManager.batteryStream.listen((battery) {
  if (battery != null) {
    print('Level: ${battery.batteryLevel}%');
    print('State: ${battery.batteryState.name}');
    print('Health: ${battery.health.name}');
    print('Temperature: ${battery.temperature}°C');
    print('Voltage: ${battery.voltage} mV');
    
    if (battery.isCharging) {
      print('Charging via ${battery.chargingSource?.name}');
    }
    
    if (battery.isLowBattery) {
      showLowBatteryWarning();
    }
  }
});

// Manual refresh
await appStateManager.refreshBattery();
```

### 8. Storage Info

**Feature Flag**: `enableStorage`  
**Dependencies**: `disk_space_plus`

Device storage space monitoring.

**Data Provided**:
- Total space (bytes/GB)
- Free space (bytes/GB)
- Used space (bytes/GB)
- Usage percentage

**Usage**:
```dart
appStateManager.storageStream.listen((storage) {
  print('Total: ${storage.totalSpaceGB.toStringAsFixed(2)} GB');
  print('Free: ${storage.freeSpaceGB.toStringAsFixed(2)} GB');
  print('Used: ${storage.usagePercentage.toStringAsFixed(1)}%');
  
  if (storage.isLowSpace) {
    showLowStorageWarning();
  }
});

// Manual refresh
await appStateManager.refreshStorage();
```

### 9. Memory Info

**Feature Flag**: `enableMemory`

Real-time system memory tracking and pressure monitoring using live process data.

**Data Provided**:
- Pressure level (normal/warning/critical)
- Total memory (bytes/MB/GB)
- Free memory (bytes/MB/GB)
- Used memory (bytes/MB/GB) - **Live data from ProcessInfo.currentRss**
- Usage percentage
- Available memory
- Memory status (Healthy/Moderate/High/Critical)

**How It Works**:
- Uses `ProcessInfo.currentRss` to read actual app process memory consumption
- Memory values update dynamically based on real system usage
- Pressure level automatically detected by Flutter framework
- Values change as app memory usage grows or shrinks

**Usage**:
```dart
appStateManager.memoryStream.listen((memory) {
  print('Pressure: ${memory.pressureLevel.name}');
  print('Used: ${memory.usedMemoryMB} (real-time)');
  print('Free: ${memory.freeMemoryMB}');
  print('Total: ${memory.totalMemoryGB}');
  print('Status: ${memory.memoryStatus}');
  print('Usage: ${memory.memoryUsagePercentage?.toStringAsFixed(1)}%');
  
  if (memory.shouldReduceMemoryUsage) {
    // Memory pressure detected
    freeUpResources();
    clearCaches();
  }
  
  if (memory.pressureLevel == MemoryPressureLevel.critical) {
    // Critical memory situation
    forceGarbageCollection();
  }
});

// Manual refresh to get latest values
await appStateManager.refreshMemory();
```

**Memory Status Indicators**:
- 🟢 **Healthy** - Usage < 60%
- 🟡 **Moderate** - Usage 60-79%
- 🟠 **High** - Usage 80-89%
- 🔴 **Critical** - Usage ≥ 90%

### 10. Audio State

**Feature Flag**: `enableAudio`  
**Dependencies**: `volume_controller`

Real-time audio volume monitoring with live listener.

**Data Provided**:
- Volume level (0-15)
- Max volume
- Output type (speaker/headphones/bluetooth)
- Mute status

**Usage**:
```dart
appStateManager.audioStateStream.listen((audio) {
  print('Volume: ${audio.volumeLevel}/${audio.maxVolume}');
  print('Percentage: ${audio.volumePercentage.toStringAsFixed(0)}%');
  print('Output: ${audio.outputType.name}');
  print('Muted: ${audio.isMuted}');
});

// Manual refresh
await appStateManager.refreshAudio();
```

### 11. Device Orientation

**Feature Flag**: `enableOrientation`

Screen orientation tracking.

**Data Provided**:
- Current orientation (portrait/landscape)
- Boolean helpers (isPortrait, isLandscape)

**Usage**:
```dart
appStateManager.deviceOrientationStream.listen((orientation) {
  print('Orientation: ${orientation.currentOrientation.name}');
  
  if (orientation.isLandscape) {
    // Show landscape-specific UI
  }
});
```

### 12. Screen Metrics

**Feature Flag**: `enableScreenMetrics`

Detailed screen measurements.

**Data Provided**:
- Pixel ratio
- DPI
- View insets (top/bottom/left/right)
- View padding (safe areas)

**Usage**:
```dart
final metrics = appStateManager.screenMetricsInfo;
print('Pixel Ratio: ${metrics.pixelRatio}');
print('DPI: ${metrics.dpi}');
print('Safe area top: ${metrics.viewPaddingTop}');
```

### 13. App Version

**Feature Flag**: `enableAppVersion`  
**Dependencies**: `package_info_plus`

App version and build information.

**Data Provided**:
- App name
- Version number
- Build number
- Package name

**Usage**:
```dart
final version = appStateManager.appVersionInfo;
print('App: ${version.appName}');
print('Version: ${version.version}+${version.buildNumber}');
print('Package: ${version.packageName}');
```

### 14. App Runtime

**Feature Flag**: `enableAppRuntime`

Tracks how long the app has been running.

**Usage**:
```dart
final runtime = appStateManager.appRuntimeInfo;
print('Running for: ${runtime.runDuration.inMinutes} minutes');
```

### 15. System Settings

**Feature Flag**: `enableSystemSettings`

System-level settings detection.

**Data Provided**:
- Low power mode
- Airplane mode
- Dark mode enabled

**Usage**:
```dart
final settings = appStateManager.systemSettingsInfo;
if (settings.isLowPowerMode) {
  disableBackgroundSync();
}
if (settings.isDarkModeEnabled) {
  applyDarkTheme();
}
```

### 16. Permissions

**Feature Flag**: `enablePermissions`  
**Dependencies**: `permission_handler`

Comprehensive permission status tracking for 25+ permission types.

**Permissions Tracked**:
- Camera, Microphone, Location (always/when in use)
- Calendar, Contacts, Photos, Videos, Storage
- Notifications, Phone, SMS, Sensors
- Bluetooth (scan/advertise/connect)
- Activity recognition, Schedule, App tracking

**Usage**:
```dart
appStateManager.permissionsStream.listen((permissions) {
  final camera = permissions.getPermission(PermissionType.camera);
  if (camera != null && camera.isGranted) {
    enableCameraFeature();
  }
  
  final location = permissions.getPermission(PermissionType.location);
  if (location != null && location.isDenied) {
    requestLocationPermission();
  }
});

// Update single permission
appStateManager.updatePermission(PermissionInfo(
  type: PermissionType.camera,
  status: PermissionStatus.granted,
  isGranted: true,
));

// Manual refresh all
await appStateManager.refreshPermissions();
```

### 17. Keyboard Info

**Feature Flag**: `enableKeyboard`

Keyboard visibility and height tracking.

**Usage**:
```dart
appStateManager.keyboardStream.listen((keyboard) {
  if (keyboard != null && keyboard.isVisible) {
    print('Keyboard height: ${keyboard.height}');
    adjustUIForKeyboard(keyboard.height);
  }
});
```

### 18. Network Type

**Feature Flag**: `enableNetworkType`

Network type detection (WiFi/Mobile/Ethernet/etc).

**Usage**:
```dart
appStateManager.networkStream.listen((network) {
  if (network != null) {
    print('Network type: ${network.type.name}');
  }
});
```

### 19. Accessibility

**Feature Flag**: `enableAccessibility`

Accessibility features detection.

**Data Provided**:
- Screen reader enabled
- Bold text enabled
- Reduce motion enabled
- High contrast enabled
- Invert colors enabled
- Text scale factor

**Usage**:
```dart
final accessibility = appStateManager.accessibilityInfo;
if (accessibility != null) {
  if (accessibility.isReduceMotionEnabled) {
    disableAnimations();
  }
  if (accessibility.isScreenReaderEnabled) {
    improveAccessibilityLabels();
  }
}
```

### 20. Navigation State

**Always Enabled** (Core feature)

Route and tab navigation tracking.

**Usage**:
```dart
// Listen to navigation
appStateManager.navigationStream.listen((nav) {
  print('Route: ${nav.currentRoute}');
  print('Params: ${nav.routeParams}');
  print('History: ${nav.routeHistory}');
  print('Tab: ${nav.currentTabIndex}');
});

// Update navigation
appStateManager.updateNavigation('/products', params: {'id': '123'});
appStateManager.updateTab(1, '/inbox');
```

### 21. Theme & Locale

**Always Enabled** (Core features)

Theme mode and locale management.

**Usage**:
```dart
// Theme
appStateManager.themeStream.listen((theme) {
  applyTheme(theme);
});
appStateManager.updateTheme(ThemeMode.dark);

// Locale
appStateManager.localeStream.listen((locale) {
  print('Language: ${locale.currentLocale.languageCode}');
  print('RTL: ${locale.isRTL}');
});
appStateManager.updateLocale(Locale('ar'));
```

---

## Refresh System

All state domains support manual refresh for pulling latest device data.

### Global Refresh

Refresh all enabled features at once:

```dart
await appStateManager.refreshAll();
```

### Individual Refresh

Refresh specific domains:

```dart
await appStateManager.refreshWiFi();
await appStateManager.refreshMobileData();
await appStateManager.refreshBattery();
await appStateManager.refreshStorage();
await appStateManager.refreshAudio();
await appStateManager.refreshMemory();
await appStateManager.refreshPermissions();
```

### UI Integration

```dart
RefreshIndicator(
  onRefresh: () => appStateManager.refreshAll(),
  child: YourContent(),
)

// Or individual buttons
ElevatedButton(
  onPressed: () => appStateManager.refreshWiFi(),
  child: Text('Refresh WiFi'),
)
```

---

## Best Practices

### 1. Enable Only What You Need

```dart
// ❌ Bad: Enable everything
final config = AppStateConfig.all();

// ✅ Good: Enable specific features
final config = AppStateConfig(
  enableAppLifecycle: true,
  enableDeviceInfo: true,
  enableConnectivity: true,
  enableBattery: true,
  // Only features you'll actually use
);
```

### 2. Dispose Properly

```dart
@override
void dispose() {
  appStateManager.dispose();
  super.dispose();
}
```

### 3. Use Streams Efficiently

```dart
// ❌ Bad: Create multiple listeners
appStateManager.batteryStream.listen(...);
appStateManager.batteryStream.listen(...);

// ✅ Good: Use single listener or StreamBuilder
StreamBuilder<BatteryInfo>(
  stream: appStateManager.batteryStream,
  initialData: appStateManager.batteryInfo,
  builder: (context, snapshot) {
    // UI based on battery
  },
)
```

### 4. Handle Null States

```dart
// Some features may be null if not enabled
final battery = appStateManager.batteryInfo;
if (battery != null) {
  // Use battery info
}
```

### 5. Platform-Specific Handling

```dart
if (!kIsWeb && Platform.isAndroid) {
  // Android-specific code
} else if (!kIsWeb && Platform.isIOS) {
  // iOS-specific code
}
```

### 6. Performance Optimization

```dart
// Refresh only when needed (e.g., on pull-to-refresh)
// Avoid continuous polling unless necessary

// Use debouncing for frequent updates
stream.debounceTime(Duration(milliseconds: 500))
  .listen((data) {
    // Handle debounced updates
  });
```

---

## Complete Example

See [`example/lib/main.dart`](../example/lib/main.dart) for a complete working example demonstrating all 21 state domains with UI integration.

---

## Troubleshooting

### WiFi info returns null on Android

Ensure you have location permission:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
```

### Battery info not updating

Check that `battery_plus` is properly initialized and platform permissions are granted.

### Compilation errors

Ensure all required dependencies for your enabled features are in `pubspec.yaml`.

---

## API Reference

For detailed API documentation, see:
- [AppStateManager Interface](../lib/src/app_state/app_state_manager.dart)
- [AppStateConfig](../lib/src/app_state/app_state_config.dart)
- [All State Models](../lib/src/app_state/models/)

---

## License

This package is licensed under the MIT License. See LICENSE file for details.
