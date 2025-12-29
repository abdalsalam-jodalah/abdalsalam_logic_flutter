# App State Management - Complete Documentation

## 🎯 Overview

The App State Management system provides comprehensive monitoring of 21+ app and device state domains with a **modular, opt-in architecture**. Only the features you explicitly enable are initialized and bundled.

## 🔧 Modular Architecture

### Design Principles

1. **Zero-Impact Disabled Features**: Features not enabled via `AppStateConfig` don't initialize or bundle their dependencies
2. **Explicit Opt-In**: Every feature requires explicit enablement through configuration
3. **App Store Compliant**: Only request permissions for enabled features
4. **Selective Dependencies**: Dependencies are only required if you enable features that need them
5. **Performance First**: Minimal overhead - only track what you need

### How It Works

```dart
// Default: Only core features (NO optional dependencies bundled)
const AppStateConfig()

// Enable specific features (ONLY those dependencies bundled)
const AppStateConfig(
  enableBattery: true,     // Adds battery_plus dependency
  enableWiFi: true,        // Adds network_info_plus dependency
)

// All features (ALL dependencies bundled - use for demos/comprehensive monitoring)
const AppStateConfig.all()

// Minimal (ZERO optional dependencies)
const AppStateConfig.minimal()
```

## 📦 Installation & Dependencies

### Base Installation

```yaml
dependencies:
  abdalsalam_logic_flutter: ^1.0.0
```

### Optional Dependencies (Feature-Based)

Add **only** the dependencies for features you enable:

| Feature Flag | Required Package | Version | Purpose |
|--------------|-----------------|---------|---------|
| `enableConnectivity` | `connectivity_plus` | ^5.0.2 | Network connectivity monitoring |
| `enableDeviceInfo` | `device_info_plus` | ^9.1.1 | Device details (OS, model, etc) |
| `enableBattery` | `battery_plus` | ^5.0.2 | Battery level & state monitoring |
| `enableWiFi` | `network_info_plus` | ^5.0.1 | WiFi SSID, IP, signal strength |
| `enableMobileData` | `network_info_plus` | ^5.0.1 | Cellular data & operator info |
| `enableStorage` | `disk_space_plus` | ^0.2.2 | Disk space monitoring |
| `enableAudio` | `volume_controller` | ^2.0.7 | Volume level monitoring |
| `enablePermissions` | `permission_handler` | ^12.0.1 | Runtime permissions tracking |
| `enableAppVersion` | `package_info_plus` | ^5.0.1 | App version & build info |

**Example**: Enabling battery and WiFi only:

```yaml
dependencies:
  abdalsalam_logic_flutter: ^1.0.0
  battery_plus: ^5.0.2
  network_info_plus: ^5.0.1
```

### Platform Permissions

Add **only** the permissions for enabled features:

#### Android (AndroidManifest.xml)

```xml
<!-- enableWiFi, enableMobileData -->
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />

<!-- enablePermissions (as needed) -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<!-- Add only permissions your app actually needs -->
```

#### iOS (Info.plist)

```xml
<!-- enableWiFi (iOS 13+) -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need location to access WiFi information</string>
```

## 🚀 Usage Patterns

### Pattern 1: Core Features Only (Minimal)

```dart
import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';

final logger = LoggerService();

// No optional features - zero extra dependencies
final appStateManager = AppStateManagerImpl.create(
  logger,
  config: const AppStateConfig(), // or .minimal()
);

await appStateManager.initialize();

// Available: Lifecycle, Device Info, Navigation, Theme, Locale, Auth
appStateManager.stateStream.listen((state) {
  print('App state: ${state.lifecycle.name}');
});
```

### Pattern 2: Specific Features (Production)

