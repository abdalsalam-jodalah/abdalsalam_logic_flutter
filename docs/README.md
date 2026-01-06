# Documentation

Welcome to the comprehensive documentation for `abdalsalam_logic_flutter`.

## Quick Navigation

### Core Services

- **[Storage](STORAGE.md)** - Type-safe storage abstraction layer for key-value and entity storage
- **[App State](APP_STATE.md)** - Comprehensive app and device state monitoring with 21+ domains
- **[Authentication](AUTHENTICATION.md)** - User authentication service (sign in, sign up, token management)
- **[FCM (Push Notifications)](FCM.md)** - Firebase Cloud Messaging integration
- **[Networking (API Client)](NETWORKING.md)** - HTTP client for RESTful API communication

## Getting Started

1. **Installation**: Add the package to your `pubspec.yaml`
   ```yaml
   dependencies:
     abdalsalam_logic_flutter: ^1.0.0
   ```

2. **Choose Your Features**: Each service is modular - only import what you need

3. **Initialize**: Set up services using dependency injection (GetIt recommended)

4. **Use**: Follow service-specific documentation for detailed usage

## Service Overview

### Storage
Provides abstraction for all storage needs:
- **KeyValueStorage** - For preferences, cache, settings
- **EntityStorage** - For structured data, database records
- **Optional Capabilities** - Transactions, queries, watching, versioning

**[Read Full Documentation →](STORAGE.md)**

### App State
Monitor 21+ app and device states:
- Connectivity (WiFi, Mobile, VPN)
- Device info (battery, orientation, screen)
- System (permissions, memory, storage)
- Modular configuration (only bundle what you enable)

**[Read Full Documentation →](APP_STATE.md)**

### Authentication
Complete auth flow:
- Sign in / Sign up
- Password reset
- Token management
- Session handling

**[Read Full Documentation →](AUTHENTICATION.md)**

### FCM
Push notification management:
- Token retrieval and refresh
- Topic subscriptions
- Message handling (foreground/background)
- Deep linking

**[Read Full Documentation →](FCM.md)**

### Networking
HTTP API client:
- RESTful operations (GET, POST, PUT, PATCH, DELETE)
- Authentication integration
- Error handling
- Configuration (base URL, headers)

**[Read Full Documentation →](NETWORKING.md)**

## Architecture Principles

All services follow these principles:

1. **Interface-Based** - Clean contracts, easy testing
2. **Modular** - Use only what you need
3. **Type-Safe** - Strong typing throughout
4. **Backend-Agnostic** - Work with any implementation
5. **Production-Ready** - Battle-tested patterns

## Quick Start Example

```dart
import 'package:get_it/get_it.dart';
import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';

void setupServices() {
  final getIt = GetIt.instance;
  
  // Storage
  getIt.registerLazySingleton<KeyValueStorage<String>>(
    () => PreferencesStorage(),
  );
  
  // Auth & API
  getIt.registerLazySingleton<AuthService>(() => AuthServiceImpl());
  getIt.registerLazySingleton<ApiClient>(() => ApiClientImpl());
  
  // App State
  getIt.registerLazySingleton<AppStateManager>(
    () => AppStateManagerImpl.create(
      getIt<LoggerService>(),
      config: AppStateConfig(enableConnectivity: true),
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServices();
  
  // Initialize
  await GetIt.I<AuthService>().initialize();
  await GetIt.I<AppStateManager>().initialize();
  
  runApp(MyApp());
}
```

## Support

For issues, questions, or contributions, please visit the repository.

## License

MIT License - See LICENSE file for details.
