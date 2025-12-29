# Documentation Index

Complete documentation for `abdalsalam_logic_flutter` package.

## Package Modules

### Core State Management

- **[App State Manager](./APP_STATE_MANAGER.md)** - Comprehensive centralized state management
  - Lifecycle tracking
  - Device information monitoring
  - Navigation state management
  - Theme and locale management
  - Authentication state tracking
  - Permission management
  - Keyboard visibility detection
  - Battery status monitoring
  - Network connectivity tracking
  - Accessibility features detection
  - Memory pressure monitoring
  - Reactive streams for all state domains

## Quick Links

- [App State Manager Documentation](./APP_STATE_MANAGER.md)
  - Architecture overview
  - Detailed state models (11 domains)
  - Usage examples
  - Best practices
  - Initialization & lifecycle

## Getting Started

### 1. App Initialization

```dart
final logger = LoggerServiceImpl();
final appStateManager = AppStateManagerImpl.create(logger);
await appStateManager.initialize();
```

### 2. Listen to State Changes

```dart
appStateManager.stateStream.listen((state) {
  if (state.isOnline && state.isForeground) {
    // App is active and connected
  }
});
```

### 3. Access Current State

```dart
final device = appStateManager.deviceInfo;
if (device != null && device.isPhone) {
  // Phone-specific logic
}
```

### 4. Update State

```dart
// Theme
appStateManager.updateTheme(ThemeMode.dark);

// Locale
appStateManager.updateLocale(Locale('ar'));

// Permissions
appStateManager.updatePermission(
  PermissionInfo.granted(PermissionType.camera),
);

// Authentication
appStateManager.setAuthenticated(user, token);
```

## Module Structure

```
lib/
├── src/
│   ├── app_state/                 # State management module
│   │   ├── app_state_manager.dart         # Interface
│   │   ├── app_state_manager_impl.dart    # Implementation
│   │   └── models/
│   │       ├── app_lifecycle_state.dart
│   │       ├── device_info.dart
│   │       ├── navigation_state.dart
│   │       ├── locale_info.dart
│   │       ├── auth_info.dart
│   │       ├── keyboard_info.dart
│   │       ├── battery_info.dart
│   │       ├── network_info.dart
│   │       ├── accessibility_info.dart
│   │       ├── memory_info.dart
│   │       └── permissions_info.dart
│   ├── core/                      # Core interfaces
│   ├── logging/                   # Logging service
│   ├── storage/                   # Storage gateway
│   ├── networking/                # API client
│   ├── auth/                      # Authentication
│   └── ...                        # Other modules
└── examples/
    ├── app_state_simple_example.dart
    ├── app_state_usage_guide.dart
    └── README.md
```

## Examples

- [Simple App State Example](../lib/examples/app_state_simple_example.dart)
- [App State Usage Guide](../lib/examples/app_state_usage_guide.dart)

## Contributing

Follow these guidelines when adding new features:

1. Maintain interface-based design
2. Document public APIs with dartdoc comments
3. Add usage examples to documentation
4. Test state transitions thoroughly
5. Follow SOLID principles

## API Reference

- **AppStateManager** - Main interface for state management
- **AppStateManagerImpl** - Reference implementation
- **AppStateInfo** - Lifecycle and connectivity state
- **DeviceInfo** - Device metrics and information
- **NavigationState** - Route and tab navigation
- **AuthInfo** - Authentication and user info
- **PermissionsInfo** - App permissions tracking
- **KeyboardInfo** - Keyboard visibility
- **BatteryInfo** - Battery and power info
- **NetworkInfo** - Network connectivity info
- **AccessibilityInfo** - Accessibility settings
- **MemoryInfo** - Memory pressure info

## Support

For issues and questions, refer to:
1. [APP_STATE_MANAGER.md](./APP_STATE_MANAGER.md) - Detailed documentation
2. [lib/examples/](../lib/examples/) - Working examples
3. [README.md](../README.md) - Package overview
