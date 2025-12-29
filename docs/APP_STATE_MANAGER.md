# App State Manager - Comprehensive Documentation

## Overview

The `AppStateManager` is a centralized state management service that monitors and broadcasts all critical application states in real-time. It provides a unified reactive interface for tracking app lifecycle, device information, user authentication, permissions, and system resources.

## Architecture

### State Domains

The AppStateManager monitors 11 distinct state domains:

1. **App Lifecycle State** - App initialization, foreground/background, online/offline
2. **Device Information** - Device type, OS, screen metrics, orientation, breakpoints
3. **Navigation State** - Current routes, history, tab navigation
4. **Theme Mode** - Light, dark, or system theme
5. **Locale Information** - Current locale, RTL support, text direction
6. **Authentication State** - User info, token, authentication status
7. **Keyboard Visibility** - Keyboard height and visibility state
8. **Battery Status** - Battery level, charging state, power mode
9. **Network Information** - Network type, connectivity, connection speed
10. **Accessibility Features** - Screen readers, motion, text scale, contrast
11. **Memory Pressure** - Memory usage level and pressure indicators
12. **Permissions** - App permissions status for 25+ permission types

### Reactive Streams

Each state domain provides a broadcast stream for reactive updates:

```dart
// Lifecycle state
Stream<AppStateInfo> get stateStream

// Device information
Stream<DeviceInfo> get deviceStream

// Navigation
Stream<NavigationState> get navigationStream

// Theme
Stream<ThemeMode> get themeStream

// Locale
Stream<LocaleInfo> get localeStream

// Authentication
Stream<AuthInfo> get authStream

// Keyboard
Stream<KeyboardInfo> get keyboardStream

// Battery
Stream<BatteryInfo> get batteryStream

// Network
Stream<NetworkInfo> get networkStream

// Accessibility
Stream<AccessibilityInfo> get accessibilityStream

// Memory
Stream<MemoryInfo> get memoryStream

// Permissions
Stream<PermissionsInfo> get permissionsStream
```

## Detailed State Models

### 1. App Lifecycle State

Tracks the application's runtime lifecycle and connectivity status.

```dart
// Lifecycle phases
AppLifecycleState:
  - appStart      // Initial startup
  - appInit       // Initialization complete
  - appForegroundOnline
  - appForegroundOffline
  - appBackgroundOnline
  - appBackgroundOffline
  - appKill       // App termination

// Focus states
AppFocusState:
  - foreground    // App is visible
  - background    // App is hidden
  - paused        // App is paused

// Connectivity states
ConnectivityState:
  - online        // Connected to network
  - offline       // No network connection
```

**Usage:**

```dart
appStateManager.stateStream.listen((state) {
  if (state.lifecycle == AppLifecycleState.appForegroundOnline) {
    // App is active and online - sync data
  }
  
  if (state.focus == AppFocusState.background) {
    // Pause non-critical operations
  }
  
  if (!state.isOnline) {
    // Show offline indicator
  }
});
```

### 2. Device Information

Provides comprehensive device metrics and configuration.

```dart
DeviceInfo:
  - type            // DeviceType.phone, tablet, desktop, web
  - os              // OperatingSystem.android, ios, windows, macos, linux
  - model           // Device model
  - isPhone         // Boolean helper
  - isTablet        // Boolean helper
  - isDesktop       // Boolean helper
  - screenSize      // Size in logical pixels
  - pixelRatio      // Device pixel ratio
  - screenWidth     // Width in logical pixels
  - screenHeight    // Height in logical pixels
  - orientation     // Orientation.portrait or landscape
  - isLandscapeFirst // Initial orientation preference
  - breakpoint      // ResponsiveBreakpoint enum
  - hasNotch        // Has screen notch
  - hasPhysicalHomeButton
  - statusBarHeight
  - platformBrightness
  - isFullScreen
```

**Responsive Breakpoints:**

```dart
ResponsiveBreakpoint:
  - xs  // < 576px    (extra small phones)
  - sm  // 576-768px  (small phones)
  - md  // 768-992px  (tablets)
  - lg  // 992-1200px (large tablets, small desktops)
  - xl  // >= 1200px  (desktops)
```

**Usage:**

```dart
appStateManager.deviceStream.listen((device) {
  if (device.isPhone) {
    // Phone-specific UI
  } else if (device.isTablet) {
    // Tablet-specific UI
  }
  
  switch (device.breakpoint) {
    case ResponsiveBreakpoint.xs:
    case ResponsiveBreakpoint.sm:
      // Single column layout
      break;
    case ResponsiveBreakpoint.md:
    case ResponsiveBreakpoint.lg:
    case ResponsiveBreakpoint.xl:
      // Multi-column layout
      break;
  }
});
```

### 3. Navigation State

Tracks navigation history and current routes.

```dart
NavigationState:
  - currentRoute      // Current route path
  - routeParams       // Current route parameters
  - routeHistory      // List of visited routes
  - currentTabIndex   // Active tab index
  - tabRoutes         // Map of tab routes
  - timestamp         // Last update time
```

