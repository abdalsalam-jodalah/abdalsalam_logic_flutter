import 'package:flutter/material.dart';
import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';
import 'package:abdalsalam_logic_flutter/examples/app_state_detection_example.dart';
import 'storage_designer.dart';
import 'storage_inspector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final logger = LoggerServiceImpl();
  
  // Create config with all features enabled for demo purposes
  // In production, only enable features you actually need
  const config = AppStateConfig.all();
  
  final appStateManager = AppStateManagerImpl.create(logger, config: config);
  await appStateManager.initialize();
  
  runApp(MyApp(appStateManager: appStateManager));
}

class MyApp extends StatelessWidget {
  final AppStateManager appStateManager;

  const MyApp({required this.appStateManager, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Logic Package Examples',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: HomeMenu(appStateManager: appStateManager),
    );
  }
}

class HomeMenu extends StatelessWidget {
  final AppStateManager appStateManager;

  const HomeMenu({required this.appStateManager, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Examples')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose a demo'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => AppStateDetectionExample(
                    appStateManager: appStateManager,
                  ),
                ));
              },
              child: const Text('App State Detection'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const StorageDesignerPage(),
                ));
              },
              child: const Text('Storage Designer'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const StorageInspectorPage(),
                ));
              },
              child: const Text('Storage Inspector'),
            ),
          ],
        ),
      ),
    );
  }
}
