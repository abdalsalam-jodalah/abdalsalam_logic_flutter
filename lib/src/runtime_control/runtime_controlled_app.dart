// lib/src/runtime_control/runtime_controlled_app.dart
// Widget wrapper that integrates with App Control Runtime

import 'package:flutter/material.dart';

import 'app_control.dart';
import 'lifecycle_phase.dart';
import 'runtime_config.dart';
import 'runtime_domain.dart';

class RuntimeControlledApp extends StatefulWidget {
  final Widget child;
  final List<RuntimeDomain> domains;
  final RuntimeConfig? config;
  final VoidCallback? onStarted;
  final VoidCallback? onError;
  
  const RuntimeControlledApp({
    super.key,
    required this.child,
    required this.domains,
    this.config,
    this.onStarted,
    this.onError,
  });
  
  @override
  State<RuntimeControlledApp> createState() => _RuntimeControlledAppState();
}

class _RuntimeControlledAppState extends State<RuntimeControlledApp> {
  bool _isInitialized = false;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _initializeRuntime();
  }
  
  Future<void> _initializeRuntime() async {
    try {
      AppControl.initialize(config: widget.config);
      AppControl.registerDomains(widget.domains);
      
      final rootKey = GlobalKey<State<StatefulWidget>>();
      AppControl.uiController.setRootKey(rootKey);
      
      await AppControl.start();
      
      setState(() {
        _isInitialized = true;
      });
      
      widget.onStarted?.call();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      widget.onError?.call();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return ErrorWidget(_error!);
    }
    
    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return widget.child;
  }
  
  @override
  void dispose() {
    AppControl.stop();
    super.dispose();
  }
}

class RuntimePhaseBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, LifecyclePhase phase) builder;
  
  const RuntimePhaseBuilder({
    super.key,
    required this.builder,
  });
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LifecyclePhase>(
      stream: AppControl.phaseStream,
      initialData: AppControl.currentPhase,
      builder: (context, snapshot) {
        return builder(context, snapshot.data ?? LifecyclePhase.uninitialized);
      },
    );
  }
}

class RuntimeControlButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  
  const RuntimeControlButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });
  
  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon ?? Icons.refresh),
      label: Text(label),
    );
  }
}
