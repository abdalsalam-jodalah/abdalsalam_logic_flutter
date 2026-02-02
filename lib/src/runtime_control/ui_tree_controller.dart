// lib/src/runtime_control/ui_tree_controller.dart
// Controller for managing UI widget tree lifecycles

import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

typedef UIRebuildCallback = void Function();

class UITreeController {
  final Map<String, GlobalKey> _treeKeys = {};
  final List<UIRebuildCallback> _rebuildCallbacks = [];
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [];
  final StreamController<UITreeEvent> _eventStream = StreamController.broadcast();
  
  GlobalKey<State<StatefulWidget>>? _rootKey;
  
  static UITreeController? _instance;
  static UITreeController get instance => _instance ??= UITreeController._internal();
  UITreeController._internal();
  
  void setRootKey(GlobalKey<State<StatefulWidget>> key) {
    _rootKey = key;
  }
  
  void registerNavigatorKey(GlobalKey<NavigatorState> key) {
    if (!_navigatorKeys.contains(key)) {
      _navigatorKeys.add(key);
    }
  }
  
  void unregisterNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKeys.remove(key);
  }
  
  void registerTree(String treeId, GlobalKey key) {
    _treeKeys[treeId] = key;
  }
  
  void unregisterTree(String treeId) {
    _treeKeys.remove(treeId);
  }
  
  void registerRebuildCallback(UIRebuildCallback callback) {
    _rebuildCallbacks.add(callback);
  }
  
  void unregisterRebuildCallback(UIRebuildCallback callback) {
    _rebuildCallbacks.remove(callback);
  }
  
  Future<void> refreshUI() async {
    _emitEvent(UITreeEvent.refresh());
    
    try {
      // Force UI refresh using Flutter's built-in mechanisms
      await _performUIRefresh();
      
      // Trigger registered callbacks
      for (final callback in List.from(_rebuildCallbacks)) {
        try {
          callback();
        } catch (e) {
          debugPrint('Error in UI rebuild callback: $e');
        }
      }
      
      // Ensure all pending frames are processed
      await _waitForFrameCompletion();
      
    } catch (e) {
      debugPrint('Error refreshing UI: $e');
      rethrow;
    }
  }
  
  Future<void> rebuildAllTrees() async {
    _emitEvent(UITreeEvent.rebuildAll());
    
    try {
      // Clear navigation stacks
      await _clearNavigationStacks();
      
      // Force complete UI tree rebuild
      await _performCompleteRebuild();
      
      // Trigger callbacks
      for (final callback in List.from(_rebuildCallbacks)) {
        try {
          callback();
        } catch (e) {
          debugPrint('Error in tree rebuild callback: $e');
        }
      }
      
      await _waitForFrameCompletion();
      
    } catch (e) {
      debugPrint('Error rebuilding all trees: $e');
      rethrow;
    }
  }
  
  Future<void> rebuildTree(String treeId) async {
    _emitEvent(UITreeEvent.rebuildTree(treeId));
    
    try {
      final key = _treeKeys[treeId];
      if (key != null && key.currentContext != null) {
        // Force specific tree rebuild by marking dirty
        (key.currentContext as Element?)?.markNeedsBuild();
      }
      
      await _waitForFrameCompletion();
      
    } catch (e) {
      debugPrint('Error rebuilding tree $treeId: $e');
      rethrow;
    }
  }
  
  Future<void> recreateAllTrees() async {
    _emitEvent(UITreeEvent.recreateAll());
    
    try {
      // Clear all caches and render objects
      await _clearRenderObjectCache();
      
      // Clear image cache
      if (!kIsWeb) {
        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();
      }
      
      // Clear navigation stacks completely
      await _clearNavigationStacks();
      
      // Recreate all GlobalKeys
      final oldKeys = Map<String, GlobalKey>.from(_treeKeys);
      _treeKeys.clear();
      
      for (final entry in oldKeys.entries) {
        _treeKeys[entry.key] = GlobalKey();
      }
      
      // Recreate root key
      if (_rootKey != null) {
        _rootKey = GlobalKey<State<StatefulWidget>>();
      }
      
      // Recreate navigator keys
      final oldNavigatorKeys = List<GlobalKey<NavigatorState>>.from(_navigatorKeys);
      _navigatorKeys.clear();
      for (final _ in oldNavigatorKeys) {
        _navigatorKeys.add(GlobalKey<NavigatorState>());
      }
      
      // Force complete application reassemble
      if (WidgetsBinding.instance.debugDidSendFirstFrameEvent) {
        await _reassembleApplication();
      }
      
      // Trigger callbacks with new keys
      for (final callback in List.from(_rebuildCallbacks)) {
        try {
          callback();
        } catch (e) {
          debugPrint('Error in recreate callback: $e');
        }
      }
      
      await _waitForFrameCompletion();
      
    } catch (e) {
      debugPrint('Error recreating all trees: $e');
      rethrow;
    }
  }
  
  Future<void> clearCachedRenderState() async {
    _emitEvent(UITreeEvent.clearCache());
    
    try {
      await _clearRenderObjectCache();
      
      // Clear image cache
      if (!kIsWeb) {
        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();
      }
      
      // Clear text input cache
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        TextInput.finishAutofillContext();
      }
      
      await _waitForFrameCompletion();
      
    } catch (e) {
      debugPrint('Error clearing cached render state: $e');
      rethrow;
    }
  }
  
  // REAL implementation methods
  
  Future<void> _performUIRefresh() async {
    // Schedule frame and force rebuild
    WidgetsBinding.instance.ensureVisualUpdate();
    
    // Force immediate frame if needed
    if (!WidgetsBinding.instance.hasScheduledFrame) {
      WidgetsBinding.instance.scheduleFrame();
    }
    
    // Wait for next frame
    await WidgetsBinding.instance.endOfFrame;
  }
  
  Future<void> _performCompleteRebuild() async {
    try {
      // Use reassembleApplication instead of scheduleBuildFor
      await WidgetsBinding.instance.reassembleApplication();
      
      // Ensure visual update
      WidgetsBinding.instance.ensureVisualUpdate();
      
      // Schedule a frame if needed
      if (!WidgetsBinding.instance.hasScheduledFrame) {
        WidgetsBinding.instance.scheduleFrame();
      }
      
      await WidgetsBinding.instance.endOfFrame;
    } catch (e) {
      debugPrint('Error in complete rebuild: $e');
      // Fallback to simple refresh
      WidgetsBinding.instance.ensureVisualUpdate();
      WidgetsBinding.instance.scheduleFrame();
    }
  }
  
  Future<void> _clearNavigationStacks() async {
    for (final navigatorKey in _navigatorKeys) {
      final navigator = navigatorKey.currentState;
      if (navigator != null && navigator.canPop()) {
        // Pop to root without animation to avoid conflicts
        navigator.popUntil((route) => route.isFirst);
      }
    }
    
    await Future.delayed(const Duration(milliseconds: 100));
  }
  
  Future<void> _clearRenderObjectCache() async {
    // Clear render object cache
    // Note: RenderObject.clearSemantics() is not available as static method
    
    // Force garbage collection of render objects
    if (RendererBinding.instance.renderViews.isNotEmpty &&
        RendererBinding.instance.renderViews.first.child != null) {
      RendererBinding.instance.renderViews.first.child!.visitChildren((child) {
        child.markNeedsLayout();
        child.markNeedsPaint();
      });
    }
  }
  
  Future<void> _reassembleApplication() async {
    // Hot reload-like reassembly
    try {
      WidgetsBinding.instance.reassembleApplication();
    } catch (e) {
      debugPrint('Error during app reassembly: $e');
    }
  }
  
  Future<void> _waitForFrameCompletion() async {
    // Ensure all pending frames are completed
    if (WidgetsBinding.instance.hasScheduledFrame) {
      await WidgetsBinding.instance.endOfFrame;
    }
    
    // Additional frame to ensure completion
    WidgetsBinding.instance.scheduleFrame();
    await WidgetsBinding.instance.endOfFrame;
  }
  
  void _emitEvent(UITreeEvent event) {
    _eventStream.add(event);
  }
  
  Stream<UITreeEvent> get eventStream => _eventStream.stream;
  
  GlobalKey<State<StatefulWidget>>? get rootKey => _rootKey;
  
  int get registeredTreeCount => _treeKeys.length;
  
  bool hasTree(String treeId) => _treeKeys.containsKey(treeId);
  
  void dispose() {
    _treeKeys.clear();
    _rebuildCallbacks.clear();
    _eventStream.close();
  }
}

class UITreeEvent {
  final UITreeEventType type;
  final String? treeId;
  final DateTime timestamp;
  
  UITreeEvent._({
    required this.type,
    this.treeId,
  }) : timestamp = DateTime.now();
  
  factory UITreeEvent.refresh() => UITreeEvent._(type: UITreeEventType.refresh);
  
  factory UITreeEvent.rebuildAll() => UITreeEvent._(type: UITreeEventType.rebuildAll);
  
  factory UITreeEvent.rebuildTree(String treeId) => UITreeEvent._(
        type: UITreeEventType.rebuildTree,
        treeId: treeId,
      );
  
  factory UITreeEvent.recreateAll() => UITreeEvent._(type: UITreeEventType.recreateAll);
  
  factory UITreeEvent.clearCache() => UITreeEvent._(type: UITreeEventType.clearCache);
}

enum UITreeEventType {
  refresh,
  rebuildAll,
  rebuildTree,
  recreateAll,
  clearCache,
}
