# Modular Architecture Guide

## Overview

This package follows a **modular, opt-in architecture** where features are only initialized and bundled if explicitly enabled. This ensures zero impact for unused features.

## Design Philosophy

### 1. Zero Impact Principle

**Disabled features should have ZERO impact on:**
- App bundle size
- Runtime performance
- Memory usage
- Initialization time
- Compilation time

**Implementation:**
```dart
// In AppStateConfig
final bool enableFeature;

// In Implementation
if (_config.enableFeature) {
  await _initializeFeature();
}

// Getters with config check
@override
FeatureInfo get featureInfo => 
  _config.enableFeature ? _featureInfo : FeatureInfo.initial();
```

### 2. Explicit Over Implicit

**Always require explicit opt-in:**
```dart
// ❌ Bad: Auto-enable everything
final config = AppStateConfig();

// ✅ Good: Explicit configuration
final config = AppStateConfig(
  enableFeature1: true,
  enableFeature2: false,
);
```

### 3. Safe Defaults

**Default to disabled for optional features:**
```dart
class AppStateConfig {
  final bool enableWiFi;
  final bool enableMobileData;
  final bool enableBattery;
  
  const AppStateConfig({
    this.enableWiFi = false,  // Safe default
    this.enableMobileData = false,
    this.enableBattery = false,
  });
}
```

### 4. Dependency Transparency

**Clearly document required dependencies:**
```dart
/// Enable WiFi information tracking
/// 
/// **Required Dependencies:**
/// - connectivity_plus: ^5.0.2
/// - network_info_plus: ^5.0.1
/// 
/// **Platform Configuration:**
/// Android: ACCESS_WIFI_STATE permission
/// iOS: Local network usage description
final bool enableWiFi;
```

## Configuration Patterns

### Presets

Provide common configurations:

```dart
class AppStateConfig {
  // 1. Default (minimal - core only)
  const AppStateConfig({...});
  
  // 2. All features enabled
  factory AppStateConfig.all() => AppStateConfig(
    enableWiFi: true,
    enableMobileData: true,
    enableBattery: true,
    // ... all features
  );
  
  // 3. Minimal (absolute minimum)
  factory AppStateConfig.minimal() => AppStateConfig(
    enableAppLifecycle: true,
    enableDeviceInfo: true,
    // Only essential features
  );
}
```

### Custom Configuration

```dart
// Developer creates exactly what they need
final config = AppStateConfig(
  // Network monitoring
  enableConnectivity: true,
  enableWiFi: true,
  enableMobileData: true,
  
  // Device state
  enableBattery: true,
  enableStorage: true,
  
  // Skip everything else
  enableMemory: false,
  enableAudio: false,
  enableVPN: false,
  // ... etc
);
```

## Initialization Flow

### Conditional Initialization

```dart
@override
Future<void> initialize() async {
  if (_isInitialized) return;

  // Core features (if enabled)
  if (_config.enableDeviceInfo) await _initializeDeviceInfo();
  if (_config.enableConnectivity) await _initializeConnectivity();
  
  // Optional features (only if enabled)
  if (_config.enableWiFi) await _initializeWiFiInfo();
  if (_config.enableMobileData) await _initializeMobileDataInfo();
  if (_config.enableBattery) await _initializeBatteryInfo();
  if (_config.enableStorage) await _initializeStorageInfo();
  if (_config.enableAudio) await _initializeAudioState();
  // ... etc
  
  _isInitialized = true;
}
```

### Lazy Stream Controllers

Don't create streams for disabled features:

```dart
// ❌ Bad: Always create controllers
final _wifiController = StreamController<WiFiInfo>.broadcast();

// ✅ Good: Conditional controllers or null checks
StreamController<WiFiInfo>? _wifiController;

Stream<WiFiInfo> get wifiStream {
  if (!_config.enableWiFi) {
    return Stream.empty();
  }
  _wifiController ??= StreamController<WiFiInfo>.broadcast();
  return _wifiController!.stream;
}
```

## Feature Integration Checklist

When adding a new feature domain:

### 1. Add Configuration Flag

```dart
// In AppStateConfig
final bool enableNewFeature;

const AppStateConfig({
  this.enableNewFeature = false,  // Safe default
  // ... other flags
});
```

### 2. Update Presets

```dart
factory AppStateConfig.all() => AppStateConfig(
  enableNewFeature: true,  // Enable in .all()
  // ... other flags
);

factory AppStateConfig.minimal() => AppStateConfig(
  enableNewFeature: false,  // Disable in .minimal()
  // ... other flags
);
```

