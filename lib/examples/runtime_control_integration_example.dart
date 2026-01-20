// lib/examples/runtime_control_integration_example.dart

import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  AppControl.initialize(
    config: const RuntimeConfig.development(),
  );
  
  AppControl.registerDomains([
    AppStateDomain(),
    StorageGatewayDomain(),
    NetworkingDomain(),
    AuthenticationDomain(),
    LoggingDomain(),
  ]);
  
  await AppControl.start();
  
  runApp(const IntegrationApp());
}

class IntegrationApp extends StatelessWidget {
  const IntegrationApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RuntimePhaseBuilder(
        builder: (context, phase) {
          if (phase == LifecyclePhase.initializing) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          if (phase == LifecyclePhase.error) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('Runtime Error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => AppControl.restart(),
                      child: const Text('Restart App'),
                    ),
                  ],
                ),
              ),
            );
          }
          
          return const HomePage();
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Runtime Control Integration'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => AppControl.refreshUI(),
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt),
            onPressed: () => AppControl.restart(),
          ),
        ],
      ),
      body: ListView(
        children: [
          const _RuntimeStatusCard(),
          const Divider(),
          const _ControlActionsCard(),
          const Divider(),
          const _DomainStatusCard(),
        ],
      ),
    );
  }
}

class _RuntimeStatusCard extends StatelessWidget {
  const _RuntimeStatusCard();
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Runtime Status',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            StreamBuilder<LifecyclePhase>(
              stream: AppControl.phaseStream,
              initialData: AppControl.currentPhase,
              builder: (context, snapshot) {
                final phase = snapshot.data ?? LifecyclePhase.uninitialized;
                return Row(
                  children: [
                    const Text('Phase: '),
                    Chip(
                      label: Text(phase.name),
                      backgroundColor: _getPhaseColor(phase),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Running: '),
                Text(
                  AppControl.isRunning ? 'Yes' : 'No',
                  style: TextStyle(
                    color: AppControl.isRunning ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Initialized: '),
                Text(
                  AppControl.isInitialized ? 'Yes' : 'No',
                  style: TextStyle(
                    color: AppControl.isInitialized ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getPhaseColor(LifecyclePhase phase) {
    if (phase.isActive) return Colors.green.shade100;
    if (phase.isTransitioning) return Colors.orange.shade100;
    if (phase.isTerminal) return Colors.red.shade100;
    return Colors.grey.shade100;
  }
}

class _ControlActionsCard extends StatelessWidget {
  const _ControlActionsCard();
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Control Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => AppControl.refreshUI(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh UI'),
                ),
                ElevatedButton.icon(
                  onPressed: () => AppControl.refreshApp(),
                  icon: const Icon(Icons.refresh_outlined),
                  label: const Text('Refresh App'),
                ),
                ElevatedButton.icon(
                  onPressed: () => AppControl.resetStates(ResetLevel.medium),
                  icon: const Icon(Icons.restore),
                  label: const Text('Medium Reset'),
                ),
                ElevatedButton.icon(
                  onPressed: () => AppControl.resetStates(ResetLevel.hard),
                  icon: const Icon(Icons.restore_page),
                  label: const Text('Hard Reset'),
                ),
                ElevatedButton.icon(
                  onPressed: () => AppControl.restart(),
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Restart'),
                ),
                ElevatedButton.icon(
                  onPressed: () => AppControl.resetRuntime(),
                  icon: const Icon(Icons.power_settings_new),
                  label: const Text('Reset Runtime'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DomainStatusCard extends StatelessWidget {
  const _DomainStatusCard();
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Registered Domains',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...AppControl.registry.getAllDomains().map((domain) {
              final initialized = AppControl.registry.isInitialized(domain.domainId);
              return ListTile(
                leading: Icon(
                  initialized ? Icons.check_circle : Icons.circle_outlined,
                  color: initialized ? Colors.green : Colors.grey,
                ),
                title: Text(domain.domainName),
                subtitle: Text('Priority: ${domain.initializationPriority}'),
                trailing: domain.dependencies.isNotEmpty
                    ? Chip(label: Text('Deps: ${domain.dependencies.length}'))
                    : null,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class AppStateDomain implements RuntimeDomain, RuntimeDomainMetadata {
  late AppStateManager _appStateManager;
  bool _initialized = false;
  
  @override
  String get domainId => 'app_state';
  
  @override
  String get domainName => 'App State Manager';
  
  @override
  int get initializationPriority => 100;
  
  @override
  List<String> get dependencies => [];
  
  @override
  Future<void> initialize() async {
    _appStateManager = AppStateManagerImpl();
    await _appStateManager.initialize(const AppStateConfig.minimal());
    _initialized = true;
  }
  
  @override
  Future<void> reset(ResetLevel level) async {
    if (level.shouldResetTransientState) {
      await _appStateManager.dispose();
      await _appStateManager.initialize(const AppStateConfig.minimal());
    }
  }
  
  @override
  Future<void> dispose() async {
    await _appStateManager.dispose();
    _initialized = false;
  }
  
  @override
  bool get isInitialized => _initialized;
  
  @override
  bool get canReset => true;
  
  @override
  String get category => 'core';
  
  @override
  bool get isCore => true;
  
  @override
  bool get isPersistent => false;
  
  @override
  bool get isOptional => false;
}

class StorageGatewayDomain implements RuntimeDomain, RuntimeDomainMetadata {
  bool _initialized = false;
  
  @override
  String get domainId => 'storage';
  
  @override
  String get domainName => 'Storage Gateway';
  
  @override
  int get initializationPriority => 95;
  
  @override
  List<String> get dependencies => [];
  
  @override
  Future<void> initialize() async {
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
  
  @override
  String get category => 'core';
  
  @override
  bool get isCore => true;
  
  @override
  bool get isPersistent => true;
  
  @override
  bool get isOptional => false;
}

class NetworkingDomain implements RuntimeDomain, RuntimeDomainMetadata {
  bool _initialized = false;
  
  @override
  String get domainId => 'networking';
  
  @override
  String get domainName => 'API Client';
  
  @override
  int get initializationPriority => 85;
  
  @override
  List<String> get dependencies => ['storage'];
  
  @override
  Future<void> initialize() async {
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
  
  @override
  String get category => 'networking';
  
  @override
  bool get isCore => true;
  
  @override
  bool get isPersistent => false;
  
  @override
  bool get isOptional => false;
}

class AuthenticationDomain implements RuntimeDomain, RuntimeDomainMetadata {
  bool _initialized = false;
  
  @override
  String get domainId => 'auth';
  
  @override
  String get domainName => 'Authentication';
  
  @override
  int get initializationPriority => 80;
  
  @override
  List<String> get dependencies => ['storage', 'networking'];
  
  @override
  Future<void> initialize() async {
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
  
  @override
  String get category => 'authentication';
  
  @override
  bool get isCore => true;
  
  @override
  bool get isPersistent => true;
  
  @override
  bool get isOptional => false;
}

class LoggingDomain implements RuntimeDomain, RuntimeDomainMetadata {
  bool _initialized = false;
  
  @override
  String get domainId => 'logging';
  
  @override
  String get domainName => 'Logging System';
  
  @override
  int get initializationPriority => 100;
  
  @override
  List<String> get dependencies => [];
  
  @override
  Future<void> initialize() async {
    _initialized = true;
  }
  
  @override
  Future<void> reset(ResetLevel level) async {
  }
  
  @override
  Future<void> dispose() async {
    _initialized = false;
  }
  
  @override
  bool get isInitialized => _initialized;
  
  @override
  bool get canReset => false;
  
  @override
  String get category => 'core';
  
  @override
  bool get isCore => true;
  
  @override
  bool get isPersistent => false;
  
  @override
  bool get isOptional => false;
}
