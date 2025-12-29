# App State Manager - Quick Reference Guide

## Initialization

```dart
// Create and initialize
final logger = LoggerServiceImpl();
final appStateManager = AppStateManagerImpl.create(logger);
await appStateManager.initialize();

// Cleanup
await appStateManager.dispose();
```

## Stream Listeners

```dart
// Lifecycle & connectivity
appStateManager.stateStream.listen((state) { });

// Device metrics & orientation
appStateManager.deviceStream.listen((device) { });

// Route changes
appStateManager.navigationStream.listen((nav) { });

// Theme changes
appStateManager.themeStream.listen((theme) { });

// Locale changes
appStateManager.localeStream.listen((locale) { });

// Authentication changes
appStateManager.authStream.listen((auth) { });

// Keyboard visibility
appStateManager.keyboardStream.listen((keyboard) { });

// Battery status
appStateManager.batteryStream.listen((battery) { });

// Network type
appStateManager.networkStream.listen((network) { });

// Accessibility features
appStateManager.accessibilityStream.listen((a11y) { });

// Memory pressure
appStateManager.memoryStream.listen((memory) { });

// Permissions
appStateManager.permissionsStream.listen((permissions) { });
```

## Getters (Current State)

```dart
// Current app state
final state = appStateManager.currentState;
final isOnline = state.isOnline;
final isForeground = state.isForeground;

// Device info
final device = appStateManager.deviceInfo;
final isPhone = device?.isPhone ?? false;
final breakpoint = device?.breakpoint;

// Navigation
final nav = appStateManager.navigationState;
final currentRoute = nav.currentRoute;
final tabIndex = nav.currentTabIndex;

// Theme
final theme = appStateManager.themeMode;

// Locale
final locale = appStateManager.localeInfo;
final isRTL = locale.isRTL;

// Auth
final auth = appStateManager.authInfo;
final isAuthenticated = auth.isAuthenticated;

// Keyboard
final keyboard = appStateManager.keyboardInfo;
final isKeyboardVisible = keyboard?.isVisible ?? false;

// Battery
final battery = appStateManager.batteryInfo;
final batteryLevel = battery?.batteryLevel ?? 0;

// Network
final network = appStateManager.networkInfo;
final isConnected = network?.isOnline ?? false;

// Accessibility
final a11y = appStateManager.accessibilityInfo;
final screenReaderEnabled = a11y?.isScreenReaderEnabled ?? false;

// Memory
final memory = appStateManager.memoryInfo;
final isMemoryCritical = memory?.isCritical ?? false;

// Permissions
final permissions = appStateManager.permissionsInfo;
final cameraGranted = permissions.isGranted(PermissionType.camera);
```

## Update Methods

```dart
// Update theme
appStateManager.updateTheme(ThemeMode.dark);

// Update locale
appStateManager.updateLocale(Locale('en'));

// Update navigation
appStateManager.updateNavigation('/products', params: {'id': '123'});

// Update tab
appStateManager.updateTab(1, '/messages');

// Pop navigation
appStateManager.popNavigation();

// Set authenticated
appStateManager.setAuthenticated(user, accessToken);

// Set unauthenticated
appStateManager.setUnauthenticated();

// Update auth info
appStateManager.updateAuthInfo(authInfo);

// Update permission
appStateManager.updatePermission(permissionInfo);

// Update permissions (multiple)
appStateManager.updatePermissions([permission1, permission2]);

// Get full state snapshot
final snapshot = appStateManager.getFullState();
```

## Permission Operations

```dart
// Check individual permission
if (permissions.isGranted(PermissionType.camera)) { }
if (permissions.isDenied(PermissionType.location)) { }
if (permissions.isRestricted(PermissionType.contacts)) { }
if (permissions.isPermanentlyDenied(PermissionType.photos)) { }
if (permissions.isLimited(PermissionType.calendar)) { }

// Get permission status
final status = permissions.getStatus(PermissionType.microphone);

// Get all permissions by status
List<PermissionType> granted = permissions.getGrantedPermissions();
List<PermissionType> denied = permissions.getDeniedPermissions();
List<PermissionType> restricted = permissions.getRestrictedPermissions();
List<PermissionType> permaDenied = permissions.getPermanentlyDeniedPermissions();

// Create permission info
final cameraGranted = PermissionInfo.granted(PermissionType.camera);
final locationDenied = PermissionInfo.denied(PermissionType.location);
final contactsRestricted = PermissionInfo.restricted(PermissionType.contacts);
final photosPermDenied = PermissionInfo.permanentlyDenied(PermissionType.photos);

// Update single permission
appStateManager.updatePermission(
  PermissionInfo.granted(PermissionType.microphone),
);

// Update multiple permissions
appStateManager.updatePermissions([
  PermissionInfo.granted(PermissionType.camera),
  PermissionInfo.granted(PermissionType.location),
  PermissionInfo.denied(PermissionType.contacts),
]);
```

