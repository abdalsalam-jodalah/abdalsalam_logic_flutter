// lib/examples/app_state_usage_guide.dart

// ============================================================================
// EXAMPLE 1: Basic Initialization
// ============================================================================

import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';

// Initialize in main.dart
Future<void> initializeAppState() async {
  final appStateManager = AppStateManagerImpl.create();
  await appStateManager.initialize();

  // Now you can access all state information
}

// ============================================================================
// EXAMPLE 2: Detecting App Lifecycle
// ============================================================================

// Example code - intended to be copied into your implementation
// ignore: unused_element
void _detectAppLifecycle(AppStateManager appState) {
  appState.stateStream.listen((state) {
    switch (state.lifecycle) {
      case AppLifecycleState.appStart:
        // Initialize critical services

      case AppLifecycleState.appInit:
        // Load configuration

      case AppLifecycleState.appForegroundOnline:
        // Start syncing data

      case AppLifecycleState.appForegroundOffline:
        // Show offline indicator
        // Use cached data

      case AppLifecycleState.appBackgroundOnline:
        // Pause animations, save state

      case AppLifecycleState.appBackgroundOffline:
        // Stop all background operations

      case AppLifecycleState.appKill:
        // Save critical state, close connections
    }
  });
}

// ============================================================================
// EXAMPLE 3: Device-Aware UI Adaptation
// ============================================================================

// Example code - intended to be copied into your implementation
// ignore: unused_element
void _adaptUIToDevice(AppStateManager appState) {
  appState.deviceStream.listen((device) {
    // Adapt layout based on device type
    if (device.isPhone) {
      // Single column, optimize for touch
    } else if (device.isTablet) {
      // Two-column, larger touches targets
    } else if (device.isDesktop) {
      // Multi-column, mouse/keyboard optimized
    }

    // Responsive breakpoints
    switch (device.currentBreakpoint) {
      case ResponsiveBreakpoint.xs:
        break;
      case ResponsiveBreakpoint.sm:
        break;
      case ResponsiveBreakpoint.md:
        break;
      case ResponsiveBreakpoint.lg:
        break;
      case ResponsiveBreakpoint.xl:
        break;
    }

    // Handle notch/safe areas
    if (device.hasNotch) {
      // adjust UI
    }

    if (device.isFullScreen) {
      // use edge-to-edge
    }
  });
}

// ============================================================================
// EXAMPLE 4: Network-Aware Data Loading
// ============================================================================

// Example code - intended to be copied into your implementation
// ignore: unused_element
void _networkAwareDataLoading(AppStateManager appState) {
  appState.networkStream.listen((network) {
    if (network.isFastConnection) {
      // Load high-quality images
      // Stream video at high bitrate
    } else if (network.isMobile) {
      // Load lower quality images
      // Reduce video quality
    } else if (network.isOnline) {
      // Default to medium quality
    } else {
      // Use cached data only
    }
  });
}

// ============================================================================
// EXAMPLE 5: Battery-Aware Performance Optimization
// ============================================================================

// Example code - intended to be copied into your implementation
// ignore: unused_element
void _batteryAwareOptimization(AppStateManager appState) {
  appState.batteryStream.listen((battery) {
    if (battery.isLowPowerMode) {
      // Disable animations
      // Reduce refresh rate
      // Stop background sync
      // Pause video playback
    }

    if (battery.isLowBattery) {
      // Show low battery warning
      // Suggest power saving mode
    }

    if (battery.isCriticalBattery) {
      // Pause all non-essential activities
      // Suggest immediate charging
      // Auto-save important data
    }

    if (battery.isCharging) {
      // Sync data
      // Download updates
      // Process offline queue
    }
  });
}

// ============================================================================
// EXAMPLE 6: Accessibility-Aware UI
// ============================================================================

// Example code - intended to be copied into your implementation
// ignore: unused_element
void _accessibilityAwareUI(AppStateManager appState) {
  appState.accessibilityStream.listen((a11y) {
    if (a11y.isScreenReaderEnabled) {
      // Ensure all interactive elements are labeled
      // Provide alternative text for images
      // Test with TalkBack/VoiceOver
    }

    if (a11y.isReduceMotionEnabled) {
      // Disable animations
      // Remove parallax effects
      // Use static transitions
    }

    if (a11y.textScaleFactor > 1.2) {
      // Adjust layouts for larger text
      // Use flexible sizing
      // Test readability
    }

    if (a11y.isBoldTextEnabled) {
      // Use medium/bold font weights
      // Increase contrast
    }

    if (a11y.isHighContrastEnabled) {
      // Use high contrast colors
      // Avoid light gray on white
    }
  });
}

// ============================================================================
// EXAMPLE 7: Memory Pressure Handling
// ============================================================================

// Example code - intended to be copied into your implementation
// ignore: unused_element
void _memoryPressureHandling(AppStateManager appState) {
  appState.memoryStream.listen((memory) {
    if (memory.isCritical) {
      // Clear image cache
      // Stop background tasks
      // Release large objects
      // Minimize active features
    } else if (memory.isWarning) {
      // Clear old cached data
      // Reduce animation quality
      // Close unused connections
    } else {
      // Normal operations
    }
  });
}

