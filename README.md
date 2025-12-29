# abdalsalam_logic_flutter

A comprehensive Flutter logic package providing reusable modules for app state, networking, storage, authentication, and more. Built following SOLID principles and modern Flutter best practices.

## Features

- **App State Management** - Comprehensive, modular state tracking with 21+ domains
  - **Modular & Opt-In Architecture** - Only initialize features you need
  - App Lifecycle, Connectivity, Device Info
  - WiFi & Mobile Data tracking with real device data
  - Battery, Storage, Memory monitoring
  - Audio, Orientation, Screen Metrics
  - Permissions (25+ types), System Settings, Accessibility
  - Navigation, Theme, Locale management
  - [📖 Complete App State Guide](docs/APP_STATE_GUIDE.md)
  - [🏗️ Modular Architecture Guide](docs/MODULAR_ARCHITECTURE.md)
- **App Initialization** - Structured app initialization with service orchestration
- **API & Networking** - HTTP client with interceptors, error handling, and token management
- **Logging** - Comprehensive logging service with multiple log levels
- **Error Handling** - Centralized error handling with custom exception types
- **Update Manager** - App version checking and update management
- **Storage** - Multiple storage options:
  - SharedPreferences (key-value storage)
  - SQLite (relational database)
  - Hive (NoSQL database)
- **Authentication** - Firebase Auth integration with token management
- **Role Management** - User role assignment and permission checking
- **Prefetch Manager** - Data prefetching and caching
- **FCM** - Firebase Cloud Messaging integration
- **File Operations** - Complete file system operations
- **Share** - Share text and files
- **Calendar** - Calendar event management
- **Contacts** - Contact management and operations

## Getting Started

### Prerequisites

- Flutter SDK >= 3.10.1
- Dart SDK >= 3.10.1

### Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  abdalsalam_logic_flutter:
    path: ../abdalsalam_logic_flutter  # or use git/version
```

Then run:

```bash
flutter pub get
```

### Firebase Setup

For authentication and FCM features, ensure Firebase is properly configured:

1. Add `firebase_core` to your app
2. Initialize Firebase in your app's main function
3. Configure Firebase for your platform (iOS/Android)

## Usage

### Basic Setup

```dart
import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';

// Initialize services
final logger = LoggerServiceImpl();
final storage = SharedPreferencesStorage(logger);
final apiClient = ApiClientImpl(logger);
final authService = AuthServiceImpl(logger, storage);
final appStateManager = AppStateManagerImpl(logger);

// Initialize app
final appInitializer = AppInitializerImpl(
  appStateManager,
  logger,
  storage,
  apiClient,
  authService,
  FcmServiceImpl(logger),
);

await appInitializer.initialize();
```

### App State Management

The `AppStateManager` provides comprehensive, modular state management with **21+ state domains**. It follows a **zero-impact, opt-in architecture** where you only initialize features you need.

#### 🎯 Key Principles

- **Modular**: Enable only the features you need via `AppStateConfig`
- **Zero Impact**: Disabled features add no code/dependencies to your bundle
- **Reactive**: All state changes broadcast via streams
- **Real Device Data**: Uses actual platform data (not mocks)
- **Manual Refresh**: Pull latest data on-demand

#### 🚀 Quick Start

```dart
import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';

// 1. Create custom configuration (opt-in features)
final config = AppStateConfig(
  // Core features
  enableAppLifecycle: true,
  enableDeviceInfo: true,
  enableConnectivity: true,
  
  // Network details
  enableWiFi: true,
  enableMobileData: true,
  
  // Device state
  enableBattery: true,
  enableStorage: true,
  enableOrientation: true,
  
  // Permissions
  enablePermissions: true,
  
  // App metadata
  enableAppVersion: true,
  
  // Skip unused features
  enableMemory: false,
  enableAudio: false,
  enableVPN: false,
  // ... etc
);

// 2. Initialize with logger
final logger = LoggerServiceImpl();
final appStateManager = AppStateManagerImpl.create(logger, config: config);
await appStateManager.initialize();

