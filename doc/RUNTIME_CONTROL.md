# App Control Runtime System

A comprehensive **central App Control Runtime system** that treats the application as a **fully controllable runtime**, providing complete authority over lifecycle, state, and UI trees.

---

## Table of Contents

- [Core Philosophy](#core-philosophy)
- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Actions Reference](#actions-reference)
- [State Registration System](#state-registration-system)
- [Reset Levels](#reset-levels)
- [Lifecycle Phases](#lifecycle-phases)
- [Domain System](#domain-system)
- [UI Tree Control](#ui-tree-control)
- [Event System](#event-system)
- [Error Handling](#error-handling)
- [Platform Restart](#platform-restart)
- [Best Practices](#best-practices)
- [Testing](#testing)
- [Examples](#examples)

---

## Core Philosophy

- The application is a **runtime environment**
- UI is only one projection of that runtime
- Every state, module, tree, and lifecycle phase is:
  - **Explicitly registered**
  - **Explicitly controlled**
  - **Explicitly resettable**
  - **Deterministically reproducible**

**No implicit behavior. No hidden side effects. No magic.**

---

## Features

### 1. Lifecycle Authority

Full lifecycle control with deterministic phases:

- **Start App** - Initialize runtime from clean baseline
- **Restart App** - Hard reset with full disposal and reinitialization
- **Platform Restart** - Native OS-level app restart (like hot restart)
- **Refresh App** - Soft reset preserving selected state
- **Reset Runtime** - Reset execution without killing process
- **Stop App** - Clean shutdown and disposal

### 2. UI & Tree Control

- Refresh UI only (no state changes)
- Rebuild all widget trees
- Force recreation of trees with new keys
- Clear cached render state
- Navigation stack clearing
- Guarantee no stale UI survives rebuild

### 3. State Control & Domains

Every controllable state belongs to a **registered domain**:

- **Auth Domain** - Authentication tokens, sessions, credentials
- **Storage Domain** - SharedPreferences, SQLite, file storage
- **Network Domain** - API clients, connection state, caches
- **Memory Domain** - In-memory caches, temporary data
- **App State Domain** - App-wide state, feature flags
- **Cache Domain** - HTTP cache, image cache, data cache
- **Sync Domain** - Background sync state, pending operations

### 4. Reset Levels

Graduated reset levels for precise control:

| Level | Description | UI Reset | Transient State | Persistent State | Runtime |
|-------|-------------|----------|-----------------|------------------|---------|
| **UI Only** | UI refresh only | ✓ | - | - | - |
| **Soft** | UI rebuild, preserve all state | ✓ | - | - | - |
| **Medium** | Clear transient state | ✓ | ✓ | - | - |
| **Hard** | Clear all state | ✓ | ✓ | ✓ | - |
| **Complete** | Full reinitialize | ✓ | ✓ | ✓ | ✓ |

### 5. Registration & Governance

Nothing participates in runtime unless:
- Explicitly registered
- Declares lifecycle hooks
- Declares reset behavior
- Declares dependencies

The system:
- Enforces registration
- Prevents unmanaged state
- Rejects hidden lifecycles
- Validates dependencies
- Manages initialization order
- Detects circular dependencies

---

## Installation

Add to your package dependencies:

```dart
import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';
```

---

## Quick Start

### 1. Initialize Runtime

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize with configuration
  AppControl.initialize(
    config: const RuntimeConfig.development(),
  );
  
  // Register domains
  AppControl.registerDomains([
    AuthDomain(),
    StorageDomain(),
    NetworkDomain(),
  ]);
  
  // Start runtime
  await AppControl.start();
  
  runApp(const MyApp());
}
```

### 2. Create a Runtime Domain

```dart
class AuthDomain implements RuntimeDomain {
  bool _initialized = false;
  
  @override
  String get domainId => 'auth';
  
  @override
  String get domainName => 'Authentication';
  
  @override
  int get initializationPriority => 100; // Higher = earlier
  
  @override
  List<String> get dependencies => ['storage']; // Depends on storage
  
  @override
  Future<void> initialize() async {
    // Initialize auth service, load tokens, etc.
    _initialized = true;
  }
  
  @override
  Future<void> reset(ResetLevel level) async {
    if (level.shouldResetPersistentState) {
      // Clear tokens, logout user
    }
  }
  
  @override
  Future<void> dispose() async {
    // Cleanup resources
    _initialized = false;
  }
  
  @override
  bool get isInitialized => _initialized;
  
  @override
  bool get canReset => true;
}
```

### 3. Use Runtime Control

```dart
// Refresh UI only
await AppControl.refreshUI();

// Soft reset - rebuild UI, preserve state
await AppControl.refreshApp();

// Medium reset - clear transient state
await AppControl.resetStates(ResetLevel.medium);

// Hard reset - clear all state
await AppControl.resetStates(ResetLevel.hard);

// Complete restart (in-process)
await AppControl.restart();

// Platform restart (like hot restart)
await AppControl.platformRestart();

// Runtime reset without process kill
await AppControl.resetRuntime();
```

---

## Actions Reference

### Start App

| Aspect | Description |
|--------|-------------|
| **General** | Bootstraps the entire application from scratch |
| **Technical** | Initializes all registered domains in dependency order, sets up event streams, transitions through `initializing` → `initialized` → `running` phases |
| **Expected Change** | App moves from cold/uninitialized state to fully operational |
| **Affected** | All registered domains, lifecycle phase, event streams |

```dart
await AppControl.start();
```

**Lifecycle Transition:** `uninitialized` → `initializing` → `initialized` → `running`

---

### Restart App

| Aspect | Description |
|--------|-------------|
| **General** | Performs a complete in-process restart of the application |
| **Technical** | Disposes all domains in reverse order, clears UI trees, resets to `uninitialized`, then calls `start()` again. Falls back to platform restart on failure. |
| **Expected Change** | Complete fresh start - all state cleared, domains reinitialized, UI rebuilt from scratch |
| **Affected** | All domains disposed and reinitialized, all UI trees recreated, all caches cleared, navigation stacks cleared |

```dart
await AppControl.restart();
```

**Lifecycle Transition:** `running` → `restarting` → `uninitialized` → `initializing` → `running`

---

### Platform Restart

| Aspect | Description |
|--------|-------------|
| **General** | Native OS-level app restart (works like Flutter's hot restart) |
| **Technical** | Uses platform-specific method channels: Android uses `Intent` with `FLAG_ACTIVITY_NEW_TASK | FLAG_ACTIVITY_CLEAR_TASK` + `finishAffinity()`, iOS uses visual restart with app re-launch |
| **Expected Change** | App completely restarts at OS level - visible restart animation, all memory cleared, fresh process state |
| **Affected** | Everything - complete process restart, equivalent to user closing and reopening app |

```dart
await AppControl.platformRestart();
```

**Platform Behavior:**
- **Android**: Creates new Intent with clear flags, finishes all activities, relaunches
- **iOS**: Shows restart overlay, exits and relies on user/system to relaunch
- **Web**: Uses `window.location.reload()` for full page refresh
- **Desktop**: Process restart via `exit(0)` with relaunch hook

---

### Refresh UI

| Aspect | Description |
|--------|-------------|
| **General** | Forces a lightweight UI repaint without touching any state |
| **Technical** | Calls Flutter's `markNeedsBuild()` on root element, waits for frame completion, triggers registered rebuild callbacks |
| **Expected Change** | Visual refresh only - animations restart, layouts recalculate, no data loss |
| **Affected** | Only render objects and widget tree - no domains, no state, no caches |

```dart
await AppControl.refreshUI();
```

**Lifecycle Transition:** `running` → `refreshing` → `running`

---

### Refresh App

| Aspect | Description |
|--------|-------------|
| **General** | Soft reset that rebuilds UI while preserving all application state |
| **Technical** | Equivalent to `resetStates(ResetLevel.soft)` - rebuilds all widget trees, clears render cache, but keeps domain state intact |
| **Expected Change** | Fresh UI with preserved data - good for recovering from UI glitches |
| **Affected** | Widget trees, navigation state, render cache, image cache - NOT domain data |

```dart
await AppControl.refreshApp();
```

**Use Cases:**
- Recovering from UI inconsistencies
- Applying theme changes
- Resetting navigation without losing session

---

### Refresh All Trees

| Aspect | Description |
|--------|-------------|
| **General** | Completely rebuilds all registered widget trees |
| **Technical** | Clears navigation stacks, marks all tree elements as dirty, processes pending frames, triggers all registered rebuild callbacks |
| **Expected Change** | Complete UI reconstruction - all widgets rebuilt, navigation reset to root |
| **Affected** | All registered trees, navigator keys, image cache, text input cache |

```dart
await AppControl.refreshAllTrees();
```

---

### Reset States

| Aspect | Description |
|--------|-------------|
| **General** | Resets domain states based on the specified reset level |
| **Technical** | Iterates domains in reverse dependency order, calls `reset(level)` on each, optionally rebuilds UI, clears caches based on level |
| **Expected Change** | Varies by level - from UI-only refresh to complete state wipe |
| **Affected** | Depends on reset level (see Reset Levels table) |

```dart
await AppControl.resetStates(ResetLevel.medium);
```

**Reset Level Details:**

| Level | UI | Transient | Persistent | Runtime |
|-------|-----|-----------|------------|---------|
| `uiOnly` | ✓ Rebuild | - | - | - |
| `soft` | ✓ Rebuild | - | - | - |
| `medium` | ✓ Rebuild | ✓ Clear | - | - |
| `hard` | ✓ Rebuild | ✓ Clear | ✓ Clear | - |
| `complete` | ✓ Rebuild | ✓ Clear | ✓ Clear | ✓ Reinit |

---

### Reset Runtime

| Aspect | Description |
|--------|-------------|
| **General** | Complete runtime reset - equivalent to fresh app launch without killing process |
| **Technical** | Calls `resetStates(ResetLevel.complete)` - resets all domains, clears all state, reinitializes everything |
| **Expected Change** | App behaves as if freshly launched - all user data cleared, all services reset |
| **Affected** | Everything except process memory - all domains, all state, all UI, all caches |

```dart
await AppControl.resetRuntime();
```

---

### Stop App

| Aspect | Description |
|--------|-------------|
| **General** | Gracefully shuts down the runtime environment |
| **Technical** | Disposes all domains in reverse dependency order, closes event streams, clears UI controller, transitions to `disposed` state |
| **Expected Change** | Runtime fully stopped - no domains active, no event processing |
| **Affected** | All domains disposed, streams closed, but process remains alive |

```dart
await AppControl.stop();
```

**Lifecycle Transition:** `running` → `disposing` → `disposed`

---

## State Registration System

### Why Registration Matters

The registration system ensures:
1. **Explicit Control** - Every piece of state is known and manageable
2. **Dependency Resolution** - Domains initialize in correct order
3. **Predictable Reset** - Each domain knows how to reset itself
4. **No Hidden State** - Unregistered state cannot affect the app

### Registering Domains

```dart
// Register before starting
AppControl.registerDomain(AuthDomain());

// Or register multiple at once
AppControl.registerDomains([
  StorageDomain(),    // Priority 50, no dependencies
  AuthDomain(),       // Priority 100, depends on storage
  NetworkDomain(),    // Priority 80, depends on auth
]);

// Then start
await AppControl.start();
```

### Domain Registration Rules

1. **Must register before `start()`** - Cannot add domains after runtime starts
2. **Dependencies must exist** - All declared dependencies must be registered
3. **No circular dependencies** - System detects and rejects cycles
4. **Higher priority = earlier init** - Priority 100 initializes before 50
5. **Dependencies override priority** - Dependency order takes precedence

### The RuntimeDomain Interface

```dart
abstract class RuntimeDomain {
  /// Unique identifier for this domain
  String get domainId;
  
  /// Human-readable name
  String get domainName;
  
  /// Higher = earlier initialization (100 before 50)
  int get initializationPriority;
  
  /// List of domain IDs this domain depends on
  List<String> get dependencies;
  
  /// Called during app start - setup resources
  Future<void> initialize();
  
  /// Called during reset - clear state based on level
  Future<void> reset(ResetLevel level);
  
  /// Called during stop - cleanup resources
  Future<void> dispose();
  
  /// Current initialization status
  bool get isInitialized;
  
  /// Whether this domain can be reset
  bool get canReset;
}
```

### Built-in Domains

The package provides ready-to-use domains:

| Domain | ID | Priority | Dependencies | What It Resets |
|--------|-----|----------|--------------|----------------|
| `StorageDomain()` | `storage` | 50 | None | SharedPrefs, caches, app directories |
| `AuthDomain()` | `auth` | 100 | `storage` | Tokens, sessions, credentials |
| `NetworkDomain()` | `network` | 80 | `auth` | API clients, connection state |
| `MemoryDomain()` | `memory` | 30 | None | In-memory caches, temp data |
| `CacheDomain()` | `cache` | 40 | `storage` | HTTP cache, image cache |
| `SyncDomain()` | `sync` | 60 | `network` | Pending operations, sync state |
| `AppStateDomain()` | `app_state` | 90 | None | Feature flags, app preferences |
| `LoggingDomain()` | `logging` | 10 | None | Log buffers, log files |

### Custom Domain Example

```dart
class CartDomain implements RuntimeDomain {
  final List<CartItem> _items = [];
  bool _initialized = false;
  
  @override
  String get domainId => 'cart';
  
  @override
  String get domainName => 'Shopping Cart';
  
  @override
  int get initializationPriority => 70;
  
  @override
  List<String> get dependencies => ['auth', 'storage'];
  
  @override
  Future<void> initialize() async {
    // Load cart from storage
    final saved = await _loadFromStorage();
    _items.addAll(saved);
    _initialized = true;
  }
  
  @override
  Future<void> reset(ResetLevel level) async {
    switch (level) {
      case ResetLevel.uiOnly:
      case ResetLevel.soft:
        // Don't touch cart data
        break;
        
      case ResetLevel.medium:
        // Clear in-memory only, keep saved
        _items.clear();
        break;
        
      case ResetLevel.hard:
      case ResetLevel.complete:
        // Clear everything
        _items.clear();
        await _clearFromStorage();
        break;
    }
  }
  
  @override
  Future<void> dispose() async {
    await _saveToStorage();
    _items.clear();
    _initialized = false;
  }
  
  @override
  bool get isInitialized => _initialized;
  
  @override
  bool get canReset => true;
}
```

### Accessing the Registry

```dart
// Get specific domain
final authDomain = AppControl.registry.getDomain('auth');

// Check if domain exists
final exists = AppControl.registry.exists('cart');

// Get initialization order (respects dependencies)
final order = AppControl.registry.getInitializationOrder();

// Check if domain is initialized
final isReady = AppControl.registry.isInitialized('auth');

// Get all domains
final allDomains = AppControl.registry.getAllDomains();

// Get domain count
final count = AppControl.registry.domainCount;

// Get initialized count
final readyCount = AppControl.registry.initializedCount;
```

---

## Reset Levels

### ResetLevel.uiOnly

| Aspect | Details |
|--------|---------|
| **What Happens** | Visual repaint only |
| **Technical** | Calls `markNeedsBuild()` on elements |
| **State Cleared** | None |
| **Use Case** | Fix visual glitches, refresh animations |

### ResetLevel.soft

| Aspect | Details |
|--------|---------|
| **What Happens** | Complete UI rebuild, preserve all state |
| **Technical** | Rebuilds widget trees, clears render cache, navigation reset |
| **State Cleared** | None - all domain data preserved |
| **Use Case** | Apply theme changes, recover from UI corruption |

### ResetLevel.medium

| Aspect | Details |
|--------|---------|
| **What Happens** | Clear transient/in-memory state |
| **Technical** | Domains clear memory caches, clear pending operations, rebuild UI |
| **State Cleared** | In-memory caches, temporary data, pending requests |
| **Use Case** | Clear stale cache data, reset feature state |

### ResetLevel.hard

| Aspect | Details |
|--------|---------|
| **What Happens** | Clear all state including persistent |
| **Technical** | Domains clear SharedPrefs, databases, files |
| **State Cleared** | Everything - transient AND persistent |
| **Use Case** | Logout user, factory reset, clear all user data |

### ResetLevel.complete

| Aspect | Details |
|--------|---------|
| **What Happens** | Full reinitialize - like fresh install |
| **Technical** | Dispose all domains, clear all state, reinitialize from scratch |
| **State Cleared** | Everything + runtime reinitialized |
| **Use Case** | Complete app reset, recover from fatal errors |

---

## Lifecycle Phases

```
┌─────────────────┐
│  uninitialized  │ ◄─────────────────────────────────┐
└────────┬────────┘                                   │
         │                                            │
         ▼                                            │
┌─────────────────┐                                   │
│  initializing   │───────► error ◄───────────────────┤
└────────┬────────┘           │                       │
         │                    │                       │
         ▼                    ▼                       │
┌─────────────────┐    ┌───────────┐                  │
│   initialized   │    │ disposing │───► disposed ────┤
└────────┬────────┘    └───────────┘                  │
         │                    ▲                       │
         ▼                    │                       │
┌─────────────────┐           │                       │
│     running     │───────────┼───────────────────────┤
└────────┬────────┘           │                       │
    │    │    │               │                       │
    │    │    └──► refreshing ──► running             │
    │    │                                            │
    │    └──────► resetting ───► running              │
    │                                                 │
    └──────────► restarting ──────────────────────────┘
```

### Phase Descriptions

| Phase | Description | Valid Transitions |
|-------|-------------|-------------------|
| `uninitialized` | Initial state, not yet started | → `initializing` |
| `initializing` | Bootstrapping domains | → `initialized`, `error` |
| `initialized` | Ready but not running | → `running`, `disposing`, `error` |
| `running` | Active and operational | → `paused`, `refreshing`, `restarting`, `resetting`, `disposing`, `error` |
| `paused` | Temporarily suspended | → `running`, `refreshing`, `restarting`, `resetting`, `disposing`, `error` |
| `refreshing` | UI/state refresh in progress | → `running`, `error` |
| `restarting` | Full restart in progress | → `uninitialized`, `running`, `error` |
| `resetting` | Reset operation in progress | → `running`, `error` |
| `disposing` | Shutdown in progress | → `disposed`, `error` |
| `disposed` | Fully shut down | → `uninitialized`, `initializing` |
| `error` | Error state | → `uninitialized`, `disposing`, `running`, `restarting`, `refreshing`, `resetting` |

---

## Domain System

### Initialization Order

Domains are initialized in this order:
1. **Dependency order** - Dependencies are initialized first
2. **Priority order** - Higher priority initializes before lower (within same dependency level)

```dart
// Example: These domains...
StorageDomain()   // priority: 50, deps: []
AuthDomain()      // priority: 100, deps: ['storage']
NetworkDomain()   // priority: 80, deps: ['auth']
MemoryDomain()    // priority: 30, deps: []

// ...initialize in this order:
// 1. StorageDomain (no deps, will be needed by auth)
// 2. MemoryDomain (no deps, lower priority than storage)
// 3. AuthDomain (depends on storage, which is ready)
// 4. NetworkDomain (depends on auth, which is ready)
```

### Disposal Order

Domains dispose in **reverse** initialization order to respect dependencies.

### State Controller

Direct access to state operations:

```dart
// Initialize specific domain
await AppControl.stateController.initializeDomain('auth');

// Reset specific domain
await AppControl.stateController.resetDomain('network', ResetLevel.medium);

// Reinitialize domain (reset + init)
await AppControl.stateController.reinitializeDomain('storage');

// Dispose specific domain
await AppControl.stateController.disposeDomain('feature_x');

// Track subscriptions for cleanup
AppControl.stateController.trackSubscription(mySubscription);
AppControl.stateController.trackController(myStreamController);
```

---

## UI Tree Control

### Registering Trees

```dart
// Set root key for main app
final rootKey = GlobalKey<State<StatefulWidget>>();
AppControl.uiController.setRootKey(rootKey);

// Register named trees for targeted rebuilds
final featureKey = GlobalKey();
AppControl.uiController.registerTree('feature_dashboard', featureKey);

// Register navigator keys for navigation control
final navKey = GlobalKey<NavigatorState>();
AppControl.uiController.registerNavigatorKey(navKey);

// Register rebuild callbacks
AppControl.uiController.registerRebuildCallback(() {
  // Called on every tree rebuild
});
```

### Tree Operations

```dart
// Refresh UI (lightweight)
await AppControl.uiController.refreshUI();

// Rebuild all trees
await AppControl.uiController.rebuildAllTrees();

// Rebuild specific tree
await AppControl.uiController.rebuildTree('feature_dashboard');

// Recreate all trees (new keys)
await AppControl.uiController.recreateAllTrees();

// Clear render cache
await AppControl.uiController.clearCachedRenderState();
```

---

## Event System

### Runtime Events

```dart
AppControl.eventStream.listen((event) {
  switch (event.type) {
    case RuntimeEventType.starting:
      print('Runtime starting...');
      break;
    case RuntimeEventType.started:
      print('Runtime started!');
      break;
    case RuntimeEventType.restarting:
      print('Restarting...');
      break;
    case RuntimeEventType.restarted:
      print('Restarted!');
      break;
    case RuntimeEventType.platformRestarting:
      print('Platform restart initiated...');
      break;
    case RuntimeEventType.refreshing:
      print('Refreshing at level: ${event.resetLevel}');
      break;
    case RuntimeEventType.refreshed:
      print('Refreshed at level: ${event.resetLevel}');
      break;
    case RuntimeEventType.stopping:
      print('Stopping...');
      break;
    case RuntimeEventType.stopped:
      print('Stopped!');
      break;
    case RuntimeEventType.error:
      print('Error: ${event.message}');
      break;
    case RuntimeEventType.phaseChange:
      print('Phase changed to: ${event.phase}');
      break;
  }
});
```

### Phase Events

```dart
AppControl.phaseStream.listen((phase) {
  print('Current phase: $phase');
  
  // React to specific phases
  if (phase == LifecyclePhase.running) {
    // App is ready for user interaction
  }
});
```

### State Events

```dart
AppControl.stateController.eventStream.listen((event) {
  switch (event.type) {
    case StateEventType.initializingDomain:
      print('Initializing: ${event.domainId}');
      break;
    case StateEventType.initializedDomain:
      print('Initialized: ${event.domainId}');
      break;
    case StateEventType.resettingDomain:
      print('Resetting ${event.domainId} at level ${event.resetLevel}');
      break;
    case StateEventType.error:
      print('Domain error: ${event.domainId} - ${event.error}');
      break;
  }
});
```

---

## Error Handling

### Exception Types

| Exception | Code | Description |
|-----------|------|-------------|
| `RuntimeException` | - | General runtime error |
| `IllegalLifecycleTransitionException` | `ILLEGAL_TRANSITION` | Invalid phase transition |
| `DomainRegistrationException` | `DOMAIN_REGISTRATION_ERROR` | Domain already registered |
| `DomainDependencyException` | `UNMET_DEPENDENCIES` | Missing dependencies |
| `RuntimeInitializationException` | `INITIALIZATION_ERROR` | Domain failed to initialize |
| `UnregisteredDomainException` | `UNREGISTERED_DOMAIN` | Domain not found |

### Error Recovery

The system supports recovery from error state:

```dart
try {
  await AppControl.start();
} catch (e) {
  // Handle initialization error
  print('Failed to start: $e');
  
  // Recover by restarting
  await AppControl.restart();
}

// Or listen for errors
AppControl.eventStream.listen((event) {
  if (event.type == RuntimeEventType.error) {
    // Log error
    print('Runtime error: ${event.message}');
    
    // Attempt recovery
    AppControl.refreshApp();
  }
});
```

---

## Platform Restart

### How It Works

| Platform | Method | Behavior |
|----------|--------|----------|
| Android | Intent with clear flags | Restarts activity stack, new process |
| iOS | Exit with overlay | Shows restart animation, exits (App Store limitation) |
| Web | `location.reload()` | Full page refresh |
| macOS/Linux/Windows | Process restart | Exit and relaunch |

### Android Implementation

```kotlin
// Creates new Intent
val intent = packageManager.getLaunchIntentForPackage(packageName)
intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK)
intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
startActivity(intent)
finishAffinity() // Close all activities
```

### iOS Implementation

```swift
// Shows visual overlay then exits
// iOS doesn't allow programmatic restart in App Store apps
// User must manually reopen (or use enterprise/dev provisioning)
```

---

## Best Practices

### 1. Register All Domains Early

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  AppControl.initialize(config: const RuntimeConfig.development());
  
  // Register ALL domains before start
  AppControl.registerDomains([...]);
  
  await AppControl.start();
  runApp(const MyApp());
}
```

### 2. Use Appropriate Reset Levels

```dart
// User changes theme → soft
await AppControl.resetStates(ResetLevel.soft);

// Clear stale cache → medium  
await AppControl.resetStates(ResetLevel.medium);

// User logs out → hard
await AppControl.resetStates(ResetLevel.hard);

// Factory reset → complete
await AppControl.resetStates(ResetLevel.complete);
```

### 3. Declare Dependencies Correctly

```dart
class PaymentDomain implements RuntimeDomain {
  @override
  List<String> get dependencies => ['auth', 'network'];
  // Payment requires auth (for user) and network (for API)
}
```

### 4. Listen to Events for Debugging

```dart
if (kDebugMode) {
  AppControl.eventStream.listen((event) {
    debugPrint('[Runtime] ${event.type}: ${event.message ?? ""}');
  });
  
  AppControl.phaseStream.listen((phase) {
    debugPrint('[Phase] $phase');
  });
}
```

### 5. Track Resources for Cleanup

```dart
class MyDomain implements RuntimeDomain {
  late StreamSubscription _subscription;
  late StreamController _controller;
  
  @override
  Future<void> initialize() async {
    _subscription = someStream.listen((_) {});
    _controller = StreamController();
    
    // Track for automatic cleanup
    AppControl.stateController.trackSubscription(_subscription);
    AppControl.stateController.trackController(_controller);
  }
}
```

---

## Testing

```dart
void main() {
  setUp(() {
    AppControl.initialize(config: const RuntimeConfig.testing());
  });
  
  tearDown(() {
    AppControl.reset();
  });
  
  test('domains initialize in dependency order', () async {
    final order = <String>[];
    
    final storage = TestDomain('storage', priority: 50, 
      onInit: () => order.add('storage'));
    final auth = TestDomain('auth', priority: 100, 
      dependencies: ['storage'],
      onInit: () => order.add('auth'));
    
    AppControl.registerDomains([auth, storage]);
    await AppControl.start();
    
    expect(order, ['storage', 'auth']);
  });
  
  test('reset clears state at correct level', () async {
    final domain = TestDomain('test');
    AppControl.registerDomains([domain]);
    await AppControl.start();
    
    await AppControl.resetStates(ResetLevel.medium);
    
    expect(domain.lastResetLevel, ResetLevel.medium);
  });
}
```

---

## Examples

See these example files for complete implementations:

- [runtime_control_example.dart](../lib/examples/runtime_control_example.dart) - Basic usage
- [runtime_control_comprehensive_ui.dart](../lib/examples/runtime_control_comprehensive_ui.dart) - Full demo UI
- [runtime_control_interactive_demo.dart](../lib/examples/runtime_control_interactive_demo.dart) - Interactive testing
- [runtime_control_integration_example.dart](../lib/examples/runtime_control_integration_example.dart) - App integration

---

## Configuration

### RuntimeConfig Options

```dart
const RuntimeConfig({
  bool enableDebugMode = false,        // Extra logging
  bool enableStrictValidation = true,  // Strict phase validation
  bool allowRuntimeReset = true,       // Allow complete reset
  bool trackLifecycleEvents = true,    // Emit lifecycle events
  ResetLevel defaultResetLevel = ResetLevel.soft,
  Duration initializationTimeout = const Duration(seconds: 30),
  Duration shutdownTimeout = const Duration(seconds: 10),
  bool enforceRegistration = true,     // Require domain registration
  bool preventUnregisteredState = true, // Block unregistered state
  bool enableRecoveryMode = false,     // Auto-recover from errors
})
```

### Presets

```dart
// Development - verbose, lenient
const RuntimeConfig.development()

// Production - minimal logging, strict
const RuntimeConfig.production()

// Testing - fast timeouts, no delays
const RuntimeConfig.testing()
```

---

## Goal

> Treat the app like a **machine you can stop, reset, rebuild, and replay** at any time — safely, predictably, and intentionally.

This system provides exactly that capability.

---

## Summary

| Action | What It Does | State Impact | Use When |
|--------|--------------|--------------|----------|
| `start()` | Bootstrap app | Initialize all | App launch |
| `restart()` | In-process restart | Clear all | Fatal recovery |
| `platformRestart()` | OS-level restart | Clear all + memory | Like hot restart |
| `refreshUI()` | Repaint only | None | Visual fixes |
| `refreshApp()` | Rebuild UI | Soft | Theme changes |
| `refreshAllTrees()` | Rebuild trees | Navigation | Deep UI reset |
| `resetStates(level)` | Reset by level | Varies | Targeted reset |
| `resetRuntime()` | Complete reset | All | Fresh start |
| `stop()` | Shutdown | Dispose all | App exit |
