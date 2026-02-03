# App State Management

**Version:** 1.0.0  
**Last Updated:** January 6, 2026  
**Package:** abdalsalam_logic_flutter

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Modular Configuration](#modular-configuration)
4. [Installation](#installation)
5. [State Domains](#state-domains)
6. [Usage Guide](#usage-guide)
7. [Refresh System](#refresh-system)
8. [Best Practices](#best-practices)
9. [API Reference](#api-reference)
10. [Examples](#examples)

---

## Overview

The App State Management system provides comprehensive, reactive tracking of 21+ different state domains in your Flutter application. It follows a **modular, opt-in architecture** where you only initialize and bundle the features you actually need.

### Key Features

✅ **21+ State Domains** - Track everything from connectivity to battery to keyboard  
✅ **Modular & Opt-In** - Only bundle features you enable  
✅ **Zero Impact** - Disabled features add no code to your bundle  
✅ **Reactive Streams** - Real-time updates via StreamControllers  
✅ **Type-Safe** - Strongly typed state models  
✅ **Memory Efficient** - Smart refresh system prevents over-polling  

### Recent Improvements

- ✅ **Memory Info**: Now uses `ProcessInfo.currentRss` for real-time, accurate memory values
- ✅ **Dynamic Updates**: Memory values update as app usage changes
- ✅ **Better Logging**: Enhanced memory pressure logs show actual used/free memory

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

### Component Structure

```
lib/src/app_state/
├── app_state_manager.dart              # Interface
├── app_state_manager_impl.dart         # Implementation
├── app_state_config.dart               # Configuration
└── models/
    ├── app_lifecycle_state.dart
    ├── connectivity_state.dart
    ├── device_info.dart
    ├── battery_info.dart
    ├── orientation_state.dart
    ├── screen_metrics.dart
    ├── wifi_info.dart
    ├── mobile_data_info.dart
    ├── vpn_info.dart
    ├── storage_info.dart
    ├── memory_info.dart
    ├── audio_state.dart
    ├── permission_state.dart
    ├── system_settings.dart
    ├── accessibility_state.dart
    ├── app_version_info.dart
    ├── runtime_info.dart
    └── keyboard_state.dart
```

---

## Modular Configuration

### AppStateConfig

Control which features are enabled using boolean flags. This determines:
- Which features are initialized
- Which dependencies are bundled
- Which permissions are requested

### Configuration Options

```dart
// Option 1: Enable ALL features (comprehensive tracking)
final config = AppStateConfig.all();

// Option 2: Minimal features (only core - no optional dependencies)
final config = AppStateConfig.minimal();

// Option 3: Custom configuration (RECOMMENDED)
final config = AppStateConfig(
  // Core features (usually enabled)
  enableAppLifecycle: true,      // App foreground/background
  enableDeviceInfo: true,         // Device model, OS version
  enableConnectivity: true,       // Online/offline status
  
  // Connectivity details
  enableWiFi: true,               // WiFi SSID, signal strength
  enableMobileData: true,         // Carrier, network type
  enableVPN: false,               // VPN connection status
  
  // Device state
  enableBattery: true,            // Battery level, charging
  enableOrientation: true,        // Portrait/landscape
  enableScreenMetrics: true,      // Screen size, DPI
  enableStorage: true,            // Disk space
  enableMemory: false,            // RAM usage
  enableAudio: false,             // Volume, audio mode
  
  // System
  enablePermissions: true,        // Permission status
  enableSystemSettings: true,     // Brightness, timezone
  enableAccessibility: false,     // A11y features
  
  // App metadata
  enableAppVersion: true,         // Version, build number
  enableAppRuntime: true,         // Uptime, launch count
  
  // UI state
  enableKeyboard: false,          // Keyboard visibility
);
```

### Dependency Mapping

Add **only** the dependencies for features you enable:

| Feature Flag | Required Package | Version | Purpose |
|--------------|-----------------|---------|---------|
| `enableBattery` | `battery_plus` | ^6.0.0 | Battery level & status |
| `enableWiFi` | `network_info_plus` | ^5.0.0 | WiFi SSID & IP |
| `enableMobileData` | `network_info_plus` | ^5.0.0 | Cellular info |
| `enableConnectivity` | `connectivity_plus` | ^6.0.0 | Network connectivity |
| `enableDeviceInfo` | `device_info_plus` | ^10.0.0 | Device details |
| `enableStorage` | `disk_space_plus` | ^0.2.0 | Disk space |
| `enablePermissions` | `permission_handler` | ^11.0.0 | Permission status |
| `enableAudio` | `volume_controller` | ^2.0.0 | Volume control |

**Note:** Core features (lifecycle, orientation, screen metrics, memory, keyboard) use Flutter SDK APIs only.

---

## State Domains

### 1. App Lifecycle

Track app foreground/background state:

```dart
class AppLifecycleState {
  final bool isInForeground;
  final bool isInBackground;
  final DateTime lastStateChange;
}
```

**Streams:**
- `appLifecycleStream` - State changes

**Use Cases:**
- Pause/resume logic
- Background task management
- Analytics tracking

---

### 2. Connectivity

Track online/offline status:

```dart
class ConnectivityState {
  final bool isConnected;
  final ConnectivityType type; // wifi, mobile, ethernet, none
}
```

**Streams:**
- `connectivityStream` - Connection changes

**Use Cases:**
- Offline mode
- Network-dependent features
- Download management

---

### 3. Device Info

Device details:

```dart
class DeviceInfo {
  final String model;
  final String manufacturer;
  final String osVersion;
  final bool isPhysicalDevice;
}
```

**Methods:**
- `deviceInfo` - Get device info

**Use Cases:**
- Analytics
- Device-specific UI
- Bug reports

---

### 4. Battery

Battery status:

```dart
class BatteryInfo {
  final int level;              // 0-100
  final bool isCharging;
  final BatteryState state;     // charging, full, discharging
}
```

**Streams:**
- `batteryStream` - Battery changes

**Use Cases:**
- Power-saving mode
- Background task scheduling
- User warnings

---

### 5. WiFi Info

WiFi details (requires `enableWiFi: true`):

```dart
class WiFiInfo {
  final String? ssid;
  final String? bssid;
  final String? ipAddress;
  final int? signalStrength;  // dBm
}
```

**Streams:**
- `wifiStream` - WiFi changes

**Use Cases:**
- Network diagnostics
- Location-based features
- Network quality monitoring

---

### 6. Mobile Data

Cellular info (requires `enableMobileData: true`):

```dart
class MobileDataInfo {
  final String? carrierName;
  final String? networkType;    // 4G, 5G, LTE
  final String? mobileCountryCode;
  final String? mobileNetworkCode;
}
```

**Streams:**
- `mobileDataStream` - Cellular changes

**Use Cases:**
- Carrier-specific features
- Network quality warnings
- Data usage tracking

---

### 7. VPN Status

VPN connection (requires `enableVPN: true`):

```dart
class VpnInfo {
  final bool isConnected;
}
```

**Streams:**
- `vpnStream` - VPN changes

**Use Cases:**
- Security features
- Network diagnostics
- Privacy indicators

---

### 8. Orientation

Screen orientation:

```dart
class OrientationState {
  final Orientation orientation;  // portrait, landscape
}
```

**Streams:**
- `orientationStream` - Orientation changes

**Use Cases:**
- Adaptive layouts
- Media playback
- Game controls

---

### 9. Screen Metrics

Screen dimensions:

```dart
class ScreenMetrics {
  final Size size;
  final double pixelRatio;
  final EdgeInsets padding;
  final EdgeInsets viewInsets;
  final EdgeInsets viewPadding;
}
```

**Streams:**
- `screenMetricsStream` - Screen changes

**Use Cases:**
- Responsive UI
- Keyboard handling
- Safe area calculation

---

### 10. Storage

Disk space (requires `enableStorage: true`):

```dart
class StorageInfo {
  final int totalSpace;         // bytes
  final int freeSpace;          // bytes
  final double usagePercentage; // 0-100
}
```

**Streams:**
- `storageStream` - Storage changes

**Use Cases:**
- Download management
- Cache cleanup
- Storage warnings

---

### 11. Memory

RAM usage (requires `enableMemory: true`):

```dart
class MemoryInfo {
  final int usedMemory;         // bytes (real-time via ProcessInfo)
  final int totalMemory;        // bytes
  final double usagePercentage; // 0-100
}
```

**Streams:**
- `memoryStream` - Memory changes

**Use Cases:**
- Performance monitoring
- Memory leak detection
- Resource optimization

---

### 12. Audio

Audio state (requires `enableAudio: true`):

```dart
class AudioState {
  final double volume;          // 0.0-1.0
  final bool isMuted;
  final AudioMode mode;         // normal, ringtone, in_call
}
```

**Streams:**
- `audioStream` - Audio changes

**Use Cases:**
- Media apps
- Volume controls
- Audio routing

---

### 13. Permissions

Permission status (requires `enablePermissions: true`):

```dart
class PermissionState {
  final Map<Permission, PermissionStatus> statuses;
}
```

**Methods:**
- `permissionState` - Get all permissions

**Use Cases:**
- Permission flows
- Feature availability
- User guidance

---

### 14. System Settings

System settings (requires `enableSystemSettings: true`):

```dart
class SystemSettings {
  final double brightness;      // 0.0-1.0
  final String timeZone;
  final String locale;
  final bool is24HourFormat;
}
```

**Streams:**
- `systemSettingsStream` - Settings changes

**Use Cases:**
- Theme adaptation
- Localization
- Time display

---

### 15. Accessibility

Accessibility features (requires `enableAccessibility: true`):

```dart
class AccessibilityState {
  final bool boldTextEnabled;
  final bool screenReaderEnabled;
  final double textScaleFactor;
}
```

**Streams:**
- `accessibilityStream` - A11y changes

**Use Cases:**
- Accessible UI
- Dynamic text sizing
- Screen reader support

---

### 16. App Version

App metadata (requires `enableAppVersion: true`):

```dart
class AppVersionInfo {
  final String version;
  final String buildNumber;
  final String packageName;
}
```

**Methods:**
- `appVersionInfo` - Get version info

**Use Cases:**
- Update prompts
- Analytics
- Support tickets

---

### 17. Runtime

App runtime info (requires `enableAppRuntime: true`):

```dart
class RuntimeInfo {
  final Duration uptime;
  final int launchCount;
  final DateTime firstLaunchDate;
  final DateTime lastLaunchDate;
}
```

**Streams:**
- `runtimeStream` - Runtime updates

**Use Cases:**
- Session tracking
- Performance metrics
- Onboarding logic

---

### 18. Keyboard

Keyboard visibility (requires `enableKeyboard: true`):

```dart
class KeyboardState {
  final bool isVisible;
  final double height;
}
```

**Streams:**
- `keyboardStream` - Keyboard changes

**Use Cases:**
- UI adjustments
- Scroll behavior
- Focus management

---

## Usage Guide

### Initialization

```dart
import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';

// 1. Create config
final config = AppStateConfig(
  enableBattery: true,
  enableWiFi: true,
  enableConnectivity: true,
);

// 2. Create manager
final appStateManager = AppStateManagerImpl.create(
  logger,
  config: config,
);

// 3. Initialize
await appStateManager.initialize();
```

### Listening to Streams

```dart
// Listen to connectivity
appStateManager.connectivityStream.listen((state) {
  if (!state.isConnected) {
    showOfflineMessage();
  }
});

// Listen to battery
appStateManager.batteryStream.listen((info) {
  if (info.level < 10 && !info.isCharging) {
    enablePowerSavingMode();
  }
});

// Listen to orientation
appStateManager.orientationStream.listen((state) {
  updateLayoutForOrientation(state.orientation);
});
```

### Getting Current State

```dart
// Get device info
final deviceInfo = await appStateManager.deviceInfo;
print('Running on: ${deviceInfo.model}');

// Get app version
final versionInfo = await appStateManager.appVersionInfo;
print('Version: ${versionInfo.version}');

// Get permission state
final permissionState = await appStateManager.permissionState;
if (permissionState.statuses[Permission.camera] != PermissionStatus.granted) {
  requestCameraPermission();
}
```

---

## Refresh System

### Manual Refresh

Force refresh specific states:

```dart
// Refresh battery
await appStateManager.refreshBattery();

// Refresh WiFi
await appStateManager.refreshWiFi();

// Refresh storage
await appStateManager.refreshStorage();

// Refresh all enabled features
await appStateManager.refreshAll();
```

### Automatic Refresh

Some states update automatically:
- **Connectivity**: Platform callbacks
- **Battery**: Platform callbacks
- **Orientation**: MediaQuery changes
- **Screen Metrics**: Window size changes
- **Keyboard**: MediaQuery changes

Others require manual refresh:
- **Storage**: Call `refreshStorage()`
- **Memory**: Call `refreshMemory()`
- **WiFi**: Updates with connectivity
- **Mobile Data**: Updates with connectivity

---

## Best Practices

### 1. Minimize Enabled Features

✅ **DO**: Only enable what you need
```dart
final config = AppStateConfig(
  enableConnectivity: true,
  enableBattery: true,
  // Only 2 features = minimal bundle size
);
```

❌ **DON'T**: Enable everything by default
```dart
final config = AppStateConfig.all(); // Heavy bundle!
```

### 2. Dispose Properly

✅ **DO**: Dispose when done
```dart
@override
void dispose() {
  appStateManager.dispose();
  super.dispose();
}
```

### 3. Handle Stream Errors

✅ **DO**: Listen for errors
```dart
appStateManager.batteryStream.listen(
  (info) => updateBatteryUI(info),
  onError: (error) => logError(error),
);
```

### 4. Use Build Context Carefully

✅ **DO**: Get MediaQuery from context
```dart
Widget build(BuildContext context) {
  final metrics = MediaQuery.of(context);
  // Use metrics.size, metrics.orientation, etc.
}
```

❌ **DON'T**: Store BuildContext
```dart
BuildContext? _context; // Bad!
```

### 5. Debounce Rapid Changes

✅ **DO**: Debounce high-frequency streams
```dart
appStateManager.screenMetricsStream
  .debounceTime(Duration(milliseconds: 100))
  .listen(updateUI);
```

### 6. Check Feature Availability

✅ **DO**: Check before using features
```dart
if (config.enableBattery) {
  final battery = await appStateManager.batteryInfo;
}
```

---

## API Reference

### AppStateManager Interface

#### Initialization
| Method | Returns | Description |
|--------|---------|-------------|
| `initialize()` | `Future<void>` | Initialize all enabled features |
| `dispose()` | `Future<void>` | Cleanup and close streams |

#### Streams
| Property | Type | Description |
|----------|------|-------------|
| `appLifecycleStream` | `Stream<AppLifecycleState>` | App foreground/background |
| `connectivityStream` | `Stream<ConnectivityState>` | Network connectivity |
| `batteryStream` | `Stream<BatteryInfo>` | Battery level/charging |
| `wifiStream` | `Stream<WiFiInfo>` | WiFi details |
| `mobileDataStream` | `Stream<MobileDataInfo>` | Cellular info |
| `vpnStream` | `Stream<VpnInfo>` | VPN status |
| `orientationStream` | `Stream<OrientationState>` | Screen orientation |
| `screenMetricsStream` | `Stream<ScreenMetrics>` | Screen dimensions |
| `storageStream` | `Stream<StorageInfo>` | Disk space |
| `memoryStream` | `Stream<MemoryInfo>` | RAM usage |
| `audioStream` | `Stream<AudioState>` | Volume/audio mode |
| `systemSettingsStream` | `Stream<SystemSettings>` | System settings |
| `accessibilityStream` | `Stream<AccessibilityState>` | A11y features |
| `runtimeStream` | `Stream<RuntimeInfo>` | App runtime |
| `keyboardStream` | `Stream<KeyboardState>` | Keyboard visibility |

#### Properties
| Property | Type | Description |
|----------|------|-------------|
| `deviceInfo` | `Future<DeviceInfo>` | Device details |
| `appVersionInfo` | `Future<AppVersionInfo>` | App version/build |
| `permissionState` | `Future<PermissionState>` | Permission statuses |

#### Refresh Methods
| Method | Returns | Description |
|--------|---------|-------------|
| `refreshBattery()` | `Future<void>` | Refresh battery info |
| `refreshWiFi()` | `Future<void>` | Refresh WiFi info |
| `refreshMobileData()` | `Future<void>` | Refresh cellular info |
| `refreshStorage()` | `Future<void>` | Refresh disk space |
| `refreshMemory()` | `Future<void>` | Refresh RAM usage |
| `refreshAudio()` | `Future<void>` | Refresh audio state |
| `refreshAll()` | `Future<void>` | Refresh all enabled |

---

## Examples

### Example 1: Network-Aware App

```dart
class NetworkAwareApp extends StatefulWidget {
  @override
  _NetworkAwareAppState createState() => _NetworkAwareAppState();
}

class _NetworkAwareAppState extends State<NetworkAwareApp> {
  late AppStateManager _stateManager;
  bool _isOnline = true;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize with connectivity only
    _stateManager = AppStateManagerImpl.create(
      logger,
      config: AppStateConfig(enableConnectivity: true),
    );
    
    _stateManager.initialize();
    
    // Listen to connectivity
    _stateManager.connectivityStream.listen((state) {
      setState(() {
        _isOnline = state.isConnected;
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: _isOnline
          ? OnlineContent()
          : OfflineMessage(),
      ),
    );
  }
  
  @override
  void dispose() {
    _stateManager.dispose();
    super.dispose();
  }
}
```

### Example 2: Battery-Conscious App

```dart
class BatteryAwareService {
  final AppStateManager _stateManager;
  bool _isPowerSavingMode = false;
  
  BatteryAwareService(this._stateManager) {
    _stateManager.batteryStream.listen((battery) {
      // Enable power saving at 20% if not charging
      _isPowerSavingMode = 
        battery.level <= 20 && !battery.isCharging;
      
      if (_isPowerSavingMode) {
        reduceBackgroundActivity();
        lowerRefreshRate();
      } else {
        restoreNormalActivity();
      }
    });
  }
  
  void reduceBackgroundActivity() {
    // Reduce polling intervals
    // Disable animations
    // Stop background sync
  }
  
  void restoreNormalActivity() {
    // Restore normal intervals
    // Enable animations
    // Resume background sync
  }
}
```

### Example 3: Responsive UI

```dart
class ResponsiveWidget extends StatelessWidget {
  final AppStateManager stateManager;
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<OrientationState>(
      stream: stateManager.orientationStream,
      builder: (context, snapshot) {
        final isPortrait = snapshot.data?.orientation == Orientation.portrait;
        
        return StreamBuilder<ScreenMetrics>(
          stream: stateManager.screenMetricsStream,
          builder: (context, metricsSnapshot) {
            final metrics = metricsSnapshot.data;
            final isSmallScreen = metrics != null && 
              metrics.size.width < 600;
            
            if (isPortrait && isSmallScreen) {
              return MobilePortraitLayout();
            } else if (isPortrait) {
              return TabletPortraitLayout();
            } else if (isSmallScreen) {
              return MobileLandscapeLayout();
            } else {
              return TabletLandscapeLayout();
            }
          },
        );
      },
    );
  }
}
```

### Example 4: Storage Management

```dart
class StorageManager {
  final AppStateManager _stateManager;
  
  StorageManager(this._stateManager) {
    _stateManager.storageStream.listen((storage) {
      if (storage.usagePercentage > 90) {
        showStorageWarning();
        suggestCleanup();
      }
    });
  }
  
  Future<bool> canDownloadFile(int fileSizeBytes) async {
    await _stateManager.refreshStorage();
    final storage = await _stateManager.storageStream.first;
    
    return storage.freeSpace > fileSizeBytes * 1.2; // 20% buffer
  }
  
  Future<void> cleanupCache() async {
    await clearTempFiles();
    await _stateManager.refreshStorage();
  }
}
```

### Example 5: Permission Flow

```dart
class PermissionManager {
  final AppStateManager _stateManager;
  
  Future<bool> requestCameraAccess() async {
    // Check current status
    final permState = await _stateManager.permissionState;
    final cameraStatus = permState.statuses[Permission.camera];
    
    if (cameraStatus == PermissionStatus.granted) {
      return true;
    }
    
    if (cameraStatus == PermissionStatus.permanentlyDenied) {
      showOpenSettingsDialog();
      return false;
    }
    
    // Request permission
    final result = await Permission.camera.request();
    return result == PermissionStatus.granted;
  }
}
```

---

## Summary

The App State Management system provides:

✅ **21+ state domains** for comprehensive app monitoring  
✅ **Modular architecture** - only bundle what you need  
✅ **Reactive streams** - real-time updates  
✅ **Type-safe** - strongly typed models  
✅ **Production-ready** - battle-tested implementation  

**Start with core features**, add more as needed, and build apps that adapt to device state automatically.