```dart
// Enable only what your app needs
final config = const AppStateConfig(
  enableBattery: true,      // Monitor battery
  enableConnectivity: true, // Track network status
  enableWiFi: true,         // Get WiFi details
  enablePermissions: true,  // Track permissions
);

final appStateManager = AppStateManagerImpl.create(logger, config: config);
await appStateManager.initialize();

// Battery monitoring
appStateManager.batteryStream.listen((battery) {
  if (battery != null && battery.batteryLevel < 20) {
    print('⚠️ Low battery: ${battery.batteryLevel}%');
  }
});

// WiFi monitoring
appStateManager.wifiStream.listen((wifi) {
  if (wifi.isConnected) {
    print('📶 Connected to: ${wifi.ssid}');
    print('Signal: ${wifi.signalQuality}');
  }
});

// Refresh on demand
await appStateManager.refreshBattery();
await appStateManager.refreshWiFi();
```

### Pattern 3: All Features (Demo/Testing)

```dart
// Enable everything for comprehensive demo
final appStateManager = AppStateManagerImpl.create(
  logger,
  config: const AppStateConfig.all(),
);

await appStateManager.initialize();

// Get complete state snapshot
final fullState = appStateManager.getFullState();
print(fullState); // JSON map with all 21+ domains

// Refresh everything
await appStateManager.refreshAll();
```

### Pattern 4: Dynamic Configuration

```dart
// Build config based on user settings or feature flags
AppStateConfig buildConfig({
  required bool premiumUser,
  required bool debugMode,
}) {
  return AppStateConfig(
    enableBattery: true,           // Always monitor battery
    enableConnectivity: true,      // Always monitor network
    enableWiFi: premiumUser,       // WiFi details for premium only
    enableMemory: debugMode,       // Memory info in debug mode
    enablePermissions: true,       // Always track permissions
  );
}

final config = buildConfig(
  premiumUser: user.isPremium,
  debugMode: kDebugMode,
);

final appStateManager = AppStateManagerImpl.create(logger, config: config);
```

## 📊 Complete State Domains Reference

### Core Features (Always Available)

#### 1. App Lifecycle
**Purpose**: Track app state transitions and connectivity

```dart
appStateManager.stateStream.listen((state) {
  print('Lifecycle: ${state.lifecycle.name}');
  print('Focus: ${state.focus.name}'); // foreground/background
  print('Connectivity: ${state.connectivity.name}'); // online/offline
  print('Is online: ${state.isOnline}');
});
```

**States**:
- `appStart`, `appInit`, `appReady`, `appKill`
- `appForegroundOnline`, `appForegroundOffline`
- `appBackgroundOnline`, `appBackgroundOffline`

#### 2. Device Information
**Purpose**: Device type, OS, screen metrics, breakpoints

```dart
final device = appStateManager.deviceInfo;
print('Type: ${device?.type.name}'); // phone, tablet, desktop
print('OS: ${device?.os.name} ${device?.osVersion}');
print('Screen: ${device?.screenSize}');
print('Breakpoint: ${device?.breakpoint.name}'); // xs, sm, md, lg, xl
print('Has notch: ${device?.hasNotch}');
print('Pixel ratio: ${device?.pixelRatio}');
```

**Device Types**: `phone`, `tablet`, `desktop`  
**Breakpoints**: `xs` (<576), `sm` (576-768), `md` (768-992), `lg` (992-1200), `xl` (>1200)

#### 3. Navigation State
**Purpose**: Track route history and tab navigation

```dart
appStateManager.navigationStream.listen((nav) {
  print('Current route: ${nav.currentRoute}');
  print('Route params: ${nav.routeParams}');
  print('History: ${nav.routeHistory}');
  print('Current tab: ${nav.currentTabIndex}');
});

// Update navigation
appStateManager.updateNavigation('/profile', params: {'userId': '123'});
appStateManager.updateTab(1, '/messages');
```

#### 4. Theme Mode
**Purpose**: Track light/dark/system theme

```dart
appStateManager.themeStream.listen((mode) {
  print('Theme: ${mode.name}'); // light, dark, system
});

appStateManager.updateTheme(ThemeMode.dark);
```

