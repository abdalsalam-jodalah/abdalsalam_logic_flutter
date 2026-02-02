// lib/examples/domain_registration_example.dart
// Example showing proper domain registration with enforcement

import 'package:flutter/material.dart';
import '../src/runtime_control/app_control.dart';
import '../src/runtime_control/runtime_config.dart';
import '../src/runtime_control/runtime_domain.dart';
import '../src/runtime_control/reset_level.dart';
import '../src/runtime_control/domains/storage_runtime_domain.dart';
import '../src/runtime_control/domains/auth_runtime_domain.dart';

class DomainRegistrationExample extends StatefulWidget {
  const DomainRegistrationExample({super.key});

  @override
  State<DomainRegistrationExample> createState() => _DomainRegistrationExampleState();
}

class _DomainRegistrationExampleState extends State<DomainRegistrationExample> {
  String _status = 'Not started';
  final List<String> _logs = [];

  void _log(String message) {
    setState(() {
      _logs.add('${DateTime.now().toLocal().toString().substring(11, 23)}: $message');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Domain Registration Example'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status: $_status',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This example shows proper domain registration with enforcement.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: _demonstrateCorrectRegistration,
                  child: const Text('✅ Correct Registration'),
                ),
                
                const SizedBox(height: 8),
                
                ElevatedButton(
                  onPressed: _demonstrateIncorrectRegistration,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text('❌ Incorrect Registration (Errors)'),
                ),
                
                const SizedBox(height: 8),
                
                ElevatedButton(
                  onPressed: _demonstrateStrictMode,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('🔒 Strict Mode Example'),
                ),
                
                const SizedBox(height: 8),
                
                ElevatedButton(
                  onPressed: _clearLogs,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: const Text('Clear Logs'),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Logs:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            _logs[index],
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
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

  Future<void> _demonstrateCorrectRegistration() async {
    try {
      setState(() {
        _status = 'Demonstrating correct registration...';
      });
      
      _log('🔄 Starting correct registration example...');
      
      // Reset any existing instance
      AppControl.reset();
      
      // Initialize with development config
      AppControl.initialize(config: const RuntimeConfig.development());
      _log('✅ Initialized with development config');
      
      // Register domains correctly
      AppControl.registerDomains([
        StorageRuntimeDomain(),  // priority: 50, no deps
        AuthRuntimeDomain(),     // priority: 100, deps: ['storage']
        PaymentDomain(),         // Custom domain with proper setup
      ]);
      _log('✅ Registered 3 domains correctly');
      
      // Start runtime
      await AppControl.start();
      _log('✅ Runtime started successfully');
      
      // Check initialization order
      final domains = AppControl.registry.getAllDomains();
      for (final domain in domains) {
        _log('📋 Domain: ${domain.domainId} (${domain.domainName})');
      }
      
      setState(() {
        _status = 'Correct registration completed ✅';
      });
      
    } catch (e) {
      _log('❌ Error: $e');
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  Future<void> _demonstrateIncorrectRegistration() async {
    try {
      setState(() {
        _status = 'Demonstrating incorrect registration...';
      });
      
      _log('🔄 Starting incorrect registration examples...');
      
      // Example 1: Duplicate domain ID
      try {
        AppControl.reset();
        AppControl.initialize(config: const RuntimeConfig.development());
        
        AppControl.registerDomain(StorageRuntimeDomain());
        AppControl.registerDomain(StorageRuntimeDomain()); // Duplicate!
        
      } catch (e) {
        _log('❌ Caught duplicate registration: $e');
      }
      
      // Example 2: Invalid domain ID (uppercase)
      try {
        AppControl.reset();
        AppControl.initialize(config: const RuntimeConfig.development());
        
        AppControl.registerDomain(BadDomain(id: 'INVALID_UPPERCASE'));
        
      } catch (e) {
        _log('❌ Caught invalid ID: $e');
      }
      
      // Example 3: Missing dependencies
      try {
        AppControl.reset();
        AppControl.initialize(config: const RuntimeConfig.development());
        
        AppControl.registerDomain(AuthRuntimeDomain()); // Depends on storage
        // Don't register storage!
        await AppControl.start();
        
      } catch (e) {
        _log('❌ Caught missing dependency: $e');
      }
      
      // Example 4: Self-dependency
      try {
        AppControl.reset();
        AppControl.initialize(config: const RuntimeConfig.development());
        
        AppControl.registerDomain(BadDomain(
          id: 'bad',
          deps: ['bad'], // Self-dependency!
        ));
        
      } catch (e) {
        _log('❌ Caught self-dependency: $e');
      }
      
      setState(() {
        _status = 'Incorrect registration examples completed';
      });
      
    } catch (e) {
      _log('❌ Unexpected error: $e');
    }
  }

  Future<void> _demonstrateStrictMode() async {
    try {
      setState(() {
        _status = 'Demonstrating strict mode...';
      });
      
      _log('🔄 Starting strict mode example...');
      
      AppControl.reset();
      
      // Initialize with strict production config
      AppControl.initialize(
        config: const RuntimeConfig.production().copyWith(
          requiredDomains: {'storage', 'logging'}, // Require these domains
        )
      );
      _log('🔒 Initialized with strict production config');
      _log('📋 Required domains: storage, logging');
      
      // Try to start without required domains
      try {
        await AppControl.start();
      } catch (e) {
        _log('❌ Failed as expected: $e');
      }
      
      // Now register required domains
      AppControl.registerDomains([
        StorageRuntimeDomain(),
        LoggingDomain(),
      ]);
      _log('✅ Registered required domains');
      
      // Should work now
      await AppControl.start();
      _log('✅ Started successfully with required domains');
      
      setState(() {
        _status = 'Strict mode demonstration completed ✅';
      });
      
    } catch (e) {
      _log('❌ Error: $e');
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
      _status = 'Logs cleared';
    });
  }
}

// Example custom domain with proper implementation
class PaymentDomain implements RuntimeDomain {
  bool _initialized = false;
  
  @override
  String get domainId => 'payment'; // Lowercase!
  
  @override
  String get domainName => 'Payment Processing';
  
  @override
  int get initializationPriority => 80;
  
  @override
  List<String> get dependencies => ['auth', 'storage']; // Proper dependencies
  
  @override
  Future<void> initialize() async {
    // Initialize payment processors
    _initialized = true;
  }
  
  @override
  Future<void> reset(ResetLevel level) async {
    if (level.shouldResetPersistentState) {
      // Clear payment cache
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

// Example of what NOT to do - bad domain
class BadDomain implements RuntimeDomain {
  final String id;
  final List<String> deps;
  
  BadDomain({
    required this.id,
    this.deps = const [],
  });
  
  @override
  String get domainId => id; // Could be invalid
  
  @override
  String get domainName => ''; // Empty name!
  
  @override
  int get initializationPriority => -1; // Negative priority!
  
  @override
  List<String> get dependencies => deps;
  
  @override
  Future<void> initialize() async {}
  
  @override
  Future<void> reset(ResetLevel level) async {}
  
  @override
  Future<void> dispose() async {}
  
  @override
  bool get isInitialized => false;
  
  @override
  bool get canReset => false;
}

// Example logging domain
class LoggingDomain implements RuntimeDomain {
  bool _initialized = false;
  
  @override
  String get domainId => 'logging';
  
  @override
  String get domainName => 'Logging System';
  
  @override
  int get initializationPriority => 10;
  
  @override
  List<String> get dependencies => [];
  
  @override
  Future<void> initialize() async {
    _initialized = true;
  }
  
  @override
  Future<void> reset(ResetLevel level) async {}
  
  @override
  Future<void> dispose() async {
    _initialized = false;
  }
  
  @override
  bool get isInitialized => _initialized;
  
  @override
  bool get canReset => true;
}