// 3. Use in your app
runApp(MyApp(appStateManager: appStateManager));
```

#### 📊 State Domains Available

| Domain | Description | Key Data |
|--------|-------------|----------|
| **App Lifecycle** | Foreground/background, online/offline | States, focus, connectivity |
| **Device Info** | Device type, OS, screen size | Phone/tablet/desktop, breakpoints |
| **Connectivity** | Network connection status | Online/offline |
| **WiFi Info** | WiFi connection details | SSID, IP, signal, speed, frequency |
| **Mobile Data** | Cellular connection tracking | 2G/3G/4G/5G, signal, operator |
| **VPN Info** | VPN connection detection | Connection status |
| **Battery Info** | Battery monitoring with live updates | Level, state, health, temperature |
| **Storage Info** | Device storage tracking | Total, free, used, percentage |
| **Memory Info** | System memory & pressure | Total, free, used, pressure level |
| **Audio State** | Volume monitoring | Level, output type, mute status |
| **Orientation** | Screen orientation | Portrait/landscape |
| **Screen Metrics** | Display measurements | Pixel ratio, DPI, safe areas |
| **App Version** | Version & build info | Version, build number, package |
| **App Runtime** | Running duration | Uptime tracking |
| **System Settings** | System-level settings | Dark mode, low power, airplane |
| **Permissions** | 25+ permission types | Camera, location, contacts, etc. |
| **Keyboard** | Keyboard visibility & height | Visible state, height |
| **Network Type** | Network connection type | WiFi, mobile, ethernet |
| **Accessibility** | Accessibility features | Screen reader, bold text, reduce motion |
| **Navigation** | Route & tab tracking | Current route, history, params |
| **Theme & Locale** | Theme mode & language | Dark/light mode, locale, RTL |

#### 📖 Documentation

- **[Complete App State Guide](docs/APP_STATE_GUIDE.md)** - Detailed usage for all 21 domains
- **[Modular Architecture Guide](docs/MODULAR_ARCHITECTURE.md)** - Design principles & patterns
- **[Example App](example/)** - Working demo with all features

#### ⚡ Common Use Cases

**1. Network-aware sync:**
```dart
appStateManager.stateStream.listen((state) {
  if (state.isOnline && state.isForeground) {
    syncData();
  }
});
```

**2. Responsive UI:**
```dart
final device = appStateManager.deviceInfo;
if (device.isTablet || device.breakpoint.index >= ResponsiveBreakpoint.lg.index) {
  // Desktop/tablet layout
} else {
  // Mobile layout
}
```

**3. Battery optimization:**
```dart
appStateManager.batteryStream.listen((battery) {
  if (battery.isLowBattery) {
    disableBackgroundSync();
  }
});
```

**4. WiFi vs Mobile Data:**
```dart
final wifi = appStateManager.wifiInfo;
final mobile = appStateManager.mobileDataInfo;

if (wifi.isConnected) {
  // High-quality streaming on WiFi
  setQuality(VideoQuality.high);
} else if (mobile.isConnected) {
  // Lower quality on mobile data
  setQuality(VideoQuality.standard);
}
```

**5. Manual refresh:**
```dart
// Refresh all enabled features
await appStateManager.refreshAll();

// Or refresh specific domains
await appStateManager.refreshWiFi();
await appStateManager.refreshBattery();
```

#### 📦 Required Dependencies

Only add dependencies for features you enable:

```yaml
dependencies:
  # Core (if using app state)
  connectivity_plus: ^5.0.2
  device_info_plus: ^9.1.1
  
  # Optional (based on your AppStateConfig)
  battery_plus: ^5.0.2              # if enableBattery
  network_info_plus: ^5.0.1         # if enableWiFi or enableMobileData
  disk_space_plus: ^0.2.2           # if enableStorage
  volume_controller: ^2.0.7         # if enableAudio
  permission_handler: ^12.0.1       # if enablePermissions
  package_info_plus: ^5.0.1         # if enableAppVersion
