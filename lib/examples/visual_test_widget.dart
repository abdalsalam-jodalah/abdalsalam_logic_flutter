// lib/examples/visual_test_widget.dart
// Widget that shows VISIBLE changes when runtime actions work

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VisualTestWidget extends StatefulWidget {
  const VisualTestWidget({super.key});

  @override
  State<VisualTestWidget> createState() => _VisualTestWidgetState();
}

class _VisualTestWidgetState extends State<VisualTestWidget>
    with TickerProviderStateMixin {
  
  // Visual state that changes
  int _counter = 0;
  Color _backgroundColor = Colors.blue.shade100;
  double _rotation = 0.0;
  String _lastAction = 'None';
  DateTime _lastUpdate = DateTime.now();
  
  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Setup animations
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.elasticInOut,
    ));
    
    // Start animations
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
    
    // Simulate some state that resets
    _startColorCycling();
  }
  
  void _startColorCycling() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _counter++;
          _backgroundColor = _generateRandomColor();
          _rotation += 45;
          _lastUpdate = DateTime.now();
        });
        _startColorCycling();
      }
    });
  }
  
  Color _generateRandomColor() {
    final random = Random();
    return Color.fromARGB(
      100,
      random.nextInt(255),
      random.nextInt(255),
      random.nextInt(255),
    );
  }
  
  // This method will be called when runtime actions happen
  void triggerVisualReset(String actionName) {
    setState(() {
      _lastAction = actionName;
      _lastUpdate = DateTime.now();
      
      // Different visual effects for different actions
      switch (actionName.toLowerCase()) {
        case 'ui refresh':
        case 'refresh ui':
        case 'uionly':
          // UI refresh - change colors dramatically
          _backgroundColor = Colors.green.shade200;
          _pulseController.forward().then((_) => _pulseController.reverse());
          break;
          
        case 'hard reset':
        case 'complete reset':
        case 'hard':
        case 'complete':
          // Hard reset - reset everything to defaults AND show restart message
          _counter = 0;
          _backgroundColor = Colors.red.shade200;
          _rotation = 0.0;
          _rotationController.reset();
          _rotationController.forward();
          // Clear test counter SharedPreferences too
          _clearTestCounters();
          // Show restart message
          _showRestartMessage();
          break;
          
        case 'soft reset':
        case 'medium reset':
        case 'soft':
        case 'medium':
          // Soft reset - partial changes
          _counter = (_counter / 2).floor();
          _backgroundColor = Colors.orange.shade200;
          break;
          
        case 'restart':
        case 'start':
          // Restart - flash and restart animations AND show restart message
          _backgroundColor = Colors.purple.shade200;
          _pulseController.reset();
          _rotationController.reset();
          _pulseController.forward();
          _rotationController.forward();
          _showRestartMessage();
          break;
          
        default:
          // Other actions - subtle change
          _backgroundColor = Colors.cyan.shade200;
          _counter++;
      }
    });
  }
  
  Future<void> _clearTestCounters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('test_persistent_counter');
      print('🧪 Cleared test counter from SharedPreferences');
    } catch (e) {
      print('Error clearing test counters: $e');
    }
  }
  
  void _showRestartMessage() {
    // Show a temporary overlay message
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.95),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.restart_alt, color: Colors.white, size: 40),
                SizedBox(height: 12),
                Text(
                  '🔥 HOT RESTART IN PROGRESS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'App is reloading completely like Flutter hot restart!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    overlay.insert(overlayEntry);
    
    // Remove overlay after longer time to ensure user sees it
    Timer(const Duration(seconds: 4), () {
      try {
        overlayEntry.remove();
      } catch (e) {
        // Ignore if already removed
      }
    });
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title
          const Text(
            'VISUAL TEST WIDGET',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Animated counter
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black54, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '$_counter',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Rotating icon
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationController.value * 2 * 3.14159 + (_rotation * 3.14159 / 180),
                child: const Icon(
                  Icons.refresh,
                  size: 40,
                  color: Colors.black54,
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Last action info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'Last Action: $_lastAction',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Updated: ${_lastUpdate.hour}:${_lastUpdate.minute.toString().padLeft(2, '0')}:${_lastUpdate.second.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Manual test button
          ElevatedButton(
            onPressed: () {
              setState(() {
                _counter += 10;
                _backgroundColor = _generateRandomColor();
              });
            },
            child: const Text('Manual Change'),
          ),
        ],
      ),
    );
  }
}

// Global instance to trigger from runtime actions
final GlobalKey<_VisualTestWidgetState> visualTestKey = GlobalKey<_VisualTestWidgetState>();