// lib/src/error_logging/runtime_error_overlay.dart
// Error overlay widget to display runtime errors on screen

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class RuntimeErrorOverlay extends StatefulWidget {
  final Widget child;
  final bool showErrors;
  final Duration errorDisplayDuration;
  final int maxErrors;

  const RuntimeErrorOverlay({
    super.key,
    required this.child,
    this.showErrors = true,
    this.errorDisplayDuration = const Duration(seconds: 10),
    this.maxErrors = 5,
  });

  @override
  State<RuntimeErrorOverlay> createState() => _RuntimeErrorOverlayState();

  // Static method to wrap the entire app
  static Widget wrapApp(Widget app, {bool showErrors = kDebugMode}) {
    return RuntimeErrorOverlay(
      showErrors: showErrors,
      child: app,
    );
  }
}

class _RuntimeErrorOverlayState extends State<RuntimeErrorOverlay> with WidgetsBindingObserver {
  final List<ErrorInfo> _errors = [];
  OverlayEntry? _errorOverlay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    if (widget.showErrors) {
      // Catch Flutter errors
      FlutterError.onError = (FlutterErrorDetails details) {
        print('🔥 FLUTTER ERROR OVERLAY: ${details.exception}');
        debugPrint('Context: ${details.context}');
        debugPrint('Stack: ${details.stack}');
        _addError(ErrorInfo(
          error: details.exception,
          stackTrace: details.stack,
          context: details.context?.toString() ?? 'Flutter Error',
          timestamp: DateTime.now(),
        ));
      };

      // Catch Dart errors
      PlatformDispatcher.instance.onError = (error, stack) {
        print('🔥 PLATFORM ERROR OVERLAY: $error');
        debugPrint('Stack: $stack');
        _addError(ErrorInfo(
          error: error,
          stackTrace: stack,
          context: 'Platform Error',
          timestamp: DateTime.now(),
        ));
        return true;
      };
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _removeErrorOverlay();
    super.dispose();
  }

  void _addError(ErrorInfo errorInfo) {
    if (!widget.showErrors || !mounted) return;

    print('🚨 ERROR OVERLAY: ${errorInfo.context} - ${errorInfo.error}');
    debugPrint('Error timestamp: ${errorInfo.timestamp}');

    setState(() {
      _errors.insert(0, errorInfo);
      
      // Keep only max errors
      if (_errors.length > widget.maxErrors) {
        _errors.removeRange(widget.maxErrors, _errors.length);
      }
    });

    _showErrorOverlay();

    // Auto-remove error after duration
    Timer(widget.errorDisplayDuration, () {
      if (mounted) {
        setState(() {
          _errors.remove(errorInfo);
          if (_errors.isEmpty) {
            _removeErrorOverlay();
          }
        });
      }
    });
  }

  void _showErrorOverlay() {
    _removeErrorOverlay();
    
    _errorOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 10,
        right: 10,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          color: Colors.red.shade800.withOpacity(0.95),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade900,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Runtime Errors',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _removeErrorOverlay(),
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(8),
                    itemCount: _errors.length,
                    itemBuilder: (context, index) => _buildErrorItem(_errors[index]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_errorOverlay!);
  }

  Widget _buildErrorItem(ErrorInfo errorInfo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.shade700,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                errorInfo.context,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                _formatTime(errorInfo.timestamp),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            errorInfo.error.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (errorInfo.stackTrace != null)
            GestureDetector(
              onTap: () => _showFullError(errorInfo),
              child: const Text(
                'Tap to view stack trace',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showFullError(ErrorInfo errorInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error: ${errorInfo.context}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Time: ${errorInfo.timestamp}'),
              const SizedBox(height: 8),
              const Text('Error:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(errorInfo.error.toString()),
              if (errorInfo.stackTrace != null) ...[
                const SizedBox(height: 8),
                const Text('Stack Trace:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  errorInfo.stackTrace.toString(),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _removeErrorOverlay() {
    _errorOverlay?.remove();
    _errorOverlay = null;
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
           '${time.minute.toString().padLeft(2, '0')}:'
           '${time.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class ErrorInfo {
  final Object error;
  final StackTrace? stackTrace;
  final String context;
  final DateTime timestamp;

  ErrorInfo({
    required this.error,
    this.stackTrace,
    required this.context,
    required this.timestamp,
  });
}