```

See [Installation Guide](docs/APP_STATE_GUIDE.md#installation) for platform-specific setup.

---

### Other Core Features

#### API & Networking

```dart
import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';

// Create instance (singleton pattern)
final logger = LoggerServiceImpl();
final appStateManager = AppStateManagerImpl.create(logger);

// Initialize (call once during app startup)
await appStateManager.initialize();
```

#### Listening to State Changes

```dart
// Listen to app lifecycle changes
appStateManager.stateStream.listen((state) {
  print('Lifecycle: ${state.lifecycle.name}');
  print('Online: ${state.isOnline}');
  print('Foreground: ${state.isForeground}');
  
  if (state.isOnline && state.isForeground) {
    // Sync data when app comes online
    syncData();
  }
});

// Listen to device info changes (orientation, size, etc.)
appStateManager.deviceStream.listen((device) {
  print('Device: ${device.type.name}');
  print('OS: ${device.os.name}');
  print('Screen: ${device.screenSize.width}x${device.screenSize.height}');
  print('Breakpoint: ${device.breakpoint.name}');
  print('Orientation: ${device.orientation.name}');
  print('Has notch: ${device.hasNotch}');
  
  // Adapt UI based on device
  if (device.isTablet) {
    // Use tablet layout
  } else if (device.breakpoint == ResponsiveBreakpoint.xl) {
    // Use desktop layout
  }
});

// Listen to navigation changes
appStateManager.navigationStream.listen((nav) {
  print('Current route: ${nav.currentRoute}');
  print('Route params: ${nav.routeParams}');
  print('History: ${nav.routeHistory}');
});

// Listen to theme changes
appStateManager.themeStream.listen((theme) {
  print('Theme mode: ${theme.name}');
});

// Listen to locale changes
appStateManager.localeStream.listen((locale) {
  print('Current locale: ${locale.currentLocale.languageCode}');
  print('RTL: ${locale.isRTL}');
  print('Text direction: ${locale.textDirection.name}');
});

// Listen to authentication changes
appStateManager.authStream.listen((auth) {
  print('Authenticated: ${auth.isAuthenticated}');
  if (auth.isAuthenticated) {
    print('User ID: ${auth.userId}');
    print('Email: ${auth.userEmail}');
  }
});
```

#### Updating State

```dart
// Update theme mode
await appStateManager.updateTheme(ThemeMode.dark);

// Update locale
await appStateManager.updateLocale(Locale('ar'));

// Update navigation
await appStateManager.updateNavigation('/products', params: {'id': '123'});

// Update tab navigation
await appStateManager.updateTab(1, '/inbox');

// Pop navigation
await appStateManager.popNavigation();

// Set authentication state
await appStateManager.setAuthenticated(
  true,
  userId: 'user123',
  userEmail: 'user@example.com',
);

// Clear authentication
await appStateManager.setUnauthenticated();
```

#### Accessing Current State

```dart
// Get current state
final state = appStateManager.currentState;
if (state.isOnline && state.isForeground) {
  // App is active and connected
}

// Get device info
final device = appStateManager.deviceInfo;
if (device != null) {
  if (device.isPhone) {
    // Phone-specific logic
  } else if (device.isTablet) {
    // Tablet-specific logic
  } else if (device.isDesktop) {
    // Desktop-specific logic
  }
  
  // Check breakpoint for responsive design
  switch (device.breakpoint) {
    case ResponsiveBreakpoint.xs:
      // Extra small screens
      break;
    case ResponsiveBreakpoint.sm:
      // Small screens
      break;
    case ResponsiveBreakpoint.md:
      // Medium screens
      break;
    case ResponsiveBreakpoint.lg:
      // Large screens
      break;
    case ResponsiveBreakpoint.xl:
      // Extra large screens
      break;
  }
}

// Get navigation state
final nav = appStateManager.navigationState;
print('Current route: ${nav.currentRoute}');
print('Tab index: ${nav.currentTabIndex}');

// Get locale info
final locale = appStateManager.localeInfo;
if (locale.isRTL) {
  // Apply RTL layout
}

