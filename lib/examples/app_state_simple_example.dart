// lib/examples/app_state_simple_example.dart
import 'package:flutter/material.dart';
import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';

class SimpleAppStateExample extends StatefulWidget {
  const SimpleAppStateExample({super.key});

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
    });

    appStateManager.deviceStream.listen((device) {
    });

    appStateManager.keyboardStream.listen((keyboard) {
    });

    appStateManager.batteryStream.listen((battery) {
    });

    appStateManager.networkStream.listen((network) {
    });

    appStateManager.memoryStream.listen((memory) {
    });

    appStateManager.accessibilityStream.listen((a11y) {
    });

    appStateManager.authStream.listen((auth) {
    });

    appStateManager.permissionsStream.listen((permissions) {
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
