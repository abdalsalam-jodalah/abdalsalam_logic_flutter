// lib/examples/app_state_simple_example.dart
import 'package:flutter/material.dart';
import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';

class SimpleAppStateExample extends StatefulWidget {
  const SimpleAppStateExample({Key? key}) : super(key: key);

  @override
  State<SimpleAppStateExample> createState() => _SimpleAppStateExampleState();
}

class _SimpleAppStateExampleState extends State<SimpleAppStateExample> {
  late AppStateManager appStateManager;

  @override
  void initState() {
    super.initState();
    _initializeAppState();
  }

  Future<void> _initializeAppState() async {
    final logger = LoggerServiceImpl();
    appStateManager = AppStateManagerImpl.create(logger);
    await appStateManager.initialize();

    _setupStateListeners();
    setState(() {});
  }

  void _setupStateListeners() {
    appStateManager.stateStream.listen((state) {
      print('📱 App State: ${state.lifecycle.name}');
      print(
        '   Focus: ${state.focus.name}, Online: ${state.connectivity.name}',
      );
    });

    appStateManager.deviceStream.listen((device) {
      print(
        '📱 Device: ${device.type.name} - ${device.screenWidth}x${device.screenHeight}',
      );
      print(
        '   Orientation: ${device.orientation.name}, Breakpoint: ${device.breakpoint.name}',
      );
    });

    appStateManager.keyboardStream.listen((keyboard) {
      print(
        '⌨️ Keyboard: ${keyboard.isVisible ? 'Visible' : 'Hidden'} (${keyboard.height.toStringAsFixed(0)}px)',
      );
    });

    appStateManager.batteryStream.listen((battery) {
      print(
        '🔋 Battery: ${battery.batteryLevel}% - ${battery.batteryState.name}',
      );
      if (battery.isLowBattery) print('   ⚠️ Low Battery!');
    });

    appStateManager.networkStream.listen((network) {
      print(
        '📡 Network: ${network.type.name} - ${network.isOnline ? 'Online' : 'Offline'}',
      );
    });

    appStateManager.memoryStream.listen((memory) {
      print('💾 Memory: ${memory.pressureLevel.name}');
      if (memory.shouldReduceMemoryUsage) print('   ⚠️ Reduce Memory Usage!');
    });

    appStateManager.accessibilityStream.listen((a11y) {
      if (a11y.hasAccessibilityFeatures) {
        print('♿ Accessibility: ${a11y.textScaleFactor}x scale');
      }
    });

    appStateManager.authStream.listen((auth) {
      print('🔐 Auth: ${auth.status.name}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App State Listener Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Check console for app state changes'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                appStateManager.setAuthenticated({'name': 'User'}, 'token123');
              },
              child: const Text('Simulate Login'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                appStateManager.setUnauthenticated();
              },
              child: const Text('Simulate Logout'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Future<void> dispose() async {
    await appStateManager.dispose();
    super.dispose();
  }
}