// Get auth info
final auth = appStateManager.authInfo;
if (auth.isAuthenticated) {
  print('User: ${auth.userEmail}');
}

// Get permissions info
final permissions = appStateManager.permissionsInfo;
if (permissions.isGranted(PermissionType.camera)) {
  // Camera is allowed
}
if (permissions.isPermanentlyDenied(PermissionType.location)) {
  // Location is permanently denied
}
```

#### Permission Management

The app state manager provides comprehensive permission tracking for 25+ common Android/iOS permissions:

**Available Permission Types:**
- Camera, Microphone
- Location (including locationAlways, locationWhenInUse)
- Calendar, Contacts
- Photos, Videos, Storage, Documents, Downloads
- Notifications, Phone, SMS
- Sensors, Activity Recognition
- Bluetooth, Schedule
- App Tracking Transparency
- Media Library, Reminders, Speech Recognition

**Permission Status:**
- `granted` - Permission is allowed
- `denied` - Permission is denied
- `restricted` - Permission is restricted by OS
- `limited` - Permission is limited (iOS 14+)
- `permanentlyDenied` - User denied and disabled "Ask Again"
- `provisional` - Provisional permission granted

**Usage:**

```dart
// Listen to permission changes
appStateManager.permissionsStream.listen((permissions) {
  if (permissions.isGranted(PermissionType.camera)) {
    // Start camera feature
  }
  
  if (permissions.isPermanentlyDenied(PermissionType.location)) {
    // Show app settings prompt to user
  }
});

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

// Query permissions
final permissions = appStateManager.permissionsInfo;
if (permissions.isGranted(PermissionType.location)) {
  // Location is available
}

// Get all permissions by status
final grantedPerms = permissions.getGrantedPermissions();
final deniedPerms = permissions.getDeniedPermissions();
final permaDeniedPerms = permissions.getPermanentlyDeniedPermissions();
```

#### Getting Full State Snapshot

```dart

#### Getting Full State Snapshot

```dart
// Get complete state snapshot (useful for debugging/analytics)
final fullState = appStateManager.getFullState();
print(fullState);
// {
//   'appState': {...},
//   'deviceInfo': {...},
//   'navigationState': {...},
//   'authInfo': {...},
//   'themeMode': 'dark',
//   'localeInfo': {...},
//   'timestamp': '2024-01-01T12:00:00.000Z'
// }
```

#### State Models

The app state manager uses several state models:

- **AppStateInfo**: Combines lifecycle, focus, and connectivity state
- **DeviceInfo**: Comprehensive device and screen information
- **NavigationState**: Route history and tab navigation
- **LocaleInfo**: Locale and text direction information
- **AuthInfo**: Authentication status and user information

All models support `copyWith()` for immutable updates and `toMap()` for serialization.

#### Lifecycle States

The app goes through these lifecycle states:

- `appStart`: Application is starting
- `appInit`: Application has initialized
- `appForegroundOnline`: App is in foreground and online
- `appForegroundOffline`: App is in foreground but offline
- `appBackgroundOnline`: App is in background and online
- `appBackgroundOffline`: App is in background and offline
- `appKill`: Application is being terminated

#### Responsive Breakpoints

Device breakpoints are automatically calculated:

- **xs**: < 576px (phones portrait)
- **sm**: 576-768px (phones landscape, small tablets)
- **md**: 768-992px (tablets portrait)
- **lg**: 992-1200px (tablets landscape)
- **xl**: ≥ 1200px (desktop, large tablets)

#### Integration with State Management

The app state manager works with any state management solution:

```dart
// With Riverpod
final appStateProvider = StreamProvider<AppStateInfo>((ref) {
  final manager = ref.watch(appStateManagerProvider);
  return manager.stateStream;
});

// With Provider
final appStateStream = StreamProvider<AppStateInfo>(
  (ref) => appStateManager.stateStream,
);

// Direct usage in widgets
StreamBuilder<AppStateInfo>(
  stream: appStateManager.stateStream,
  builder: (context, snapshot) {
    final state = snapshot.data;
    if (state?.isOffline == true) {
      return OfflineBanner();
    }
    return YourWidget();
  },
);
```

