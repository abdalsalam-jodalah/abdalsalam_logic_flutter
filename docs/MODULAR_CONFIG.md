# Modular App State Configuration

## Overview

The AppStateManager is designed with a **modular, opt-in architecture** that ensures:
- ✅ **Zero unnecessary dependencies** are bundled into your app
- ✅ **No permissions requested** for unused features
- ✅ **App store compliance** - only request permissions for features you actually use
- ✅ **Minimal app size** and resource usage
- ✅ **Each feature independently** enabled/disabled via configuration

## Quick Start

### Minimal Configuration (Core Features Only)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final logger = LoggerServiceImpl();
  
  // Only core features enabled - minimal permissions
  const config = AppStateConfig.minimal();
  
  final appStateManager = AppStateManagerImpl.create(logger, config: config);
  await appStateManager.initialize();
  
  runApp(MyApp(appStateManager: appStateManager));
}
```

**Minimal config includes:**
- App lifecycle tracking
- Device info (OS, model)
- Connectivity status

**No extra permissions required!**

---

### Custom Configuration (Pick What You Need)

```dart
const config = AppStateConfig(
  // Core features (always recommended)
  enableAppLifecycle: true,
  enableDeviceInfo: true,
  enableConnectivity: true,
  
  // Device monitoring (opt-in)
  enableBattery: true,      // Requires: battery_plus package
  enableWiFi: true,         // Requires: network_info_plus, location permissions
  enableStorage: true,      // Requires: disk_space_plus
  
  // UI/Display features (opt-in)
  enableOrientation: true,  // No extra permissions
  enableScreenMetrics: true,
  enableKeyboard: true,
  
  // System features (opt-in)
  enablePermissions: true,  // Requires: permission_handler
  enableAudio: true,        // Requires: volume_controller
  enableMemory: true,
  
  // App info (opt-in)
  enableAppVersion: true,   // Requires: package_info_plus
  enableAppRuntime: true,
);
```

---

### All Features Enabled (For Testing/Demo)

```dart
const config = AppStateConfig.all();
```

**⚠️ Only use this for demo/testing! In production, only enable what you need.**

---

## Feature Modules & Dependencies

| Feature | Config Flag | Required Package | Platform Permissions |
|---------|------------|------------------|---------------------|
| **Core Features** ||||
| App Lifecycle | `enableAppLifecycle` | ✅ Built-in | None |
| Device Info | `enableDeviceInfo` | `device_info_plus` | None |
| Connectivity | `enableConnectivity` | `connectivity_plus` | `ACCESS_NETWORK_STATE` |
| **Device State** ||||
| Battery | `enableBattery` | `battery_plus` | None |
| WiFi | `enableWiFi` | `network_info_plus` | `ACCESS_FINE_LOCATION`, `ACCESS_WIFI_STATE` |
| VPN | `enableVPN` | ✅ Built-in | None |
| Audio | `enableAudio` | `volume_controller` | None |
| Storage | `enableStorage` | `disk_space_plus` | `READ_EXTERNAL_STORAGE` (Android 10-) |
| Memory | `enableMemory` | ✅ Built-in | None |
| **UI/Display** ||||
| Orientation | `enableOrientation` | ✅ Built-in | None |
| Screen Metrics | `enableScreenMetrics` | ✅ Built-in | None |
| Keyboard | `enableKeyboard` | ✅ Built-in | None |
| **System** ||||
| Permissions | `enablePermissions` | `permission_handler` | Varies by permission |
| System Settings | `enableSystemSettings` | ✅ Built-in | None |
| Accessibility | `enableAccessibility` | ✅ Built-in | None |
| **App Info** ||||
| App Version | `enableAppVersion` | `package_info_plus` | None |
| App Runtime | `enableAppRuntime` | ✅ Built-in | None |
| **Network** ||||
| Network Type | `enableNetworkType` | `connectivity_plus` | `ACCESS_NETWORK_STATE` |

---

## Configuration Helpers

### Get Required Permissions

```dart
const config = AppStateConfig(
  enableWiFi: true,
  enableStorage: true,
);

