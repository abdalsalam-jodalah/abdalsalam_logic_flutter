# abdalsalam_logic_flutter - Package Documentation

> **📖 For complete documentation, see [README.md](README.md)**

This package provides comprehensive Flutter logic modules for production apps.

## Quick Links

- **[📖 Main Documentation](README.md)** - Complete guide and overview
- **[📱 App State Management](APP_STATE.md)** - 21+ state domains
- **[🎮 Runtime Control](RUNTIME_CONTROL.md)** - Dynamic app control
- **[💾 Storage System](STORAGE.md)** - Multi-layer storage
- **[🌐 Networking](NETWORKING.md)** - HTTP client
- **[🔐 Authentication](AUTHENTICATION.md)** - Firebase Auth
- **[📝 Logging](LOGGING.md)** - Structured logging
- **[⚠️ Error Handling](ERROR_HANDLING.md)** - Exception management
- **[📁 File Operations](FILE_HANDLING.md)** - File utilities
- **[🔔 FCM](FCM.md)** - Push notifications
- **[🚀 Prefetch](PREFETCH.md)** - Data preloading

## Installation

```yaml
dependencies:
  abdalsalam_logic_flutter: ^0.1.0
```

## Quick Example

```dart
import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';

// Configure features
final config = AppStateConfig(
  enableConnectivity: true,
  enableDeviceInfo: true,
);

// Initialize
final logger = LoggerServiceImpl();
final appStateManager = AppStateManagerImpl.create(logger, config: config);
await appStateManager.initialize();

// Use services
await StorageGateway.instance.saveUser(user);
final response = await apiClient.get('/data');
await AppControl.instance.restartApp();
```

---

**For detailed documentation and guides, see [README.md](README.md)**