#### 5. Locale Information
**Purpose**: Track app and device locale

```dart
appStateManager.localeStream.listen((locale) {
  print('Current: ${locale.currentLocale.languageCode}');
  print('Device: ${locale.deviceLocale?.languageCode}');
  print('Is RTL: ${locale.isRTL}');
});

appStateManager.updateLocale(const Locale('ar')); // Arabic
```

#### 6. Authentication State
**Purpose**: Track user authentication status

```dart
appStateManager.authStream.listen((auth) {
  print('Status: ${auth.status.name}');
  print('User: ${auth.currentUser}');
  print('Has session: ${auth.hasValidSession}');
});

appStateManager.setAuthenticated(user, 'access_token_here');
appStateManager.setUnauthenticated();
```

**Auth States**: `unknown`, `authenticated`, `unauthenticated`, `loading`, `error`

### Optional Features (Enable via Config)

#### 7. Connectivity (enableConnectivity: true)
**Purpose**: Network connectivity monitoring

```dart
// Automatically tracked via lifecycle state
final state = appStateManager.currentState;
print('Online: ${state.isOnline}');
```

**Dependency**: `connectivity_plus: ^5.0.2`

#### 8. WiFi (enableWiFi: true)
**Purpose**: Detailed WiFi connection information

```dart
appStateManager.wifiStream.listen((wifi) {
  print('Connected: ${wifi.isConnected}');
  print('SSID: ${wifi.ssid}');
  print('IP: ${wifi.ipAddress}');
  print('Gateway: ${wifi.gateway}');
  print('Signal: ${wifi.signalStrength} dBm (${wifi.signalQuality})');
  print('Link speed: ${wifi.linkSpeed} Mbps');
  print('Frequency: ${wifi.frequency} MHz (${wifi.frequencyBand})');
  print('Security: ${wifi.securityType}');
});

await appStateManager.refreshWiFi();
```

**Fields**:
- Connection: `isConnected`, `ssid`, `bssid`
- Network: `ipAddress`, `gateway`, `subnet`
- Quality: `signalStrength` (-30 to -90 dBm), `signalQuality` (Excellent/Good/Fair/Poor)
- Speed: `linkSpeed` (Mbps), `frequency` (MHz), `frequencyBand` (2.4GHz/5GHz)
- Security: `securityType` (WPA2, WPA3, etc)

**Dependency**: `network_info_plus: ^5.0.1`

#### 9. Mobile Data (enableMobileData: true)
**Purpose**: Cellular/mobile data connection details

```dart
appStateManager.mobileDataStream.listen((data) {
  print('Connected: ${data.isConnected}');
  print('Type: ${data.dataTypeDisplay}'); // 2G, 3G, 4G, 5G
  print('Signal: ${data.signalStrength} dBm');
  print('Quality: ${data.signalQuality}');
  print('Percentage: ${data.signalPercentage}%');
  print('Operator: ${data.operatorName}');
  print('Country: ${data.isoCountryCode}');
});

await appStateManager.refreshMobileData();
```

**Data Types**: `none`, `cellular2g`, `cellular3g`, `cellular4g`, `cellular5g`, `unknown`

**Fields**:
- Connection: `isConnected`, `dataType`
- Signal: `signalStrength` (-50 to -120 dBm), `signalQuality`, `signalPercentage`
- Operator: `operatorName`, `isoCountryCode`, `mobileNetworkCode`, `mobileCountryCode`

**Dependency**: `network_info_plus: ^5.0.1`

#### 10. Battery (enableBattery: true)
**Purpose**: Live battery monitoring with detailed metrics

