// lib/src/runtime_control/runtime_domain.dart
// Interface for all controllable runtime domains

import 'reset_level.dart';

abstract class RuntimeDomain {
  String get domainId;
  
  String get domainName;
  
  int get initializationPriority;
  
  List<String> get dependencies;
  
  Future<void> initialize();
  
  Future<void> reset(ResetLevel level);
  
  Future<void> dispose();
  
  bool get isInitialized;
  
  bool get canReset;
}

abstract class RuntimeDomainMetadata {
  String get category;
  
  bool get isCore;
  
  bool get isPersistent;
  
  bool get isOptional;
}