**Usage:**

```dart
// Listen to route changes
appStateManager.navigationStream.listen((nav) {
  print('Current route: ${nav.currentRoute}');
  print('Route params: ${nav.routeParams}');
});

// Update navigation
appStateManager.updateNavigation('/products', params: {'id': '123'});

// Switch tabs
appStateManager.updateTab(1, '/messages');

// Pop route
appStateManager.popNavigation();

// Access current navigation state
final nav = appStateManager.navigationState;
if (nav.currentRoute == '/home') {
  // On home screen
}
```

### 4. Theme & Locale

Manages application theming and localization.

```dart
ThemeMode:
  - light      // Light theme
  - dark       // Dark theme
  - system     // Follow system settings

LocaleInfo:
  - currentLocale     // Current Locale
  - isRTL             // Right-to-left language
  - textDirection     // TextDirection enum
  - supportedLocales  // List of supported locales
```

**Usage:**

```dart
// Theme changes
appStateManager.themeStream.listen((theme) {
  if (theme == ThemeMode.dark) {
    // Apply dark theme
  }
});

// Locale changes
appStateManager.localeStream.listen((locale) {
  if (locale.isRTL) {
    // Apply RTL layout
  }
});

// Update theme
appStateManager.updateTheme(ThemeMode.dark);

// Update locale
appStateManager.updateLocale(Locale('ar', 'SA'));
```

### 5. Authentication State

Tracks user authentication and session information.

```dart
AppAuthStatus:
  - unauthenticated   // No active session
  - authenticating    // Authentication in progress
  - authenticated     // User logged in
  - sessionExpired    // Session ended
  - reauthenticating  // Re-authentication required

AuthInfo:
  - status            // Current authentication status
  - currentUser       // User object/data
  - userId            // Unique user identifier
  - userEmail         // User email address
  - accessToken       // Session access token
  - refreshToken      // Token refresh token
  - hasValidSession   // Session validity check
  - lastLoginTime     // Last login timestamp
  - tokenExpiryTime   // Token expiration time
```

**Usage:**

```dart
appStateManager.authStream.listen((auth) {
  if (auth.isAuthenticated) {
    // User is logged in
    print('User: ${auth.userEmail}');
    print('Login time: ${auth.lastLoginTime}');
  } else {
    // Show login screen
  }
});

// Login
appStateManager.setAuthenticated(
  {'id': '123', 'name': 'John'},
  'access_token_123',
);

// Logout
appStateManager.setUnauthenticated();

// Update full auth info
appStateManager.updateAuthInfo(AuthInfo(
  status: AppAuthStatus.authenticated,
  currentUser: user,
  accessToken: token,
  refreshToken: refreshToken,
));
```

### 6. Keyboard State

Detects keyboard visibility and height.

```dart
KeyboardInfo:
  - isVisible         // Keyboard is visible
  - height            // Height in logical pixels
  - animationDuration // Animation duration
  - isSoftInputMode   // Soft input mode
```

**Usage:**

```dart
appStateManager.keyboardStream.listen((keyboard) {
  if (keyboard.isVisible) {
    // Adjust UI for keyboard
    final bottomPadding = keyboard.height;
    // Move FAB, adjust scroll position
  } else {
    // Restore normal layout
  }
});
```

### 7. Battery Status

Monitors device battery and power state.

```dart
BatteryInfo:
  - batteryLevel      // 0-100 percentage
  - batteryState      // Charging state
  - isLowBattery      // < 20%
  - isCriticalBattery // < 10%
  - isCharging        // Device is charging
  - isLowPowerMode    // Low power mode enabled

BatteryState:
  - unknown
  - charging
  - discharging
  - full
```

**Usage:**

```dart
appStateManager.batteryStream.listen((battery) {
  if (battery.isLowBattery) {
    // Show warning to user
  }
  
  if (battery.isLowPowerMode) {
    // Disable animations, reduce refresh rate
  }
  
  if (battery.isCharging) {
    // Safe to run heavy operations
  }
});
```

### 8. Network Information

Tracks network connectivity and type.

```dart
NetworkInfo:
  - type              // NetworkType enum
  - isOnline          // Connected to network
  - isFastConnection  // WiFi or 4G/5G
  - isMobile          // Mobile connection
  - isConnected       // Any connection

NetworkType:
  - wifi
  - mobile
  - ethernet
  - vpn
  - unknown
  - none
```

**Usage:**

```dart
appStateManager.networkStream.listen((network) {
  if (network.isFastConnection) {
    // Load high quality content
  } else if (network.isMobile) {
    // Load lower quality content
  } else if (!network.isOnline) {
    // Use cached data only
  }
});
```

### 9. Accessibility Features

Detects accessibility settings and user preferences.

```dart
AccessibilityInfo:
  - isScreenReaderEnabled     // Screen reader active
  - isReduceMotionEnabled     // Reduce motion preference
  - isBoldTextEnabled         // Bold text preference
  - isHighContrastEnabled     // High contrast enabled
  - textScaleFactor           // Text scale multiplier
  - hasAccessibilityFeatures  // Any a11y feature enabled
```