### 3. Update copyWith()

```dart
AppStateConfig copyWith({
  bool? enableNewFeature,
  // ... other parameters
}) {
  return AppStateConfig(
    enableNewFeature: enableNewFeature ?? this.enableNewFeature,
    // ... other fields
  );
}
```

### 4. Add Interface Methods

```dart
// In AppStateManager interface
abstract class AppStateManager {
  /// New feature info
  /// 
  /// Returns initial/empty state if [AppStateConfig.enableNewFeature] is false
  NewFeatureInfo get newFeatureInfo;
  
  /// Stream of new feature changes
  Stream<NewFeatureInfo> get newFeatureStream;
  
  /// Refresh new feature data
  Future<void> refreshNewFeature();
}
```

### 5. Implement in Manager

```dart
// In AppStateManagerImpl

// State field
NewFeatureInfo _newFeatureInfo = NewFeatureInfo.initial();

// Stream controller
final StreamController<NewFeatureInfo> _newFeatureController = 
  StreamController.broadcast();

// Stream getter
@override
Stream<NewFeatureInfo> get newFeatureStream => 
  _newFeatureController.stream;

// Public getter with config check
@override
NewFeatureInfo get newFeatureInfo => 
  _config.enableNewFeature ? _newFeatureInfo : NewFeatureInfo.initial();

// Initialize in initialize()
if (_config.enableNewFeature) await _initializeNewFeature();

// Initialization method
Future<void> _initializeNewFeature() async {
  try {
    // Get data from platform
    _newFeatureInfo = NewFeatureInfo(/* ... */);
    _newFeatureController.add(_newFeatureInfo);
    _logger.info('New feature initialized');
  } catch (error, stackTrace) {
    _logger.error('Failed to initialize new feature', 
      error: error, stackTrace: stackTrace);
  }
}

// Refresh method
@override
Future<void> refreshNewFeature() async {
  if (!_config.enableNewFeature) return;
  await _initializeNewFeature();
}

// Add to refreshAll()
@override
Future<void> refreshAll() async {
  await Future.wait([
    // ... other features
    if (_config.enableNewFeature) _initializeNewFeature(),
  ]);
}

// Add to dispose()
@override
Future<void> dispose() async {
  // ... other controllers
  await _newFeatureController.close();
}

// Add to getFullState()
@override
Map<String, dynamic> getFullState() {
  return {
    // ... other features
    'newFeatureInfo': _newFeatureInfo.toMap(),
  };
}
```

### 6. Export Model

```dart
// In main package file
export 'src/app_state/models/new_feature_info.dart';
```

### 7. Document Dependencies

Update [APP_STATE_GUIDE.md](APP_STATE_GUIDE.md) with:
- Feature description
- Required dependencies
- Platform configuration
- Usage examples

## Dependency Management

### Required vs Optional

```dart
/// Helper method to get required dependencies
List<String> getRequiredDependencies() {
  final deps = <String>[];
  
  if (enableConnectivity) deps.add('connectivity_plus: ^5.0.2');
  if (enableDeviceInfo) deps.add('device_info_plus: ^9.1.1');
  if (enableBattery) deps.add('battery_plus: ^5.0.2');
  if (enableWiFi || enableMobileData) {
    deps.add('network_info_plus: ^5.0.1');
  }
  if (enableStorage) deps.add('disk_space_plus: ^0.2.2');
  if (enableAudio) deps.add('volume_controller: ^2.0.7');
  if (enablePermissions) deps.add('permission_handler: ^12.0.1');
  if (enableAppVersion) deps.add('package_info_plus: ^5.0.1');
  
  return deps;
}
```

### Permission Requirements

```dart
/// Helper method to get required permissions
List<String> getRequiredPermissions() {
  final perms = <String>[];
  
  if (enableWiFi) {
    perms.add('android.permission.ACCESS_WIFI_STATE');
    perms.add('android.permission.ACCESS_FINE_LOCATION');
  }
  if (enableMobileData) {
    perms.add('android.permission.ACCESS_NETWORK_STATE');
  }
  if (enableBattery) {
    perms.add('android.permission.BATTERY_STATS');
  }
  // ... etc
  
  return perms;
}
```

## Testing Strategy

### Unit Tests

Test with different configurations:

