import 'package:flutter/material.dart';
import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';
import 'package:abdalsalam_logic_flutter/examples/app_state_detection_example.dart';

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
      title: 'App State Detection Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: AppStateDetectionExample(appStateManager: appStateManager),
    );
  }
}
