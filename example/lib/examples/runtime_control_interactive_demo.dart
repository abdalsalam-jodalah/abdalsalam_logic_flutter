// lib/examples/runtime_control_interactive_demo.dart

import 'dart:async';
import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';
import 'package:flutter/material.dart';

class InteractiveDomain implements RuntimeDomain, RuntimeDomainMetadata {
  bool _initialized = false;
  int initializationCount = 0;
  int resetCount = 0;
  int disposeCount = 0;
  DateTime? lastAction;
  
  @override
  String get domainId => 'interactive';
  
  @override
  String get domainName => 'Interactive Demo';
  
  @override
  int get initializationPriority => 100;
  
  @override
  List<String> get dependencies => [];
  
  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _initialized = true;
    initializationCount++;
    lastAction = DateTime.now();
    debugPrint('✅ Interactive Domain initialized (count: $initializationCount)');
  }
  
  @override
  Future<void> reset(ResetLevel level) async {
    await Future.delayed(const Duration(milliseconds: 300));
    resetCount++;
    lastAction = DateTime.now();
    debugPrint('🔄 Interactive Domain reset with ${level.name} (count: $resetCount)');
  }
  
  @override
  Future<void> dispose() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _initialized = false;
    disposeCount++;
    lastAction = DateTime.now();
    debugPrint('🗑️ Interactive Domain disposed (count: $disposeCount)');
  }
  
  @override
  bool get isInitialized => _initialized;
  
  @override
  bool get canReset => true;
  
  @override
  String get category => 'demo';
  
  @override
  bool get isCore => false;
  
  @override
  bool get isPersistent => true;
  
  @override
  bool get isOptional => false;
}

class RuntimeControlInteractiveDemo extends StatefulWidget {
  const RuntimeControlInteractiveDemo({super.key});
  
  @override
  State<RuntimeControlInteractiveDemo> createState() => _RuntimeControlInteractiveDemoState();
}

class _RuntimeControlInteractiveDemoState extends State<RuntimeControlInteractiveDemo> {
  final InteractiveDomain _domain = InteractiveDomain();
  final List<String> _actionLog = [];
  StreamSubscription<RuntimeEvent>? _runtimeSub;
  StreamSubscription<StateEvent>? _stateSub;
  StreamSubscription<UITreeEvent>? _uiSub;
  bool _initialized = false;
  
  @override
  void initState() {
    super.initState();
    _initializeAppControl();
  }
  
  Future<void> _initializeAppControl() async {
    try {
      AppControl.initialize(config: const RuntimeConfig.development());
      AppControl.registerDomains([_domain]);
      await AppControl.start();
      
      _runtimeSub = AppControl.eventStream.listen((event) {
        setState(() {
          _actionLog.insert(0, '${DateTime.now().toString().substring(11, 19)} - Runtime: ${event.type.name}');
          if (_actionLog.length > 50) _actionLog.removeLast();
        });
      });
      
      _stateSub = AppControl.stateController.eventStream.listen((event) {
        setState(() {
          _actionLog.insert(0, '${DateTime.now().toString().substring(11, 19)} - State: ${event.type.name} ${event.domainId ?? ""}');
          if (_actionLog.length > 50) _actionLog.removeLast();
        });
      });
      
      _uiSub = AppControl.uiController.eventStream.listen((event) {
        setState(() {
          _actionLog.insert(0, '${DateTime.now().toString().substring(11, 19)} - UI: ${event.type.name}');
          if (_actionLog.length > 50) _actionLog.removeLast();
        });
      });
      
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      setState(() {
        _actionLog.insert(0, 'ERROR: $e');
      });
    }
  }
  
  @override
  void dispose() {
    _runtimeSub?.cancel();
    _stateSub?.cancel();
    _uiSub?.cancel();
    super.dispose();
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
        setState(() {});
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
    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Runtime Control - Interactive Demo'),
        elevation: 2,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Init Count',
                        value: '${_domain.initializationCount}',
                        icon: Icons.rocket_launch,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatCard(
                        title: 'Reset Count',
                        value: '${_domain.resetCount}',
                        icon: Icons.refresh,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Dispose Count',
                        value: '${_domain.disposeCount}',
                        icon: Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatCard(
                        title: 'Status',
                        value: _domain.isInitialized ? 'Ready' : 'Stopped',
                        icon: _domain.isInitialized ? Icons.check_circle : Icons.cancel,
                        color: _domain.isInitialized ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Runtime Controls',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                
                ElevatedButton.icon(
                  onPressed: () => _executeAction('Restart', () => AppControl.restart()),
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Restart Runtime'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 8),
                
                ElevatedButton.icon(
                  onPressed: () => _executeAction('Refresh UI', () => AppControl.refreshUI()),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh UI'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 8),
                
                ElevatedButton.icon(
                  onPressed: () => _executeAction('Refresh App', () => AppControl.refreshApp()),
                  icon: const Icon(Icons.cached),
                  label: const Text('Refresh App'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 16),
                
                Text(
                  'Reset Levels',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                
                _buildResetButton(ResetLevel.uiOnly, 'UI Only', Colors.lightBlue),
                _buildResetButton(ResetLevel.soft, 'Soft Reset', Colors.orange),
                _buildResetButton(ResetLevel.medium, 'Medium Reset', Colors.deepOrange),
                _buildResetButton(ResetLevel.hard, 'Hard Reset', Colors.red),
                _buildResetButton(ResetLevel.complete, 'Complete Reset', Colors.red.shade900),
              ],
            ),
          ),
          
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_note, size: 20),
                        const SizedBox(width: 8),
                        const Text('Action Log', style: TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _actionLog.clear();
                            });
                          },
                          icon: const Icon(Icons.clear_all, size: 16),
                          label: const Text('Clear'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _actionLog.isEmpty
                        ? const Center(
                            child: Text('No actions yet. Try pressing a button!'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: _actionLog.length,
                            itemBuilder: (context, index) {
                              final log = _actionLog[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  log,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildResetButton(ResetLevel level, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton(
        onPressed: () => _executeAction('Reset: ${level.name}', () => AppControl.resetStates(level)),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          padding: const EdgeInsets.all(12),
        ),
        child: Text(label),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
