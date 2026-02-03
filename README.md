# abdalsalam_logic_flutter

[![pub package](https://img.shields.io/pub/v/abdalsalam_logic_flutter.svg)](https://pub.dev/packages/abdalsalam_logic_flutter)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive Flutter logic package providing 20+ reusable modules for app state management, networking, storage, authentication, and more. Built following SOLID principles with modular, opt-in architecture.

## ✨ Key Features

### 📱 **Smart App State (21+ Domains)**
- Real-time device monitoring (battery, connectivity, storage)
- Responsive breakpoint detection & platform awareness
- Modular architecture - only bundle what you enable

### 🌐 **Networking & Storage**
- Offline-first HTTP client with intelligent caching
- Unified storage gateway (SQLite + Hive + SharedPreferences)
- Automatic data synchronization and conflict resolution

### 🔐 **Authentication & Security**
- Firebase Auth integration with token management
- User isolation for all data operations
- Role-based permissions and access control

### 🎮 **Runtime Control**
- Native app restart functionality
- Custom domain registration system
- Dynamic UI tree management (refresh, rebuild, recreate)

### 🛠️ **Developer Tools**
- Structured logging with caller tracking
- Centralized error handling and classification
- Comprehensive file operations and sharing

### 📱 **Platform Integration**
- Calendar and contacts native access
- Firebase Cloud Messaging (FCM)
- Cross-platform utilities (Android, iOS, Web, Desktop)

## 🚀 Quick Start

### Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  abdalsalam_logic_flutter: ^1.0.0
```

Run:

```bash
flutter pub get
```

## 💻 Usage

### Quick Setup

```dart
import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';

// Configure only the features you need (zero-impact bundling)
final config = AppStateConfig(
  enableConnectivity: true,
  enableDeviceInfo: true,
  enableBattery: true,
);

// Initialize and start using
final appStateManager = AppStateManagerImpl.create(
  LoggerServiceImpl(), 
  config: config,
);
await appStateManager.initialize();
```

### Core Services

**App State Management**
```dart
// Reactive app state monitoring
StreamBuilder<AppStateInfo>(
  stream: appStateManager.stateStream,
  builder: (context, snapshot) {
    final state = snapshot.data;
    return state?.isOffline == true 
      ? OfflineBanner() 
      : YourMainWidget();
  },
);
```

**Storage & Networking**
```dart
// Unified storage access (SQLite + Hive + SharedPreferences)
await StorageGateway.instance.saveUser(user);
final userData = await StorageGateway.instance.getUser(userId);

// HTTP client with offline support
final apiClient = ApiClientImpl(logger);
final response = await apiClient.get('/api/data');
```

**Authentication**
```dart
final authService = AuthServiceImpl(logger, storage);
final result = await authService.signIn(email, password);
```

### Advanced Features

**Runtime Control**
```dart
// Custom runtime domains
class MyFeatureDomain implements RuntimeDomain {
  @override
  String get domainId => 'my_feature';
  // Implementation...
}

// Native app restart
await AppControl.instance.restartApp();
```

**Smart Optimizations**
```dart
// Network-aware operations
appStateManager.stateStream.where((s) => s.isOnline).listen((_) => syncData());

// Battery-conscious background tasks
appStateManager.batteryStream
  .where((b) => !b.isLowBattery)
  .listen((_) => enableBackgroundSync());

// Responsive UI adaptation
final isLargeScreen = appStateManager.deviceInfo.breakpoint
  .index >= ResponsiveBreakpoint.lg.index;
```

## 📚 Documentation

Comprehensive guides and API documentation:

- **[📖 Package Documentation](docs/PACKAGE_DOCUMENTATION.md)** - Complete usage guide
- **[📱 App State Management](docs/APP_STATE.md)** - 21+ state domains
- **[🔄 Runtime Control](docs/RUNTIME_CONTROL.md)** - Dynamic app control
- **[🌐 Networking](docs/NETWORKING.md)** - HTTP client & offline support
- **[💾 Storage System](docs/STORAGE.md)** - Multi-layer storage gateway
- **[🔐 Authentication](docs/AUTHENTICATION.md)** - Firebase Auth integration
- **[📝 Logging](docs/LOGGING.md)** - Structured logging system
- **[⚠️ Error Handling](docs/ERROR_HANDLING.md)** - Exception management
- **[📁 File Operations](docs/FILE_HANDLING.md)** - File system utilities
- **[🔔 FCM Messaging](docs/FCM.md)** - Push notifications
- **[🚀 Prefetch System](docs/PREFETCH.md)** - Data preloading
- **[🚀 Example App](example/)** - Working demo

## ⚙️ Platform Support

| Platform | Status |
|----------|--------|
| Android  | ✅ Full support |
| iOS      | ✅ Full support |
| Web      | ✅ Core features |
| macOS    | ✅ Core features |
| Windows  | ✅ Core features |
| Linux    | ✅ Core features |

## 🔄 Migration

See [CHANGELOG.md](CHANGELOG.md) for version history and migration guides.

## 🤝 Contributing

Contributions are welcome! Please read the [contributing guidelines](CONTRIBUTING.md) first.

## 📜 License

[MIT License](LICENSE) - see LICENSE file for details.

## 📞 Support

- 🐛 [Report Issues](https://github.com/AbdAlmalik/abdalsalam_logic_flutter/issues)
- 💬 [Discussions](https://github.com/AbdAlmalik/abdalsalam_logic_flutter/discussions)
- 📧 Email: abed.alsalam.jodalah@gmail.com
