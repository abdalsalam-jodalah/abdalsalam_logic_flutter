import 'package:flutter/material.dart';
import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';
import 'package:abdalsalam_logic_flutter/examples/app_state_detection_example.dart';
import 'package:abdalsalam_logic_flutter/examples/runtime_control_comprehensive_ui.dart';
import 'package:abdalsalam_logic_flutter/examples/runtime_control_interactive_demo.dart';
import 'storage_designer.dart';
import 'storage_inspector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  const logConfig = LogConfig(
    coreConfig: LoggerCoreConfig(
      environment: LogEnvironment.development,
      environmentLevels: {
        LogEnvironment.development: LogLevel.debug,
        LogEnvironment.profile: LogLevel.info,
        LogEnvironment.release: LogLevel.warning,
      },
      targetsPerEnvironment: {
        LogEnvironment.development: {LogTarget.console},
        LogEnvironment.profile: {LogTarget.console},
        LogEnvironment.release: {LogTarget.console, LogTarget.file},
      },
      allowUnregisteredModules: true,
      strictMode: false,
    ),
    moduleConfig: LoggerModuleRegistryConfig(
      globalLevel: LogLevel.debug,
      enableColors: true,
      modules: {},
    ),
  );
  
  LoggerImpl.initialize(logConfig);
  
  AppControl.initialize(config: const RuntimeConfig.development());
  AppControl.registerDomains([
    LoggingDomain(),
    StorageDomain(),
    NetworkingDomain(),
    AuthDomain(),
    AppStateDomain(),
    CacheDomain(),
    SyncDomain(),
  ]);
  await AppControl.start();
  
  const config = AppStateConfig.all();
  
  final appStateManager = AppStateManagerImpl.create(config: config);
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
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const RuntimeControlInteractiveDemo(),
                ));
              },
              child: const Text('Runtime Control (Interactive)'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const RuntimeControlDemoApp(),
                ));
              },
              child: const Text('Runtime Control (Full Demo)'),
            ),
          ],
        ),
      ),
    );
  }
}
