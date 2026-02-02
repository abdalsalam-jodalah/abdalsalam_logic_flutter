// lib/examples/app_restart_example.dart
// Simple example showing how to use the AppRestart API

import 'package:flutter/material.dart';
import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';

class AppRestartExample extends StatelessWidget {
  const AppRestartExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Restart Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'App Restart Functionality',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            
            ElevatedButton.icon(
              onPressed: () async {
                // Show loading
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🔄 Restarting app...'),
                    backgroundColor: Colors.blue,
                  ),
                );
                
                // Restart using platform-specific method
                final success = await AppRestart.restartApp();
                
                if (!success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('❌ Restart failed - platform not supported'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.restart_alt),
              label: const Text('Restart App'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            
            const SizedBox(height: 20),
            
            ElevatedButton.icon(
              onPressed: () async {
                // Show warning dialog
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('⚠️ Warning'),
                    content: const Text(
                      'This will forcibly terminate the app. Any unsaved data will be lost. Continue?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Force Restart'),
                      ),
                    ],
                  ),
                );
                
                if (confirm == true) {
                  // Show loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('💀 Force restarting...'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  
                  // Force restart
                  final success = await AppRestart.forceKillAndRestart();
                  
                  if (!success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('❌ Force restart failed - platform not supported'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.power_settings_new),
              label: const Text('Force Kill & Restart'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            
            const SizedBox(height: 40),
            
            const Card(
              margin: EdgeInsets.all(20),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How it works:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    Text('• Android: Uses Intent.makeRestartActivityTask() for clean restart'),
                    SizedBox(height: 4),
                    Text('• iOS: Shows prompt to manually restart (iOS limitation)'),
                    SizedBox(height: 4),
                    Text('• Force restart: Aggressively terminates and restarts the app'),
                    SizedBox(height: 12),
                    Text(
                      'Note: The restart functionality is provided by the abdalsalam_logic_flutter package and works in any app that uses it.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}