```dart
appStateManager.batteryStream.listen((battery) {
  if (battery != null) {
    print('Level: ${battery.batteryLevel}%');
    print('State: ${battery.batteryState.name}');
    print('Health: ${battery.health?.name}');
    print('Temperature: ${battery.temperature}°C');
    print('Voltage: ${battery.voltage} mV');
    print('Technology: ${battery.technology}');
    print('Charging source: ${battery.chargingSource?.name}');
    print('Capacity: ${battery.capacity} mAh');
  }
});

await appStateManager.refreshBattery();
```

**Battery States**: `charging`, `discharging`, `full`, `unknown`  
**Health**: `good`, `overheat`, `dead`, `overVoltage`, `cold`, `unknown`  
**Charging Sources**: `ac`, `usb`, `wireless`, `unknown`

**Dependency**: `battery_plus: ^5.0.2`

#### 11. Storage (enableStorage: true)
**Purpose**: Disk space monitoring

```dart
appStateManager.storageStream.listen((storage) {
  print('Total: ${storage.totalSpaceGB} GB');
  print('Used: ${storage.usedSpaceGB} GB');
  print('Free: ${storage.freeSpaceGB} GB');
  print('Usage: ${storage.usagePercentage.toStringAsFixed(1)}%');
});

await appStateManager.refreshStorage();
```

**Dependency**: `disk_space_plus: ^0.2.2`

#### 12. Audio (enableAudio: true)
**Purpose**: System volume monitoring

```dart
appStateManager.audioStateStream.listen((audio) {
  print('Volume: ${audio.volumeLevel}/${audio.maxVolume}');
  print('Percentage: ${audio.volumePercentage.toStringAsFixed(0)}%');
  print('Muted: ${audio.isMuted}');
  print('Output: ${audio.outputType.name}');
});

await appStateManager.refreshAudio();
```

**Output Types**: `speaker`, `headphones`, `bluetooth`, `unknown`

**Dependency**: `volume_controller: ^2.0.7`

#### 13. Memory (enableMemory: true)
**Purpose**: RAM usage and memory pressure

```dart
appStateManager.memoryStream.listen((memory) {
  print('Total: ${memory.totalMemoryGB} GB');
  print('Used: ${memory.usedMemoryMB} MB');
  print('Free: ${memory.freeMemoryMB} MB');
  print('Usage: ${memory.memoryUsagePercentage?.toStringAsFixed(1)}%');
  print('Pressure: ${memory.pressureLevel.name}');
});

await appStateManager.refreshMemory();
```

**Pressure Levels**: `normal`, `warning`, `critical`

#### 14. Permissions (enablePermissions: true)
**Purpose**: Track 25+ runtime permissions

```dart
appStateManager.permissionsStream.listen((permissions) {
  print('Granted: ${permissions.grantedPermissions.length}');
  print('Denied: ${permissions.deniedPermissions.length}');
  
  final camera = permissions.getPermission(PermissionType.camera);
  print('Camera: ${camera?.status.name}');
});

// Update permission
appStateManager.updatePermission(PermissionInfo(
  type: PermissionType.camera,
  status: PermissionStatus.granted,
));

await appStateManager.refreshPermissions();
```

**Permission Types** (25+):
- Media: `camera`, `microphone`, `photos`, `videos`
- Location: `location`, `locationAlways`, `locationWhenInUse`
- Contacts: `contacts`, `calendar`, `reminders`
- Storage: `storage`, `manageExternalStorage`
- Communication: `phone`, `sms`, `callLog`
- Sensors: `sensors`, `activityRecognition`
- Network: `bluetooth`, `nearbyDevices`
- Notifications: `notifications`, `criticalAlerts`
- Other: `appTrackingTransparency`, `mediaLibrary`, `speech`

**Permission Statuses**: `granted`, `denied`, `restricted`, `limited`, `permanentlyDenied`

**Dependency**: `permission_handler: ^12.0.1`

#### 15. Keyboard (enableKeyboard: true)
**Purpose**: Keyboard visibility and height

```dart
appStateManager.keyboardStream.listen((keyboard) {
  if (keyboard != null) {
    print('Visible: ${keyboard.isVisible}');
    print('Height: ${keyboard.height} dp');
  }
});
```

