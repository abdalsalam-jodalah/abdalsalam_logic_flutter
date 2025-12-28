import 'package:flutter/material.dart';
import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';
import 'package:abdalsalam_logic_flutter/examples/app_state_detection_example.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final logger = LoggerServiceImpl();
  final appStateManager = AppStateManagerImpl.create(logger);
  await appStateManager.initialize();
  
  runApp(MyApp(appStateManager: appStateManager));
}

class MyApp extends StatelessWidget {
  final AppStateManager appStateManager;

  const MyApp({required this.appStateManager, Key? key}) : super(key: key);

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
