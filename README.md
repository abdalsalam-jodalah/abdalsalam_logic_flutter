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

```dart
final appStateManager = AppStateManagerImpl(logger);

// Listen to state changes
appStateManager.state.addListener(() {
  print('Current state: ${appStateManager.state.value}');
});

// Initialize app state
await appStateManager.initialize();

// Set authentication state
await appStateManager.setAuthenticated(true);
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