#### 16. Device Orientation (enableOrientation: true)
**Purpose**: Portrait/landscape tracking

```dart
appStateManager.deviceOrientationStream.listen((orientation) {
  print('Orientation: ${orientation.currentOrientation.name}');
  print('Is portrait: ${orientation.isPortrait}');
  print('Is landscape: ${orientation.isLandscape}');
});
```

**Orientations**: `portrait`, `landscape`

#### 17. App Version (enableAppVersion: true)
**Purpose**: App version and build information

```dart
final version = appStateManager.appVersionInfo;
print('App: ${version.appName}');
print('Version: ${version.version}');
print('Build: ${version.buildNumber}');
print('Package: ${version.packageName}');
```

**Dependency**: `package_info_plus: ^5.0.1`

#### 18. Screen Metrics (enableScreenMetrics: true)
**Purpose**: Detailed screen metrics

```dart
appStateManager.screenMetricsStream.listen((metrics) {
  print('Pixel ratio: ${metrics.pixelRatio}');
  print('DPI: ${metrics.dpi}');
  print('View insets: ${metrics.viewInsetBottom}'); // Keyboard height
  print('View padding: ${metrics.viewPaddingTop}'); // Status bar
});
```

#### 19. System Settings (enableSystemSettings: true)
**Purpose**: System-level settings

```dart
appStateManager.systemSettingsStream.listen((settings) {
  print('Low power: ${settings.isLowPowerMode}');
  print('Airplane: ${settings.isAirplaneMode}');
  print('Dark mode: ${settings.isDarkModeEnabled}');
});
```

#### 20. VPN (enableVPN: true)
**Purpose**: VPN connection detection

```dart
appStateManager.vpnStream.listen((vpn) {
  print('VPN connected: ${vpn.isConnected}');
  print('VPN name: ${vpn.vpnName}');
});
```

#### 21. App Runtime (enableAppRuntime: true)
**Purpose**: App uptime tracking

```dart
final runtime = appStateManager.appRuntimeInfo;
print('Uptime: ${runtime.uptime}');
```

## 🔄 Refresh System

### Global Refresh
```dart
// Refresh all enabled features
await appStateManager.refreshAll();
```

### Individual Refresh
```dart
await appStateManager.refreshWiFi();
await appStateManager.refreshBattery();
await appStateManager.refreshStorage();
await appStateManager.refreshAudio();
await appStateManager.refreshMemory();
await appStateManager.refreshPermissions();
await appStateManager.refreshMobileData();
```

## 📋 Configuration Reference

### AppStateConfig

```dart
class AppStateConfig {
  // Core features (no extra dependencies)
  final bool enableAppLifecycle;       // Default: true
  final bool enableDeviceInfo;         // Default: true
  final bool enableConnectivity;       // Default: true
  
  // Optional features (require dependencies)
  final bool enableBattery;            // Default: false
  final bool enableWiFi;               // Default: false
  final bool enableMobileData;         // Default: false
  final bool enableVPN;                // Default: false
  final bool enableStorage;            // Default: false
  final bool enableAudio;              // Default: false
  final bool enableMemory;             // Default: false
  final bool enablePermissions;        // Default: false
  final bool enableKeyboard;           // Default: false
  final bool enableNetworkType;        // Default: false
  final bool enableAccessibility;      // Default: false
  final bool enableOrientation;        // Default: false
  final bool enableAppVersion;         // Default: false
  final bool enableScreenMetrics;      // Default: false
  final bool enableSystemSettings;     // Default: false
  final bool enableAppRuntime;         // Default: false
}
```

### Helper Methods

