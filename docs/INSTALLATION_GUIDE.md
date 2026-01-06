# Installation Guide - abdalsalam_logic_flutter

## Quick Start

### 1. Add Package Dependency

```yaml
dependencies:
  abdalsalam_logic_flutter: ^1.0.0
```

### 2. Choose Your Features

The package uses **modular architecture**. Add dependencies **only** for features you'll use:

```yaml
dependencies:
  abdalsalam_logic_flutter: ^1.0.0
  
  # Optional - Add based on features enabled
  connectivity_plus: ^5.0.2      # For enableConnectivity
  device_info_plus: ^9.1.1       # For enableDeviceInfo
  battery_plus: ^5.0.2           # For enableBattery
  network_info_plus: ^5.0.1      # For enableWiFi, enableMobileData
  disk_space_plus: ^0.2.2        # For enableStorage
  volume_controller: ^2.0.7      # For enableAudio
  permission_handler: ^12.0.1    # For enablePermissions
  package_info_plus: ^5.0.1      # For enableAppVersion
```

### 3. Configure App State

```dart
import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';

// Create logger
final logger = LoggerService();

// Configure features (enable only what you need)
final config = const AppStateConfig(
  // Core features (always available)
  enableAppLifecycle: true,
  enableDeviceInfo: true,
  enableConnectivity: true,
  
  // Optional features (add dependencies above)
  enableBattery: true,
  enableWiFi: true,
  enablePermissions: true,
);

// Create and initialize
final appStateManager = AppStateManagerImpl.create(logger, config: config);
await appStateManager.initialize();
```

## Platform-Specific Setup

### Android

#### AndroidManifest.xml

Add **only** the permissions for features you enabled:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
  <application>
    <!-- Your app config -->
  </application>
  
  <!-- For enableWiFi, enableMobileData, enableConnectivity -->
  <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
  <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
  
  <!-- For enablePermissions (add only what you'll request) -->
  <uses-permission android:name="android.permission.CAMERA" />
  <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
  <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
  
  <!-- Add other permissions as needed -->
</manifest>
```

### iOS

#### Info.plist

Add **only** the usage descriptions for features you enabled:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN">
<plist version="1.0">
<dict>
  <!-- For enableWiFi (iOS 13+) -->
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>We need location permission to access WiFi information</string>
  
  <!-- For enablePermissions - camera -->
  <key>NSCameraUsageDescription</key>
  <string>We need camera access for taking photos</string>
  
  <!-- Add other usage descriptions as needed -->
</dict>
</plist>
```

## Configuration Presets

### Minimal (Core Only)

```dart
// No optional dependencies needed
final config = const AppStateConfig.minimal();

// OR explicitly
final config = const AppStateConfig(
  enableAppLifecycle: true,
  enableDeviceInfo: true,
  enableConnectivity: true,
);
```

**Required Dependencies:** None (all built-in)  
**Permissions:** None

### Standard (Recommended for Production)

```dart
final config = const AppStateConfig(
  enableAppLifecycle: true,
  enableDeviceInfo: true,
  enableConnectivity: true,
  enableBattery: true,
  enableWiFi: true,
  enablePermissions: true,
  enableAppVersion: true,
);
```

**Required Dependencies:**
- `battery_plus: ^5.0.2`
- `network_info_plus: ^5.0.1`
- `permission_handler: ^12.0.1`
- `package_info_plus: ^5.0.1`

**Android Permissions:**
- `ACCESS_NETWORK_STATE`
- `ACCESS_WIFI_STATE`
- (Plus permissions you'll request via permission_handler)

### Full (All Features - Demos Only)

```dart
final config = const AppStateConfig.all();
```

**Required Dependencies:** All packages listed in section 2

**Android Permissions:** All network and feature permissions

## Verification

### Check Required Dependencies

```dart
final config = const AppStateConfig(
  enableBattery: true,
  enableWiFi: true,
);

// Get list of required packages
final dependencies = config.getRequiredDependencies();
print(dependencies);
// Output: ['battery_plus', 'network_info_plus']

// Get list of required Android permissions
final permissions = config.getRequiredPermissions();
print(permissions);
// Output: ['ACCESS_NETWORK_STATE', 'ACCESS_WIFI_STATE']
```

### Test Initialization

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final logger = LoggerService();
  final config = const AppStateConfig(
    enableBattery: true,
    enableWiFi: true,
  );
  
  final appStateManager = AppStateManagerImpl.create(logger, config: config);
  
  try {
    await appStateManager.initialize();
    print('✅ App State initialized successfully');
    
    // Test battery
    if (config.enableBattery) {
      final battery = appStateManager.batteryInfo;
      print('Battery level: ${battery?.batteryLevel}%');
    }
    
    // Test WiFi
    if (config.enableWiFi) {
      final wifi = appStateManager.wifiInfo;
      print('WiFi connected: ${wifi.isConnected}');
    }
  } catch (e) {
    print('❌ Initialization failed: $e');
  }
  
  runApp(MyApp());
}
```

## Common Issues

### Issue: MissingPluginException

**Cause:** Feature enabled but dependency not added to pubspec.yaml

**Solution:** Add the required dependency:
```yaml
dependencies:
  battery_plus: ^5.0.2  # If enableBattery: true
```

### Issue: Permission Denied

**Cause:** Android/iOS permissions not declared in manifest/plist

**Solution:** Add platform-specific permissions (see Platform-Specific Setup above)

### Issue: Feature Returns Null

**Cause:** Feature not enabled in AppStateConfig

**Solution:** Enable the feature:
```dart
const AppStateConfig(
  enableBattery: true,  // Add this
)
```

### Issue: App Size Too Large

**Cause:** Too many features enabled, bundling unnecessary dependencies

**Solution:** Enable only needed features:
```dart
// Before (all features - large app)
const AppStateConfig.all()

// After (only what's needed - smaller app)
const AppStateConfig(
  enableBattery: true,
  enableConnectivity: true,
)
```

## Next Steps

1. ✅ Install package and dependencies
2. ✅ Configure platform permissions
3. ✅ Create AppStateConfig with needed features
4. ✅ Initialize AppStateManager
5. 📚 Read [APP_STATE_DOCUMENTATION.md](./APP_STATE_DOCUMENTATION.md) for complete feature guide
6. 💡 Check [example/](./example/) folder for working demo
7. 🎨 Build your UI with reactive streams

## Support

- **Documentation:** [APP_STATE_DOCUMENTATION.md](./APP_STATE_DOCUMENTATION.md)
- **Architecture Guide:** [_ai_agent.md](./_ai_agent.md)
- **Example App:** [example/lib/main.dart](./example/lib/main.dart)
- **Changelog:** [CHANGELOG.md](./CHANGELOG.md)

---

**Ready to build? Start with minimal config and add features as needed! 🚀**
