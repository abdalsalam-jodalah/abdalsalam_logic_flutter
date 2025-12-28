# App State Detection - Complete Reference

This comprehensive example demonstrates all detectable app states and how to use them in your Flutter application.

## 📁 Example Files

1. **app_state_detection_example.dart** - Full-featured UI showing all states
2. **app_state_simple_example.dart** - Console-based listener example
3. **app_state_usage_guide.dart** - Code examples for each use case

## 🎯 What You Can Detect

### 1. **App Lifecycle** (7 states)
```
appStart → appInit → (appForegroundOnline|appForegroundOffline|appBackgroundOnline|appBackgroundOffline) → appKill
```
- Detect when app starts, initializes, goes foreground/background, comes online/offline, terminates
- Combine focus (foreground/background) + connectivity (online/offline) states

### 2. **Device Information** (20+ properties)
- **Type**: phone, tablet, desktop, web
- **OS**: Android, iOS, Windows, macOS, Linux, Web
- **Screen**: size (width/height), aspect ratio, pixel ratio
- **Orientation**: portrait/landscape with auto-update
- **Responsive Breakpoints**: xs, sm, md, lg, xl
- **System UI**: notch detection, navigation bars, status bar height, safe areas
- **Computed Properties**: isMobile, isTablet, isDesktop, isLandscape, etc.

### 3. **Connectivity** (2 states)
- Online / Offline
- Combine with lifecycle for 4 connectivity states
- Auto-revalidate when app comes to foreground

### 4. **Keyboard State** (2 properties)
- **Visible**: boolean
- **Height**: keyboard height in logical pixels
- Updates when keyboard shows/hides

### 5. **Battery Status** (5+ properties)
- **Level**: battery percentage (0-100)
- **State**: charging, discharging, full, unknown
- **Power Mode**: normal, low power
- **Helpers**: isCharging, isLowBattery, isCriticalBattery, isLowPowerMode

### 6. **Network Type** (Multiple types)
- **Types**: WiFi, Mobile (2G/3G/4G/5G), Ethernet, Bluetooth, VPN, None
- **Connection Quality**: isFastConnection, isMobile, isWifi
- **Detailed Mobile Type**: 2G, 3G, 4G, 5G detection

### 7. **Accessibility Features** (6+ features)
- Screen reader enabled
- Bold text enabled
- Reduce motion enabled
- High contrast enabled
- Invert colors enabled
- Text scale factor
- Helper: hasAccessibilityFeatures

### 8. **Memory Pressure** (3 levels)
- **Levels**: normal, warning, critical
- **Helpers**: isNormal, isWarning, isCritical, shouldReduceMemoryUsage
- Triggered by `didHaveMemoryPressure()` callback

### 9. **Theme** (3 modes)
- Light / Dark / System (follows device preference)

### 10. **Locale** (Multiple properties)
- Current locale (language code)
- Device locale (default language)
- Text direction (LTR/RTL)
- RTL detection for Arabic, Hebrew, Persian, Urdu, Yiddish

### 11. **Authentication** (Multiple properties)
- **Status**: unauthenticated, authenticated, refreshing, expired
- **User**: current user object
- **Tokens**: access token, refresh token
- **Session**: validity flag, last login time

### 12. **Navigation** (Multiple properties)
- Current route
- Route history
- Route parameters
- Current tab index
- Tab-to-route mapping

## 💡 Use Cases

### Network-Aware Data Loading
```dart
appState.networkStream.listen((network) {
  if (network.isFastConnection) {
    // Load high-quality images, stream high-bitrate video
  } else if (network.isMobile) {
    // Load lower-quality images
  } else {
    // Use cached data only
  }
});
```

### Battery-Aware Optimization
```dart
appState.batteryStream.listen((battery) {
  if (battery.isLowPowerMode) {
    // Disable animations, reduce refresh rate
  }
  if (battery.isCriticalBattery) {
    // Pause all non-essential work
  }
});
```

### Accessibility Support
```dart
appState.accessibilityStream.listen((a11y) {
  if (a11y.isReduceMotionEnabled) {
    // Disable animations
  }
  if (a11y.textScaleFactor > 1.2) {
    // Adjust layouts for larger text
  }
});
```

### Responsive Design
```dart
appState.deviceStream.listen((device) {
  switch (device.currentBreakpoint) {
    case ResponsiveBreakpoint.xs:
      // Single column, touch-optimized
    case ResponsiveBreakpoint.xl:
      // Multi-column, desktop layout
    default:
      // Tablet/medium layout
  }
});
```

### Smart Sync Decisions
```dart
appState.stateStream.listen((state) {
  if (state.isOnline && state.isForeground) {
    // Start aggressive sync
  } else if (state.isOnline && appState.batteryInfo?.isCharging == true) {
    // Background sync is OK if charging
  } else {
    // Queue for later
  }
});
```

## 🚀 Quick Start

### 1. Initialize in main()
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final logger = LoggerServiceImpl();
  final appState = AppStateManagerImpl.create(logger);
  await appState.initialize();
  
  runApp(MyApp(appState: appState));
}
```

### 2. Access State in Widgets
```dart
StreamBuilder<AppStateInfo>(
  stream: appStateManager.stateStream,
  initialData: appStateManager.currentState,
  builder: (context, snapshot) {
    final state = snapshot.data!;
    return Text('State: ${state.lifecycle.name}');
  },
)
```

### 3. Listen for Changes
```dart
appStateManager.batteryStream.listen((battery) {
  print('Battery: ${battery.batteryLevel}%');
});
```

## 📊 State Streams Available

- `stateStream` - App lifecycle + connectivity
- `deviceStream` - Device metrics
- `networkStream` - Network type changes
- `keyboardStream` - Keyboard visibility
- `batteryStream` - Battery status
- `accessibilityStream` - Accessibility features
- `memoryStream` - Memory pressure
- `authStream` - Authentication state
- `themeStream` - Theme changes
- `localeStream` - Locale changes
- `navigationStream` - Navigation changes

## 🎓 Learning Path

1. Start with **SimpleAppStateExample** to understand console output
2. Review **AppStateUsageGuide** for specific use cases
3. Check **AppStateDetectionExample** for full UI demonstration
4. Build custom implementations based on your needs

## ✅ What Makes This Comprehensive

- ✅ Detects **12 major categories** of app state
- ✅ **50+ individual properties** tracked
- ✅ **Computed properties** for common checks
- ✅ **Automatic updates** on device/system changes
- ✅ **Reactive streams** for all state changes
- ✅ **Type-safe** enums and models
- ✅ **Memory efficient** - only tracks initialized states
- ✅ **Production-ready** - handles edge cases
- ✅ **Platform-aware** - Android, iOS, Windows, macOS, Linux, Web

## 🔮 Future Enhancements

Consider adding detection for:
- Biometric availability (FaceID, TouchID)
- Permissions status (camera, location, microphone)
- Storage space available
- Time zone changes
- App version + update availability
- Focus mode / Do Not Disturb
- Emulator detection
- Safe mode detection