```dart
final config = const AppStateConfig(
  enableBattery: true,
  enableWiFi: true,
);

// Get required Android permissions
final permissions = config.getRequiredPermissions();
// Returns: ['ACCESS_NETWORK_STATE', 'ACCESS_WIFI_STATE']

// Get required package dependencies
final deps = config.getRequiredDependencies();
// Returns: ['battery_plus', 'network_info_plus']

// Modify configuration
final newConfig = config.copyWith(
  enableStorage: true,
  enableMemory: true,
);
```

## 🎨 UI Integration Example

```dart
class AppStateDashboard extends StatelessWidget {
  final AppStateManager manager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App State'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => manager.refreshAll(),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Battery
          StreamBuilder<BatteryInfo?>(
            stream: manager.batteryStream,
            builder: (context, snapshot) {
              final battery = snapshot.data;
              if (battery == null) return SizedBox();
              
              return ListTile(
                leading: Icon(Icons.battery_full),
                title: Text('Battery'),
                subtitle: Text('${battery.batteryLevel}%'),
                trailing: Text(battery.batteryState.name),
              );
            },
          ),
          
          // WiFi
          StreamBuilder<WiFiInfo>(
            stream: manager.wifiStream,
            builder: (context, snapshot) {
              final wifi = snapshot.data;
              if (wifi == null || !wifi.isConnected) {
                return ListTile(
                  leading: Icon(Icons.wifi_off),
                  title: Text('WiFi'),
                  subtitle: Text('Not connected'),
                );
              }
              
              return ListTile(
                leading: Icon(Icons.wifi),
                title: Text('WiFi - ${wifi.ssid}'),
                subtitle: Text('${wifi.signalQuality} • ${wifi.ipAddress}'),
                trailing: IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () => manager.refreshWiFi(),
                ),
              );
            },
          ),
          
          // Add more state widgets...
        ],
      ),
    );
  }
}
```

## ⚡ Performance Considerations

1. **Disabled Features**: Features with `enable` = `false` are not initialized, have no memory footprint, and don't bundle dependencies
2. **Streams**: All streams are broadcast streams - multiple listeners supported
3. **Refresh**: Individual refresh methods update only specific domains
4. **Memory**: Streams are closed on dispose to prevent leaks

## 🔒 Privacy & App Store Compliance

1. **Permission Declaration**: Only declare permissions for enabled features
2. **Usage Description**: Provide clear descriptions for permission requests
3. **Data Minimization**: Only collect data for features you actually use
4. **User Control**: Allow users to disable features at runtime

## 🐛 Troubleshooting

### Feature Not Working

```dart
// Check if feature is enabled
final config = AppStateConfig(enableBattery: true);

// Verify dependencies are added to pubspec.yaml
// battery_plus: ^5.0.2

// Check platform permissions are declared
// Android: ACCESS_NETWORK_STATE for WiFi
```

### Stream Not Emitting

```dart
// Ensure initialization is complete
await appStateManager.initialize();

// Check if feature is enabled in config
print(appStateManager.batteryInfo); // null if disabled

// Try manual refresh
await appStateManager.refreshBattery();
```

### Permission Issues

```dart
// Check permission status
final permissions = appStateManager.permissionsInfo;
final camera = permissions.getPermission(PermissionType.camera);

if (camera?.isPermanentlyDenied == true) {
  // Guide user to settings
  await openAppSettings();
}
```

## 📚 Additional Resources

- [Example App](./example/lib/main.dart) - Complete demo with all features
- [Architecture Guide](./_ai_agent.md) - Design principles and patterns
- [Changelog](./CHANGELOG.md) - Version history and updates

## 💡 Best Practices

1. **Start Minimal**: Begin with core features, add optionals as needed
2. **Profile First**: Measure impact before enabling all features
3. **Document Dependencies**: List enabled features in your app's documentation
4. **Handle Nulls**: Disabled features return `null` - always check
5. **Refresh Strategically**: Use individual refresh methods instead of `refreshAll()`
6. **Clean Up**: Call `dispose()` when done to close streams

---

**Built with ❤️ following SOLID principles and Flutter best practices**