```dart
test('WiFi info returns initial when disabled', () {
  final config = AppStateConfig(enableWiFi: false);
  final manager = AppStateManagerImpl.create(logger, config: config);
  
  expect(manager.wifiInfo.isConnected, false);
  expect(manager.wifiInfo.ssid, null);
});

test('WiFi info initializes when enabled', () async {
  final config = AppStateConfig(enableWiFi: true);
  final manager = AppStateManagerImpl.create(logger, config: config);
  await manager.initialize();
  
  expect(manager.wifiInfo, isNotNull);
});
```

### Integration Tests

Verify zero impact:

```dart
test('Disabled features have zero overhead', () async {
  final stopwatch = Stopwatch()..start();
  
  final config = AppStateConfig.minimal();
  final manager = AppStateManagerImpl.create(logger, config: config);
  await manager.initialize();
  
  stopwatch.stop();
  
  // Should be very fast with minimal features
  expect(stopwatch.elapsedMilliseconds, lessThan(100));
});
```

## Performance Considerations

### 1. Initialization Order

Group related features:

```dart
// Network features together
await Future.wait([
  if (_config.enableConnectivity) _initializeConnectivity(),
  if (_config.enableWiFi) _initializeWiFiInfo(),
  if (_config.enableMobileData) _initializeMobileDataInfo(),
]);

// Device features together
await Future.wait([
  if (_config.enableBattery) _initializeBatteryInfo(),
  if (_config.enableStorage) _initializeStorageInfo(),
  if (_config.enableMemory) _initializeMemoryInfo(),
]);
```

### 2. Lazy Initialization

Initialize expensive features only when accessed:

```dart
Future<void> _ensureFeatureInitialized() async {
  if (_featureInitialized) return;
  await _initializeFeature();
  _featureInitialized = true;
}

@override
FeatureInfo get featureInfo {
  if (!_config.enableFeature) return FeatureInfo.initial();
  _ensureFeatureInitialized();  // Initialize on first access
  return _featureInfo;
}
```

### 3. Memory Management

Clean up properly:

```dart
@override
Future<void> dispose() async {
  // Only dispose what was created
  if (_config.enableWiFi) await _wifiController?.close();
  if (_config.enableBattery) await _batteryController?.close();
  // ... etc
}
```

## Migration Guide

### From Old Architecture

```dart
// ❌ Old: Everything always enabled
final appState = AppStateManager();
await appState.initialize();

// ✅ New: Explicit configuration
final config = AppStateConfig(
  enableWiFi: true,
  enableBattery: true,
  // Only what you need
);
final appState = AppStateManagerImpl.create(logger, config: config);
await appState.initialize();
```

### Gradual Adoption

```dart
// Start with all features
final config = AppStateConfig.all();

// Then optimize by disabling unused features
final config = AppStateConfig(
  enableWiFi: true,
  enableBattery: true,
  enableStorage: false,  // Not using storage tracking
  enableMemory: false,   // Not using memory tracking
  // ... etc
);
```

## Real-World Examples

### Example 1: Social Media App

```dart
final config = AppStateConfig(
  // Core
  enableAppLifecycle: true,
  enableDeviceInfo: true,
  enableConnectivity: true,
  
  // Need network details for analytics
  enableWiFi: true,
  enableMobileData: true,
  
  // Battery for video playback optimization
  enableBattery: true,
  
  // Permissions for camera/photos
  enablePermissions: true,
  
  // Version for update prompts
  enableAppVersion: true,
  
  // Skip: audio, storage, memory, VPN, etc.
);
```

### Example 2: Offline-First App

```dart
final config = AppStateConfig(
  // Core
  enableAppLifecycle: true,
  enableDeviceInfo: true,
  enableConnectivity: true,
  
  // Storage for data sync
  enableStorage: true,
  
  // Version tracking
  enableAppVersion: true,
  
  // Skip: network details, battery, audio, etc.
);
```

### Example 3: IoT/Device Monitoring App

```dart
final config = AppStateConfig.all();  // Need everything!

// WiFi, mobile data, battery, storage, memory, audio
// All useful for device monitoring dashboard
```

## Summary

The modular architecture ensures:

✅ **Zero overhead** for unused features  
✅ **Explicit configuration** for clarity  
✅ **Easy to extend** with new features  
✅ **Testable** with different configurations  
✅ **Production-ready** with safe defaults  
✅ **Developer-friendly** with clear documentation  

By following these patterns, the package remains lean, efficient, and adaptable to any use case.
