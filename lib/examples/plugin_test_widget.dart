// lib/examples/plugin_test_widget.dart
// Simple widget to test if the restart plugin is working

import 'package:flutter/material.dart';
import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';

class PluginTestWidget extends StatefulWidget {
  const PluginTestWidget({super.key});

  @override
  State<PluginTestWidget> createState() => _PluginTestWidgetState();
}

class _PluginTestWidgetState extends State<PluginTestWidget> {
  String _status = 'Not tested';
  bool _isSupported = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Plugin Status: $_status',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: _testPlugin,
              child: const Text('Test Plugin'),
            ),
            
            const SizedBox(height: 20),
            
            if (_isSupported) ...[
              ElevatedButton(
                onPressed: _testRestart,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Test Restart'),
              ),
              
              const SizedBox(height: 10),
              
              ElevatedButton(
                onPressed: _testForceRestart,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Test Force Restart'),
              ),
            ],
            
            const SizedBox(height: 40),
            
            const Card(
              margin: EdgeInsets.all(20),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Debug Info:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('• This tests if the native plugin is working'),
                    Text('• Check console logs for detailed error messages'),
                    Text('• MissingPluginException = plugin not registered'),
                    Text('• TimeoutException = plugin registered but not responding'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _testPlugin() async {
    setState(() {
      _status = 'Testing...';
    });
    
    try {
      final supported = await AppRestart.isRestartSupported();
      setState(() {
        _isSupported = supported;
        _status = supported ? 'Plugin Working ✅' : 'Plugin Not Available ❌';
      });
      
      print('🧪 Plugin test result: $supported');
      
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isSupported = false;
      });
      print('🚨 Plugin test failed: $e');
    }
  }
  
  Future<void> _testRestart() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🚀 Testing restart - app should reload!'),
        backgroundColor: Colors.blue,
      ),
    );
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    final success = await AppRestart.restartApp();
    print('🧪 Restart test result: $success');
  }
  
  Future<void> _testForceRestart() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Force Restart Test'),
        content: const Text('This will forcibly kill the app. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Force Test'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('💀 Testing force restart - app should kill and reload!'),
          backgroundColor: Colors.red,
        ),
      );
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      final success = await AppRestart.forceKillAndRestart();
      print('🧪 Force restart test result: $success');
    }
  }
}