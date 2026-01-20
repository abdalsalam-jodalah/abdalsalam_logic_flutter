// lib/src/runtime_control/ui_tree_controller.dart
// Controller for managing UI widget tree lifecycles

import 'dart:async';
import 'package:flutter/widgets.dart';

typedef UIRebuildCallback = void Function();

class UITreeController {
  final Map<String, GlobalKey> _treeKeys = {};
  final List<UIRebuildCallback> _rebuildCallbacks = [];
  final StreamController<UITreeEvent> _eventStream = StreamController.broadcast();
  
  GlobalKey<State<StatefulWidget>>? _rootKey;
  
  void setRootKey(GlobalKey<State<StatefulWidget>> key) {
    _rootKey = key;
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
    
    for (final callback in _rebuildCallbacks) {
      callback();
    }
    
    await Future.delayed(const Duration(milliseconds: 16));
  }
  
  Future<void> rebuildAllTrees() async {
    _emitEvent(UITreeEvent.rebuildAll());
    
    for (final callback in _rebuildCallbacks) {
      callback();
    }
    
    await Future.delayed(const Duration(milliseconds: 32));
  }
  
  Future<void> rebuildTree(String treeId) async {
    _emitEvent(UITreeEvent.rebuildTree(treeId));
    
    for (final callback in _rebuildCallbacks) {
      callback();
    }
    
    await Future.delayed(const Duration(milliseconds: 16));
  }
  
  Future<void> recreateAllTrees() async {
    _emitEvent(UITreeEvent.recreateAll());
    
    final oldKeys = Map<String, GlobalKey>.from(_treeKeys);
    _treeKeys.clear();
    
    for (final entry in oldKeys.entries) {
      _treeKeys[entry.key] = GlobalKey();
    }
    
    if (_rootKey != null) {
      _rootKey = GlobalKey<State<StatefulWidget>>();
    }
    
    for (final callback in _rebuildCallbacks) {
      callback();
    }
    
    await Future.delayed(const Duration(milliseconds: 50));
  }
  
  Future<void> clearCachedRenderState() async {
    _emitEvent(UITreeEvent.clearCache());
    
    await Future.delayed(const Duration(milliseconds: 16));
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
