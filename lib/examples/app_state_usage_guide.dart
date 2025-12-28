// lib/examples/app_state_usage_guide.dart
/// # App State Detection - Complete Usage Guide
///
/// This guide demonstrates all detectable app states and best practices.
/// These examples show common patterns - convert to comments or separate files as needed.

// ============================================================================
// EXAMPLE 1: Basic Initialization
// ============================================================================

import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';

// Initialize in main.dart
Future<void> initializeAppState() async {
  final logger = LoggerServiceImpl();
  final appStateManager = AppStateManagerImpl.create(logger);
  await appStateManager.initialize();

  // Now you can access all state information
  print('App initialized and ready!');
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
        print('App is starting...');
        // Initialize critical services

      case AppLifecycleState.appInit:
        print('App initialization complete');
        // Load configuration

      case AppLifecycleState.appForegroundOnline:
        print('App in foreground and online');
        // Start syncing data

      case AppLifecycleState.appForegroundOffline:
        print('App in foreground but offline');
        // Show offline indicator
        // Use cached data

      case AppLifecycleState.appBackgroundOnline:
        print('App in background but online');
        // Pause animations, save state

      case AppLifecycleState.appBackgroundOffline:
        print('App in background and offline');
        // Stop all background operations

      case AppLifecycleState.appKill:
        print('App is being terminated');
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
      print('Using mobile layout');
      // Single column, optimize for touch
    } else if (device.isTablet) {
      print('Using tablet layout');
      // Two-column, larger touches targets
    } else if (device.isDesktop) {
      print('Using desktop layout');
      // Multi-column, mouse/keyboard optimized
    }

    // Responsive breakpoints
    switch (device.currentBreakpoint) {
      case ResponsiveBreakpoint.xs:
        print('Extra small screen: < 576px');
      case ResponsiveBreakpoint.sm:
        print('Small screen: 576-768px');
      case ResponsiveBreakpoint.md:
        print('Medium screen: 768-992px');
      case ResponsiveBreakpoint.lg:
        print('Large screen: 992-1200px');
      case ResponsiveBreakpoint.xl:
        print('Extra large screen: >= 1200px');
    }

    // Handle notch/safe areas
    if (device.hasNotch) {
      print('Device has notch - adjust UI');
    }

    if (device.isFullScreen) {
      print('Full screen device - use edge-to-edge');
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
      print('Fast connection (WiFi/4G/5G)');
      // Load high-quality images
      // Stream video at high bitrate
    } else if (network.isMobile) {
      print('Mobile connection - may be slow');
      // Load lower quality images
      // Reduce video quality
    } else if (network.isOnline) {
      print('Online but type unknown');
      // Default to medium quality
    } else {
      print('Offline');
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
      print('🔴 Low Power Mode - Optimize for battery');
      // Disable animations
      // Reduce refresh rate
      // Stop background sync
      // Pause video playback
    }

    if (battery.isLowBattery) {
      print('⚠️ Battery < 20% - Warn user');
      // Show low battery warning
      // Suggest power saving mode
    }

    if (battery.isCriticalBattery) {
      print('🚨 Battery < 10% - Critical');
      // Pause all non-essential activities
      // Suggest immediate charging
      // Auto-save important data
    }

    if (battery.isCharging) {
      print('⚡ Charging - Can run heavy tasks');
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
      print('♿ Screen Reader Enabled');
      // Ensure all interactive elements are labeled
      // Provide alternative text for images
      // Test with TalkBack/VoiceOver
    }

    if (a11y.isReduceMotionEnabled) {
      print('Reduce Motion Enabled');
      // Disable animations
      // Remove parallax effects
      // Use static transitions
    }

    if (a11y.textScaleFactor > 1.2) {
      print('Large Text: ${a11y.textScaleFactor}x');
      // Adjust layouts for larger text
      // Use flexible sizing
      // Test readability
    }

    if (a11y.isBoldTextEnabled) {
      print('Bold Text Enabled');
      // Use medium/bold font weights
      // Increase contrast
    }

    if (a11y.isHighContrastEnabled) {
      print('High Contrast Mode');
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
      print('🚨 Critical Memory Pressure');
      // Clear image cache
      // Stop background tasks
      // Release large objects
      // Minimize active features
    } else if (memory.isWarning) {
      print('⚠️ Memory Warning');
      // Clear old cached data
      // Reduce animation quality
      // Close unused connections
    } else {
      print('✅ Memory Normal');
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
      print('⌨️ Keyboard Visible: ${keyboard.height}px');
      // Adjust scroll position
      // Move floating action buttons
      // Resize input forms
    } else {
      print('⌨️ Keyboard Hidden');
      // Restore normal layout
      // Reset scroll position
    }
  });
}

// ============================================================================
// EXAMPLE 9: Complete Adaptive Example
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
      print('📱 Offline - Queue for later sync');
      return;
    }

    if (state.focus == AppFocusState.background) {
      if (isCharging && isFastConnection) {
        print('⚙️ Background sync: Optimal conditions');
        // Full sync
      } else {
        print('⚙️ Background sync: Limited (paused)');
        // Minimal sync
      }
      return;
    }

    // Foreground sync
    if (isCharging && isFastConnection && isMemoryOK) {
      print('🔄 Aggressive sync: Charging + Fast network');
      // Sync everything, high priority
    } else if (isFastConnection && isMemoryOK) {
      print('🔄 Normal sync: Good network');
      // Regular sync
    } else {
      print('🔄 Conservative sync: Limited resources');
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
    print('📱 State: ${state.lifecycle.name}');
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