// Get list of required Android permissions
final permissions = config.getRequiredPermissions();
// Returns: ['android.permission.ACCESS_WIFI_STATE', 
//           'android.permission.ACCESS_FINE_LOCATION', ...]
```

### Get Required Dependencies

```dart
final dependencies = config.getRequiredDependencies();
// Returns: ['connectivity_plus', 'network_info_plus', 'disk_space_plus', ...]
```

---

## Usage Examples

### Example 1: E-Commerce App (Minimal)

```dart
// Only need core features + app version for updates
const config = AppStateConfig(
  enableAppLifecycle: true,
  enableDeviceInfo: true,
  enableConnectivity: true,
  enableAppVersion: true,
);
```

**Result:** Minimal permissions, no location/storage access needed.

---

### Example 2: Fitness Tracker

```dart
// Need battery, storage, and permissions
const config = AppStateConfig(
  enableAppLifecycle: true,
  enableDeviceInfo: true,
  enableConnectivity: true,
  enableBattery: true,      // Monitor battery during workouts
  enableStorage: true,      // Store workout data
  enablePermissions: true,  // Request fitness permissions
  enableMemory: true,       // Optimize performance
);
```

---

### Example 3: Network Monitoring Tool

```dart
// Need comprehensive network monitoring
const config = AppStateConfig(
  enableAppLifecycle: true,
  enableDeviceInfo: true,
  enableConnectivity: true,
  enableWiFi: true,         // Full WiFi details
  enableVPN: true,          // Detect VPN usage
  enableNetworkType: true,  // Track network changes
);
```

---

## Checking If Features Are Enabled

```dart
// Access features safely - returns null if disabled
final battery = appStateManager.batteryInfo;
if (battery != null) {
  print('Battery level: ${battery.batteryLevel}%');
} else {
  print('Battery monitoring not enabled');
}

// Getters return initial/empty values for disabled features
final storage = appStateManager.storageInfo;
if (storage.totalSpace > 0) {
  print('Storage available');
} else {
  print('Storage monitoring not enabled (returns zeros)');
}
```

---

## Best Practices

### ✅ DO

- **Only enable features you actually use**
- Use `AppStateConfig.minimal()` as a starting point
- Add features incrementally as needed
- Document why each feature is enabled
- Test with minimal config in production builds

### ❌ DON'T

- Don't use `AppStateConfig.all()` in production
- Don't enable features "just in case"
- Don't request permissions you don't need
- Don't forget to update AndroidManifest.xml/Info.plist when enabling new features

---

## Platform-Specific Setup

### Android Manifest

When enabling certain features, add required permissions:

```xml
<!-- For WiFi monitoring -->
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />

<!-- For Storage monitoring (Android 10 and below) -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />

<!-- For Connectivity -->
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### iOS Info.plist

```xml
<!-- For location (required for WiFi SSID on iOS) -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need location access to show WiFi network details</string>
```

---

## Migration Guide

### From Full Initialization to Modular

**Before:**
```dart
final appStateManager = AppStateManagerImpl.create(logger);
await appStateManager.initialize();
```

**After:**
```dart
const config = AppStateConfig(
  enableBattery: true,
  enableWiFi: true,
  // ... only what you need
);

final appStateManager = AppStateManagerImpl.create(logger, config: config);
await appStateManager.initialize();
```

---

## App Store Compliance

### Why This Matters

App stores (Apple App Store, Google Play) **reject apps** that:
- Request unnecessary permissions
- Include unused SDKs/features
- Don't justify permission usage

### How Modular Config Helps

✅ **Only include what you use** → Smaller app size
✅ **Only request needed permissions** → Better app store approval
✅ **Explain each permission** → Clearer privacy policy
✅ **Remove unused features** → Faster app performance

---

## FAQ

**Q: What happens if I access a disabled feature?**
A: Getters return `null` or initial/empty values. Check before using.

**Q: Can I change config after initialization?**
A: No. Create a new instance with different config and reinitialize.

**Q: What's the performance impact of enabling all features?**
A: Minimal on modern devices, but increases app size and startup time.

**Q: Do I need to update dependencies in pubspec.yaml?**
A: Yes! Only add dependencies for features you enable.

**Q: How do I know which features I need?**
A: Start with `minimal()` config, then add features as your app requires them.

---

## Support

For issues or questions:
- Check the main README.md
- Review examples in `example/` folder
- See `_ai_agent.md` for architecture details
