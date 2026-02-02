// lib/examples/runtime_control_example.dart

import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';
import 'package:flutter/material.dart';
import '../src/runtime_control/domains/auth_runtime_domain.dart';
import '../src/runtime_control/domains/storage_runtime_domain.dart';
import '../src/runtime_control/domains/network_runtime_domain.dart';
import '../src/runtime_control/domains/memory_runtime_domain.dart';
import '../src/runtime_control/domains/service_registry_runtime_domain.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  AppControl.initialize(
    config: const RuntimeConfig.development(),
  );
  
  AppControl.registerDomains([
    ServiceRegistryRuntimeDomain(),
    MemoryRuntimeDomain(),
    AuthRuntimeDomain(),
    StorageRuntimeDomain(), 
    NetworkRuntimeDomain(),
  ]);
  
  await AppControl.start();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Runtime Control Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const RuntimeControlDemo(),
    );
  }
}

class RuntimeControlDemo extends StatefulWidget {
  const RuntimeControlDemo({super.key});

  @override
  State<RuntimeControlDemo> createState() => _RuntimeControlDemoState();
}

class _RuntimeControlDemoState extends State<RuntimeControlDemo> {
  @override
  void initState() {
    super.initState();
    
    AppControl.phaseStream.listen((phase) {
      debugPrint('Runtime phase changed: $phase');
    });
    
    AppControl.eventStream.listen((event) {
      debugPrint('Runtime event: ${event.type}');
    });
  }
  
  Future<void> _executeAction(String actionName, Future<void> Function() action) async {
    try {
      await action();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ $actionName completed!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $actionName failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Runtime Control Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'App Control Actions',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          _buildActionCard(
            'Refresh UI',
            'Rebuild UI only - no state loss',
            Icons.refresh,
            Colors.blue,
            () => _executeAction('Refresh UI', AppControl.refreshUI),
          ),
          
          _buildActionCard(
            'Refresh App (Soft Reset)',
            'UI rebuild - preserve all state',
            Icons.cached,
            Colors.green,
            () => _executeAction('Refresh App', AppControl.refreshApp),
          ),
          
          _buildActionCard(
            'Reset States (Medium)',
            'Clear transient state - preserve persistent',
            Icons.layers_clear,
            Colors.orange,
            () => _executeAction('Reset Medium', () => AppControl.resetStates(ResetLevel.medium)),
          ),
          
          _buildActionCard(
            'Reset States (Hard)',
            'Clear all state - rebuild from scratch',
            Icons.delete_sweep,
            Colors.red,
            () => _executeAction('Reset Hard', () => AppControl.resetStates(ResetLevel.hard)),
          ),
          
          _buildActionCard(
            'Restart App',
            'Complete app restart',
            Icons.restart_alt,
            Colors.purple,
            () => _executeAction('Restart App', AppControl.restart),
          ),
          
          _buildActionCard(
            'Reset Runtime',
            'Reinitialize as if freshly launched',
            Icons.settings_backup_restore,
            Colors.indigo,
            () => _executeAction('Reset Runtime', AppControl.resetRuntime),
          ),
          
          const SizedBox(height: 24),
          const Text(
            'Runtime Status',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          StreamBuilder<LifecyclePhase>(
            stream: AppControl.phaseStream,
            builder: (context, snapshot) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Phase',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.data?.toString() ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 16,
                          color: _getPhaseColor(snapshot.data),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
  
  Color? _getPhaseColor(LifecyclePhase? phase) {
    if (phase == null) return null;
    
    switch (phase) {
      case LifecyclePhase.running:
        return Colors.green;
      case LifecyclePhase.initializing:
      case LifecyclePhase.restarting:
      case LifecyclePhase.refreshing:
      case LifecyclePhase.resetting:
        return Colors.orange;
      case LifecyclePhase.error:
        return Colors.red;
      case LifecyclePhase.disposed:
        return Colors.grey;
      default:
        return null;
    }
  }
}