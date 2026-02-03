# abdalsalam_logic_flutter - Documentation

Complete guide for the Flutter logic package providing 20+ reusable modules for app state, networking, storage, authentication, and more.

## 📋 Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Core Services](#core-services)
- [Quick Start](#quick-start)
- [Architecture](#architecture)

---

## Overview

A comprehensive Flutter logic package built with SOLID principles and modular architecture. All features are opt-in - only bundle what you need.

**Requirements:** Flutter 3.10.1+, Dart 3.10.1+

---

## Installation

```yaml
dependencies:
  abdalsalam_logic_flutter: ^0.1.0
```

For Firebase features (auth, FCM), configure Firebase in your app first.

---

## Core Services

### 📱 App State Management
Monitor 21+ device and app states with zero-impact, opt-in architecture.

**Features:** Lifecycle, connectivity, device info, battery, WiFi, mobile data, storage, memory, permissions, orientation, theme, and more.

**[→ Complete Guide](APP_STATE.md)**

---

### 🎮 Runtime Control
User-defined domain architecture with dynamic app control.

**Features:** Custom domain registration, native app restart, UI tree management (refresh/rebuild/recreate), validation system.

**[→ Complete Guide](RUNTIME_CONTROL.md)**

---

### 💾 Storage System
Multi-layer storage with unified gateway pattern.

**Features:** SQLite, Hive, SharedPreferences abstraction, key-value and entity storage, transactions, queries, versioning.

**[→ Complete Guide](STORAGE.md)**

---

### 🌐 Networking
Dio-based HTTP client with offline support.

**Features:** RESTful operations, authentication integration, interceptors, error handling, token management.

**[→ Complete Guide](NETWORKING.md)**

---

### 🔐 Authentication
Firebase Auth integration with complete flow management.

**Features:** Sign in/up, password reset, token management, session handling, user state tracking.

**[→ Complete Guide](AUTHENTICATION.md)**

---

### 📝 Logging System
Structured logging with caller tracking and environment awareness.

**Features:** Multiple log levels, file output, caller information, environment-based filtering.

**[→ Complete Guide](LOGGING.md)**

---

### ⚠️ Error Handling
Centralized exception management with smart classification.

**Features:** Custom exception types, error classification, user-friendly messages, recovery strategies.

**[→ Complete Guide](ERROR_HANDLING.md)** | **[Exception Handling](EXCEPTION_HANDLING.md)**

---

### 📁 File Operations
Complete file system management utilities.

**Features:** Read/write operations, directory management, file sharing, path utilities.

**[→ Complete Guide](FILE_HANDLING.md)**

---

### 🔔 Firebase Cloud Messaging
Push notification integration with topic management.

**Features:** Token handling, topic subscriptions, foreground/background messages, deep linking.

**[→ Complete Guide](FCM.md)**

---

### 🚀 Prefetch System
Data preloading and caching strategies.

**Features:** Background data loading, cache management, priority queuing, resource optimization.

**[→ Complete Guide](PREFETCH.md)**

---

### 🛠️ Additional Services
- **Role Management**: User permissions and role-based access
- **Update Manager**: Version tracking and app updates
- **Share Service**: Text and file sharing
- **Calendar Service**: Event management
- **Contacts Service**: Contact operations

---

## Quick Start

### Basic Setup

```dart
import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';

// Configure only needed features
final config = AppStateConfig(
  enableConnectivity: true,
  enableDeviceInfo: true,
  enableBattery: true,
);

// Initialize core services
final logger = LoggerServiceImpl();
final appStateManager = AppStateManagerImpl.create(logger, config: config);
await appStateManager.initialize();
```

### Using Storage

```dart
// Unified storage access
await StorageGateway.instance.saveUser(user);
final userData = await StorageGateway.instance.getUser(userId);
```

### API Client

```dart
final apiClient = ApiClientImpl(logger);
apiClient.setBaseUrl('https://api.example.com');
final response = await apiClient.get('/data');
```

### Runtime Control

```dart
// Custom domain
class MyDomain implements RuntimeDomain {
  @override
  String get domainId => 'my_feature';
  // Implementation...
}

// Register and use
final registry = DomainRegistry();
registry.register(MyDomain());

// Native restart
await AppControl.instance.restartApp();
```

---

## Architecture

### Design Principles

1. **Interface-Based**: Clean contracts, dependency inversion
2. **Modular**: Opt-in features, zero-impact bundling
3. **Type-Safe**: Strong typing throughout
4. **Provider-Agnostic**: Works with any state management solution
5. **Platform-Aware**: Conditional platform-specific code

### Module Structure

```
lib/src/
├── core/               # Foundational interfaces and errors
├── app_state/          # State management (21+ domains)
├── runtime_control/    # Dynamic app control
├── networking/         # HTTP client
├── storage/            # Multi-layer storage gateway
├── auth/               # Authentication
├── logging/            # Logging system
├── error_handling/     # Exception management
├── fcm/                # Push notifications
├── file_operations/    # File utilities
├── prefetch/           # Data preloading
└── ...                 # Additional services
```

---

## Platform Support

| Platform | Status |
|----------|--------|
| Android  | ✅ Full |
| iOS      | ✅ Full |
| Web      | ✅ Core |
| macOS    | ✅ Core |
| Windows  | ✅ Core |
| Linux    | ✅ Core |

---

## Support

- 🐛 [Report Issues](https://github.com/AbdAlmalik/abdalsalam_logic_flutter/issues)
- 📧 Email: abed.alsalam.jodalah@gmail.com

## License

MIT License - See LICENSE file for details.