## Lifecycle Patterns

```dart
// Check app state
switch (state.lifecycle) {
  case AppLifecycleState.appStart:
  case AppLifecycleState.appInit:
  case AppLifecycleState.appForegroundOnline:
  case AppLifecycleState.appForegroundOffline:
  case AppLifecycleState.appBackgroundOnline:
  case AppLifecycleState.appBackgroundOffline:
  case AppLifecycleState.appKill:
}

// Check focus
switch (state.focus) {
  case AppFocusState.foreground:
  case AppFocusState.background:
  case AppFocusState.paused:
}

// Check connectivity
switch (state.connectivity) {
  case ConnectivityState.online:
  case ConnectivityState.offline:
}
```

## Device Breakpoints

```dart
// Check responsive breakpoint
switch (device.breakpoint) {
  case ResponsiveBreakpoint.xs:   // < 576px
  case ResponsiveBreakpoint.sm:   // 576-768px
  case ResponsiveBreakpoint.md:   // 768-992px
  case ResponsiveBreakpoint.lg:   // 992-1200px
  case ResponsiveBreakpoint.xl:   // >= 1200px
}

// Device type checks
if (device.isPhone) { }
if (device.isTablet) { }
if (device.isDesktop) { }

// Orientation
if (device.orientation == Orientation.portrait) { }
if (device.orientation == Orientation.landscape) { }
```

## Network Types

```dart
final network = appStateManager.networkInfo;

// Type checks
network?.type == NetworkType.wifi
network?.type == NetworkType.mobile
network?.type == NetworkType.ethernet
network?.type == NetworkType.vpn

// Speed checks
network?.isFastConnection  // WiFi or 4G/5G
network?.isMobile          // Mobile connection
network?.isOnline          // Any connection
```

## Battery States

```dart
final battery = appStateManager.batteryInfo;

// State checks
battery?.batteryState == BatteryState.charging
battery?.batteryState == BatteryState.discharging
battery?.batteryState == BatteryState.full

// Level checks
battery?.isLowBattery      // < 20%
battery?.isCriticalBattery // < 10%
battery?.isCharging        // Plugged in
battery?.isLowPowerMode    // Power saving enabled
```

## Authentication Status

```dart
final auth = appStateManager.authInfo;

// Status checks
auth.status == AppAuthStatus.unauthenticated
auth.status == AppAuthStatus.authenticating
auth.status == AppAuthStatus.authenticated
auth.status == AppAuthStatus.sessionExpired
auth.status == AppAuthStatus.reauthenticating

// Helpers
auth.isAuthenticated       // Boolean check
auth.hasValidSession       // Session is valid
```

## Common Patterns

### Network-Aware Loading

```dart
appStateManager.networkStream.listen((network) {
  if (network.isFastConnection) {
    loadHighQualityContent();
  } else if (network.isMobile) {
    loadLowQualityContent();
  } else if (!network.isOnline) {
    loadCachedContent();
  }
});
```

### Battery-Aware Operations

```dart
appStateManager.batteryStream.listen((battery) {
  if (battery.isLowPowerMode) {
    disableAnimations();
    reduceSyncFrequency();
  } else if (battery.isCharging) {
    runHeavyOperations();
    syncAllData();
  }
});
```

### Responsive UI

```dart
appStateManager.deviceStream.listen((device) {
  switch (device?.breakpoint) {
    case ResponsiveBreakpoint.xs:
    case ResponsiveBreakpoint.sm:
      renderSingleColumn();
    case ResponsiveBreakpoint.md:
    case ResponsiveBreakpoint.lg:
    case ResponsiveBreakpoint.xl:
      renderMultiColumn();
    case null:
  }
});
```

### Permission Gating

```dart
appStateManager.permissionsStream.listen((permissions) {
  if (permissions.isGranted(PermissionType.camera)) {
    enableCameraFeature();
  } else if (permissions.isPermanentlyDenied(PermissionType.camera)) {
    showSettingsPrompt();
  } else {
    disableCameraFeature();
  }
});
```

### Accessibility Support

```dart
appStateManager.accessibilityStream.listen((a11y) {
  if (a11y?.isReduceMotionEnabled ?? false) {
    disableAnimations();
  }
  if (a11y?.isScreenReaderEnabled ?? false) {
    ensureSemanticLabels();
  }
  if ((a11y?.textScaleFactor ?? 1.0) > 1.2) {
    adjustLayoutForLargeText();
  }
});
```

## Permission Types

```dart
PermissionType:
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
```

## Permission Status Types

```dart
PermissionStatus:
  - denied              // Permission denied
  - granted             // Permission granted
  - restricted          // Restricted by OS
  - limited             // Limited (iOS 14+)
  - permanentlyDenied   // Permanently denied
  - provisional         // Provisional grant
```
