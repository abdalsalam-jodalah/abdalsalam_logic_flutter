// lib/examples/test_counter_widget.dart
// Simple counter that shows visible state changes

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestCounterWidget extends StatefulWidget {
  const TestCounterWidget({super.key});

  @override
  State<TestCounterWidget> createState() => _TestCounterWidgetState();
}

class _TestCounterWidgetState extends State<TestCounterWidget> {
  int _persistentCounter = 0;
  int _transientCounter = 0;
  
  @override
  void initState() {
    super.initState();
    _loadCounters();
  }
  
  Future<void> _loadCounters() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _persistentCounter = prefs.getInt('test_persistent_counter') ?? 0;
    });
  }
  
  Future<void> _savePersistentCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('test_persistent_counter', _persistentCounter);
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.yellow.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              '🧪 TEST COUNTERS',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Persistent counter (survives soft resets)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💾 Persistent Counter', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('(Saved to SharedPreferences)', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() => _persistentCounter++);
                        _savePersistentCounter();
                      },
                      icon: const Icon(Icons.add),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$_persistentCounter',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Transient counter (resets with any restart)  
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('⚡ Transient Counter', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('(Memory only - resets on any action)', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => setState(() => _transientCounter++),
                      icon: const Icon(Icons.add),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$_transientCounter',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📋 Test Instructions:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('• Increment both counters'),
                  Text('• Try SOFT reset → Persistent should stay'),
                  Text('• Try HARD reset → Both should reset to 0'),
                  Text('• Watch the visual widget above change colors/animations'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Global key for external access
final GlobalKey<_TestCounterWidgetState> testCounterKey = GlobalKey<_TestCounterWidgetState>();