**Usage:**

```dart
appStateManager.accessibilityStream.listen((a11y) {
  if (a11y.isScreenReaderEnabled) {
    // Ensure semantic labels
    // Avoid purely decorative elements
  }
  
  if (a11y.isReduceMotionEnabled) {
    // Disable animations
    // Use static transitions
  }
  
  if (a11y.textScaleFactor > 1.2) {
    // Adjust layouts for larger text
    // Use flexible sizing
  }
});
```

### 10. Memory Pressure

Monitors device memory usage.

```dart
MemoryInfo:
  - pressureLevel         // MemoryPressureLevel enum
  - isWarning             // Memory warning level
  - isCritical            // Memory critical level
  - shouldReduceMemoryUsage // Recommendation flag

MemoryPressureLevel:
  - normal                // Normal memory usage
  - warning               // Warning level
  - critical              // Critical level
```

**Usage:**

```dart
appStateManager.memoryStream.listen((memory) {
  if (memory.isCritical) {
    // Clear caches
    // Release large objects
    // Pause heavy operations
  } else if (memory.isWarning) {
    // Clear old cached data
    // Reduce animation quality
  }
});
```

### 11. Permissions Information

Tracks app permissions status for multiple permission types.

```dart
PermissionType (25+ types):
  - camera
  - microphone
  - location
  - locationAlways
  - locationWhenInUse
  - calendar
  - contacts
  - photos
  - videos
  - storage
  - documents
  - downloads
  - notifications
  - phone
  - sms
  - sensors
  - activityRecognition
  - bluetooth
  - schedule
  - appTrackingTransparency
  - mediaLibrary
  - reminders
  - speechRecognition

PermissionStatus:
  - denied              // Permission denied
  - granted             // Permission granted
  - restricted          // Restricted by OS
  - limited             // Limited (iOS 14+)
  - permanentlyDenied   // Permanently denied
  - provisional          // Provisional grant

PermissionsInfo:
  - permissions         // Map<PermissionType, PermissionInfo>
  - lastUpdated         // Last update time
```

**Usage:**

```dart
appStateManager.permissionsStream.listen((permissions) {
  if (permissions.isGranted(PermissionType.camera)) {
    // Start camera feature
  }
  
  if (permissions.isPermanentlyDenied(PermissionType.location)) {
    // Show settings prompt
  }
});

// Update permissions
appStateManager.updatePermission(
  PermissionInfo.granted(PermissionType.microphone),
);

appStateManager.updatePermissions([
  PermissionInfo.granted(PermissionType.camera),
  PermissionInfo.denied(PermissionType.contacts),
]);

// Query permissions
final perms = appStateManager.permissionsInfo;
if (perms.isGranted(PermissionType.location)) {
  // Location available
}

final grantedPerms = perms.getGrantedPermissions();
final deniedPerms = perms.getDeniedPermissions();
final permaDeniedPerms = perms.getPermanentlyDeniedPermissions();
```

## Initialization & Lifecycle

### Initialization

```dart
import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';

// Create instance
final logger = LoggerServiceImpl();
final appStateManager = AppStateManagerImpl.create(logger);

// Initialize (required before use)
await appStateManager.initialize();

// Now ready to use
appStateManager.stateStream.listen((state) {
  // Handle state changes
});
```

### Disposal

```dart
// Clean up resources
await appStateManager.dispose();
```

## State Snapshot

Get a complete snapshot of all application states:

```dart
final snapshot = appStateManager.getFullState();
// {
//   'appState': {...},
//   'deviceInfo': {...},
//   'navigationState': {...},
//   'authInfo': {...},
//   'keyboardInfo': {...},
//   'batteryInfo': {...},
//   'networkInfo': {...},
//   'accessibilityInfo': {...},
//   'memoryInfo': {...},
//   'permissionsInfo': {...},
//   'themeMode': 'dark',
//   'localeInfo': {...},
//   'timestamp': '2025-12-29T...'
// }
```

## Best Practices

1. **Listen at Widget Level**: Attach listeners in initState, clean up in dispose
2. **Use Getters for Current State**: Access current state for immediate values
3. **Batch Updates**: Update multiple permissions together when possible
4. **Monitor Lifecycle**: Always check app lifecycle before resource-intensive operations
5. **Respect Battery**: Disable features in low power mode
6. **Network Awareness**: Adapt data quality based on network type
7. **Memory Management**: Listen to memory pressure and adjust accordingly
8. **Accessibility**: Always respect accessibility settings
9. **Permissions First**: Check permissions before accessing sensitive features
10. **State Persistence**: Use getFullState() for analytics or debugging

## Examples

See [lib/examples/](../lib/examples/) for complete working examples:
- `app_state_simple_example.dart` - Basic state monitoring
- `app_state_usage_guide.dart` - Comprehensive usage patterns
