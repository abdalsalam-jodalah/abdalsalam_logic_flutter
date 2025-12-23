# abdalsalam_logic_flutter

A comprehensive Flutter logic package providing reusable modules for app state, networking, storage, authentication, and more. Built following SOLID principles and modern Flutter best practices.

## Features

- **App State Management** - Centralized app state management with reactive state updates
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

The `AppStateManager` provides centralized state management for your entire application, tracking lifecycle, device info, navigation, theme, locale, and authentication state.

#### Features

- **Lifecycle Tracking**: Monitors app foreground/background, connectivity, and initialization states
- **Device Information**: Automatic detection of device type, OS, screen metrics, and responsive breakpoints
- **Connectivity Monitoring**: Real-time network connectivity status
- **Navigation State**: Tracks routes, history, and tab navigation
- **Theme & Locale**: Manages theme mode and locale with RTL support
- **Authentication State**: Tracks user authentication status and user info
- **Reactive Streams**: Broadcast streams for all state domains

#### Basic Usage

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
```

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
