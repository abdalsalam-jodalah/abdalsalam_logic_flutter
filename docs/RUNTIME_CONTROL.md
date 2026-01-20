# App Control Runtime System

A comprehensive **central App Control Runtime system** that treats the application as a **fully controllable runtime**, providing complete authority over lifecycle, state, and UI trees.

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
- **Refresh App** - Soft reset preserving selected state
- **Reset Runtime** - Reset execution without killing process
- **Stop App** - Clean shutdown and disposal

### 2. UI & Tree Control

- Refresh UI only (no state changes)
- Rebuild all widget trees
- Force recreation of trees with new keys
- Clear cached render state
- Guarantee no stale UI survives rebuild

### 3. State Control & Domains

Every controllable state belongs to a **registered domain**:

- Global app state
- Feature/module state
- Navigation state
- Session/runtime state
- Cached/in-memory state
- Persistent state

Each domain explicitly defines:
- `initialize()` - Setup and bootstrapping
- `reset(level)` - Reset behavior per level
- `dispose()` - Cleanup and teardown

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
  List<String> get dependencies => []; // Dependency domain IDs
  
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

// Complete restart
await AppControl.restart();

// Runtime reset without process kill
await AppControl.resetRuntime();
```

---

## API Reference

### AppControl

Main singleton access point:

```dart
// Initialization
AppControl.initialize({RuntimeConfig? config})

// Lifecycle control
AppControl.start()           // Start runtime
AppControl.restart()         // Hard restart
AppControl.refreshApp()      // Soft reset
AppControl.refreshUI()       // UI only
AppControl.refreshAllTrees() // Rebuild all trees
AppControl.resetStates(level) // Reset with level
AppControl.resetRuntime()    // Complete reset
AppControl.stop()            // Shutdown

// Registration
AppControl.registerDomain(domain)
AppControl.registerDomains(domains)

// State access
AppControl.currentPhase      // Current lifecycle phase
AppControl.phaseStream       // Phase change stream
AppControl.eventStream       // Runtime event stream
AppControl.isRunning         // Runtime running?
AppControl.isInitialized     // Runtime initialized?

// Controllers
AppControl.uiController      // UI tree controller
AppControl.stateController   // State controller
AppControl.registry          // Domain registry
```

### RuntimeConfig

Configuration options:

```dart
const RuntimeConfig({
  bool enableDebugMode = false,
  bool enableStrictValidation = true,
  bool allowRuntimeReset = true,
  bool trackLifecycleEvents = true,
  ResetLevel defaultResetLevel = ResetLevel.soft,
  Duration initializationTimeout = const Duration(seconds: 30),
  Duration shutdownTimeout = const Duration(seconds: 10),
  bool enforceRegistration = true,
  bool preventUnregisteredState = true,
  bool enableRecoveryMode = false,
})

// Presets
const RuntimeConfig.development()
const RuntimeConfig.production()
const RuntimeConfig.testing()
```

### LifecyclePhase

Runtime phases:

- `uninitialized` - Initial state
- `initializing` - Bootstrapping in progress
- `initialized` - Ready but not running
- `running` - Active runtime
- `paused` - Temporarily paused
- `refreshing` - UI/state refresh in progress
- `restarting` - Full restart in progress
- `resetting` - Reset operation in progress
- `disposing` - Shutdown in progress
- `disposed` - Fully shut down
- `error` - Error state

---

## Advanced Usage

### Listen to Lifecycle Events

```dart
AppControl.phaseStream.listen((phase) {
  print('Runtime phase: $phase');
});

AppControl.eventStream.listen((event) {
  print('Runtime event: ${event.type}');
});
```

### UI Tree Control

```dart
// Register UI trees for control
final rootKey = GlobalKey<State<StatefulWidget>>();
AppControl.uiController.setRootKey(rootKey);

// Register named trees
AppControl.uiController.registerTree('feature_a', featureKey);

// Rebuild specific tree
await AppControl.uiController.rebuildTree('feature_a');

// Recreate all trees (new keys)
await AppControl.uiController.recreateAllTrees();
```

### State Control

```dart
// Initialize specific domain
await AppControl.stateController.initializeDomain('auth');

// Reset specific domain
await AppControl.stateController.resetDomain('network', ResetLevel.medium);

// Reinitialize domain
await AppControl.stateController.reinitializeDomain('storage');

// Dispose domain
await AppControl.stateController.disposeDomain('feature_x');
```

### Domain Registry

```dart
// Get domain
final authDomain = AppControl.registry.getDomain('auth');

// Get initialization order
final order = AppControl.registry.getInitializationOrder();

// Check if initialized
final initialized = AppControl.registry.isInitialized('auth');

// Get all domains
final allDomains = AppControl.registry.getAllDomains();
```

---

## Design Constraints

- ✅ No implicit behavior
- ✅ No framework magic
- ✅ No uncontrolled state
- ✅ No circular lifecycles
- ✅ Fully testable without UI
- ✅ Deterministic execution order

---

## Testing

The system is designed for complete testability:

```dart
void main() {
  setUp(() {
    AppControl.initialize(config: const RuntimeConfig.testing());
  });
  
  tearDown(() {
    AppControl.reset();
  });
  
  test('should initialize domains in correct order', () async {
    final domain1 = TestDomain('d1', priority: 100);
    final domain2 = TestDomain('d2', priority: 90, dependencies: ['d1']);
    
    AppControl.registerDomains([domain2, domain1]);
    await AppControl.start();
    
    expect(domain1.initializeTime.isBefore(domain2.initializeTime), true);
  });
}
```

---

## Recovery Mode

In development/debug, enable extreme recovery:

```dart
AppControl.initialize(
  config: const RuntimeConfig(
    enableRecoveryMode: true,
    allowRuntimeReset: true,
  ),
);

// Later: full runtime reset without killing process
await AppControl.resetRuntime();
```

---

## Best Practices

1. **Register all domains early** - Before `AppControl.start()`
2. **Use appropriate reset levels** - Don't use `complete` when `soft` suffices
3. **Handle dependencies** - Declare domain dependencies explicitly
4. **Set priorities** - Higher priority = earlier initialization
5. **Listen to events** - Monitor phase changes for debugging
6. **Test thoroughly** - Use testing config for unit tests
7. **Avoid direct state** - Route all state through registered domains

---

## Examples

See [runtime_control_example.dart](../examples/runtime_control_example.dart) for complete implementation examples.

---

## Goal

> Treat the app like a **machine you can stop, reset, rebuild, and replay** at any time — safely, predictably, and intentionally.

This system provides exactly that capability.
