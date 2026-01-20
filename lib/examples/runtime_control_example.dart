// lib/examples/runtime_control_example.dart

import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';
import 'package:flutter/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  AppControl.initialize(
    config: const RuntimeConfig.development(),
  );
  
  AppControl.registerDomains([
    AuthDomain(),
    StorageDomain(),
    NetworkDomain(),
  ]);
  
  await AppControl.start();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RuntimeControlDemo(),
    );
  }
}

class RuntimeControlDemo extends StatefulWidget {
  @override
  State<RuntimeControlDemo> createState() => _RuntimeControlDemoState();
}

class _RuntimeControlDemoState extends State<RuntimeControlDemo> {
  @override
  void initState() {
    super.initState();
    
    AppControl.phaseStream.listen((phase) {
      print('Runtime phase changed: $phase');
    });
    
    AppControl.eventStream.listen((event) {
      print('Runtime event: ${event.type}');
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Control Runtime Demo'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Refresh UI'),
            subtitle: const Text('Rebuild UI only - no state loss'),
            onTap: () => AppControl.refreshUI(),
          ),
          ListTile(
            title: const Text('Refresh App (Soft Reset)'),
            subtitle: const Text('UI rebuild - preserve all state'),
            onTap: () => AppControl.refreshApp(),
          ),
          ListTile(
            title: const Text('Reset States (Medium)'),
            subtitle: const Text('Clear transient state - preserve persistent'),
            onTap: () => AppControl.resetStates(ResetLevel.medium),
          ),
          ListTile(
            title: const Text('Reset States (Hard)'),
            subtitle: const Text('Clear all state - rebuild from scratch'),
            onTap: () => AppControl.resetStates(ResetLevel.hard),
          ),
          ListTile(
            title: const Text('Restart App'),
            subtitle: const Text('Complete app restart'),
            onTap: () => AppControl.restart(),
          ),
          ListTile(
            title: const Text('Reset Runtime'),
            subtitle: const Text('Reinitialize as if freshly launched'),
            onTap: () => AppControl.resetRuntime(),
          ),
          const Divider(),
          StreamBuilder<LifecyclePhase>(
            stream: AppControl.phaseStream,
            builder: (context, snapshot) {
              return ListTile(
                title: const Text('Current Phase'),
                subtitle: Text(snapshot.data?.toString() ?? 'Unknown'),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AuthDomain implements RuntimeDomain {
  bool _initialized = false;
  
  @override
  String get domainId => 'auth';
  
  @override
  String get domainName => 'Authentication';
  
  @override
  int get initializationPriority => 100;
  
  @override
  List<String> get dependencies => [];
  
  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _initialized = true;
  }
  
  @override
  Future<void> reset(ResetLevel level) async {
    if (level.shouldResetPersistentState) {
    }
  }
  
  @override
  Future<void> dispose() async {
    _initialized = false;
  }
  
  @override
  bool get isInitialized => _initialized;
  
  @override
  bool get canReset => true;
}

class StorageDomain implements RuntimeDomain {
  bool _initialized = false;
  
  @override
  String get domainId => 'storage';
  
  @override
  String get domainName => 'Storage';
  
  @override
  int get initializationPriority => 90;
  
  @override
  List<String> get dependencies => [];
  
  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _initialized = true;
  }
  
  @override
  Future<void> reset(ResetLevel level) async {
    if (level.shouldResetPersistentState) {
    }
  }
  
  @override
  Future<void> dispose() async {
    _initialized = false;
  }
  
  @override
  bool get isInitialized => _initialized;
  
  @override
  bool get canReset => true;
}

class NetworkDomain implements RuntimeDomain {
  bool _initialized = false;
  
  @override
  String get domainId => 'network';
  
  @override
  String get domainName => 'Network';
  
  @override
  int get initializationPriority => 80;
  
  @override
  List<String> get dependencies => ['storage'];
  
  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _initialized = true;
  }
  
  @override
  Future<void> reset(ResetLevel level) async {
    if (level.shouldResetTransientState) {
    }
  }
  
  @override
  Future<void> dispose() async {
    _initialized = false;
  }
  
  @override
  bool get isInitialized => _initialized;
  
  @override
  bool get canReset => true;
}