// ============================================================================
// EXAMPLE 8: Keyboard State Detection
// ============================================================================

// Example code - intended to be copied into your implementation
// ignore: unused_element
void _keyboardStateDetection(AppStateManager appState) {
  appState.keyboardStream.listen((keyboard) {
    if (keyboard.isVisible) {
      // Adjust scroll position
      // Move floating action buttons
      // Resize input forms
    } else {
      // Restore normal layout
      // Reset scroll position
    }
  });
}

// ============================================================================
// EXAMPLE 9: Permissions Management
// ============================================================================

// Example code - intended to be copied into your implementation
// ignore: unused_element
void _permissionsManagement(AppStateManager appState) {
  appState.permissionsStream.listen((permissions) {
    // Check if specific permission is granted
    if (permissions.isGranted(PermissionType.camera)) {
      // Camera access allowed - start camera stream
    }

    if (permissions.isGranted(PermissionType.location)) {
      // Location access allowed - start location updates
    }

    if (permissions.isDenied(PermissionType.microphone)) {
      // Microphone denied - disable voice features
    }

    if (permissions.isPermanentlyDenied(PermissionType.contacts)) {
      // Permanently denied - show app settings prompt
    }

    // Get all granted permissions
    // ignore: unused_local_variable
    final grantedPerms = permissions.getGrantedPermissions();

    // Get all denied permissions
    // ignore: unused_local_variable
    final deniedPerms = permissions.getDeniedPermissions();

    // Get all permanently denied permissions
    // ignore: unused_local_variable
    final permaDeniedPerms = permissions.getPermanentlyDeniedPermissions();

    // Get status of specific permission
    // ignore: unused_local_variable
    final photoStatus = permissions.getStatus(PermissionType.photos);
  });
}

// ============================================================================
// EXAMPLE 10: Complete Adaptive Example
// ============================================================================

class AdaptiveDataSyncService {
  final AppStateManager appState;

  AdaptiveDataSyncService(this.appState) {
    _setupSyncListeners();
  }

  void _setupSyncListeners() {
    // Listen to multiple state streams for smart sync decisions
    appState.stateStream.listen((state) {
      _decideSyncStrategy(
        state: state,
        battery: appState.batteryInfo,
        network: appState.networkInfo,
      );
    });

    appState.batteryStream.listen((_) {
      _decideSyncStrategy(
        state: appState.currentState,
        battery: appState.batteryInfo,
        network: appState.networkInfo,
      );
    });

    appState.networkStream.listen((_) {
      _decideSyncStrategy(
        state: appState.currentState,
        battery: appState.batteryInfo,
        network: appState.networkInfo,
      );
    });
  }

  void _decideSyncStrategy({
    required AppStateInfo state,
    BatteryInfo? battery,
    NetworkInfo? network,
  }) {
    final canSync = state.connectivity == ConnectivityState.online;
    final isCharging = battery?.isCharging ?? false;
    final isFastConnection = network?.isFastConnection ?? false;
    final isMemoryOK = true; // Check actual memory

    if (!canSync) {
      return;
    }

    if (state.focus == AppFocusState.background) {
      if (isCharging && isFastConnection) {
        // Full sync
      } else {
        // Minimal sync
      }
      return;
    }

    // Foreground sync
    if (isCharging && isFastConnection && isMemoryOK) {
      // Sync everything, high priority
    } else if (isFastConnection && isMemoryOK) {
      // Regular sync
    } else {
      // Minimal, essential data only
    }
  }
}

// ============================================================================
// EXAMPLE 10: Complete Example in main()
// ============================================================================

/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app state
  final logger = LoggerServiceImpl();
  final appState = AppStateManagerImpl.create(logger);
  await appState.initialize();

  // Setup listeners
  _setupAppStateListeners(appState);

  runApp(MyApp(appState: appState));
}

void _setupAppStateListeners(AppStateManager appState) {
  // Lifecycle monitoring
  appState.stateStream.listen((state) {
  });

  // Sync optimization
  appState.networkStream.listen((network) {
    if (network.isFastConnection) {
      // Sync large files
    }
  });

  // Battery optimization
  appState.batteryStream.listen((battery) {
    if (battery.isLowPowerMode) {
      // Disable animations
    }
  });

  // Accessibility support
  appState.accessibilityStream.listen((a11y) {
    if (a11y.isReduceMotionEnabled) {
      // Disable animations
    }
  });
}

class MyApp extends StatelessWidget {
  final AppStateManager appState;

  const MyApp({required this.appState});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(appState: appState),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final AppStateManager appState;

  const MyHomePage({required this.appState});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppStateInfo>(
      stream: appState.stateStream,
      initialData: appState.currentState,
      builder: (context, snapshot) {
        final state = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            title: Text('App State: ${state.lifecycle.name}'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Online: ${state.connectivity.name}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  'Focus: ${state.focus.name}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
*/