### API Client

```dart
final apiClient = ApiClientImpl(logger);

// Configure
apiClient.setBaseUrl('https://api.example.com');
apiClient.setAuthToken('your-token');

// Make requests
final response = await apiClient.get('/users');
final created = await apiClient.post('/users', data: {'name': 'John'});
```

### Storage

```dart
// SharedPreferences
final storage = SharedPreferencesStorage(logger);
await storage.initialize();
await storage.set('key', 'value');
final value = await storage.get<String>('key');

// SQLite
final sqliteStorage = SqliteStorageImpl<User>(
  logger,
  'app.db',
  'users',
  (user) => user.toMap(),
  (map) => User.fromMap(map),
);
await sqliteStorage.initialize('CREATE TABLE users (id TEXT PRIMARY KEY, name TEXT)');
await sqliteStorage.create(user);

// Hive
final hiveStorage = HiveStorageImpl<User>(logger, 'users');
await hiveStorage.initialize();
await hiveStorage.create(user);
```

### Authentication

```dart
final authService = AuthServiceImpl(logger, storage);

// Sign in
final userId = await authService.signIn('email@example.com', 'password');

// Sign up
final userId = await authService.signUp('email@example.com', 'password');

// Check authentication
final isAuth = await authService.isAuthenticated();

// Sign out
await authService.signOut();
```

### Role Management

```dart
final roleManager = RoleManagerImpl(logger, storage);

// Assign role
await roleManager.assignRole('userId', 'admin');

// Check role
final hasRole = await roleManager.hasRole('userId', 'admin');
final hasAny = await roleManager.hasAnyRole('userId', ['admin', 'moderator']);
```

### File Operations

```dart
final fileService = FileServiceImpl(logger);

// Save file
await fileService.saveFile('/path/to/file.txt', bytes);

// Read file
final content = await fileService.readFileAsString('/path/to/file.txt');

// Get directories
final docsDir = await fileService.getAppDocumentsDirectory();
final cacheDir = await fileService.getAppCacheDirectory();
```

### Share

```dart
final shareService = ShareServiceImpl(logger);

// Share text
await shareService.shareText('Hello World');

// Share file
await shareService.shareFile('/path/to/file.pdf');
```

### Calendar

```dart
final calendarService = CalendarServiceImpl(logger);

// Add event
await calendarService.addEvent(
  title: 'Meeting',
  startDate: DateTime.now(),
  endDate: DateTime.now().add(Duration(hours: 1)),
);

// Get events
final events = await calendarService.getEvents(
  startDate: DateTime.now(),
  endDate: DateTime.now().add(Duration(days: 7)),
);
```

### Contacts

```dart
final contactsService = ContactsServiceImpl(logger);

// Request permission
final hasPermission = await contactsService.requestPermission();

// Get contacts
final contacts = await contactsService.getContacts();

// Add contact
await contactsService.addContact({
  'givenName': 'John',
  'familyName': 'Doe',
  'emails': ['john@example.com'],
  'phones': ['+1234567890'],
});
```

## Architecture

The package follows SOLID principles:

- **Single Responsibility** - Each service has a single, well-defined responsibility
- **Open/Closed** - Services are open for extension through interfaces
- **Liskov Substitution** - Implementations can be substituted through interfaces
- **Interface Segregation** - Focused interfaces for specific use cases
- **Dependency Inversion** - Depend on abstractions, not concretions

## Module Structure

```
lib/
├── src/
│   ├── core/
│   │   ├── errors/
│   │   └── interfaces/
│   ├── app_state/
│   ├── app_initialization/
│   ├── networking/
│   ├── logging/
│   ├── storage/
│   ├── auth/
│   ├── role_management/
│   ├── prefetch/
│   ├── fcm/
│   ├── file_operations/
│   ├── share/
│   ├── calendar/
│   ├── contacts/
│   └── update_manager/
└── abdalsalam_logic_flutter.dart
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

See LICENSE file for details.
