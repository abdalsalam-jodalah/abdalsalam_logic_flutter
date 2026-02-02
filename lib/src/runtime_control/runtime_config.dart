// lib/src/runtime_control/runtime_config.dart
// Configuration for runtime control behavior

import 'reset_level.dart';

class RuntimeConfig {
  final bool enableDebugMode;
  
  final bool enableStrictValidation;
  
  final bool allowRuntimeReset;
  
  final bool trackLifecycleEvents;
  
  final ResetLevel defaultResetLevel;
  
  final Duration initializationTimeout;
  
  final Duration shutdownTimeout;
  
  final bool enforceRegistration;
  
  final bool preventUnregisteredState;
  
  final bool enableRecoveryMode;
  
  /// Set of domain IDs that must be registered (enforced if enableStrictValidation is true)
  final Set<String> requiredDomains;
  
  /// Enforce domain naming conventions (lowercase IDs, non-empty names)
  final bool enforceDomainNaming;
  
  /// Validate domain consistency (unique names, valid priorities, etc.)
  final bool validateDomainConsistency;
  
  const RuntimeConfig({
    this.enableDebugMode = false,
    this.enableStrictValidation = true,
    this.allowRuntimeReset = true,
    this.trackLifecycleEvents = true,
    this.defaultResetLevel = ResetLevel.soft,
    this.initializationTimeout = const Duration(seconds: 30),
    this.shutdownTimeout = const Duration(seconds: 10),
    this.enforceRegistration = true,
    this.preventUnregisteredState = true,
    this.enableRecoveryMode = false,
    this.requiredDomains = const {},
    this.enforceDomainNaming = true,
    this.validateDomainConsistency = true,
  });
  
  const RuntimeConfig.development()
      : enableDebugMode = true,
        enableStrictValidation = true,
        allowRuntimeReset = true,
        trackLifecycleEvents = true,
        defaultResetLevel = ResetLevel.soft,
        initializationTimeout = const Duration(seconds: 60),
        shutdownTimeout = const Duration(seconds: 15),
        enforceRegistration = true,
        preventUnregisteredState = true,
        enableRecoveryMode = true,
        requiredDomains = const {},
        enforceDomainNaming = true,
        validateDomainConsistency = true;
  
  const RuntimeConfig.production()
      : enableDebugMode = false,
        enableStrictValidation = true,
        allowRuntimeReset = false,
        trackLifecycleEvents = false,
        defaultResetLevel = ResetLevel.soft,
        initializationTimeout = const Duration(seconds: 20),
        shutdownTimeout = const Duration(seconds: 5),
        enforceRegistration = true,
        preventUnregisteredState = true,
        enableRecoveryMode = false,
        requiredDomains = const {}, // USER configures what they need
        enforceDomainNaming = true,
        validateDomainConsistency = true;
  
  const RuntimeConfig.testing()
      : enableDebugMode = true,
        enableStrictValidation = false,
        allowRuntimeReset = true,
        trackLifecycleEvents = true,
        defaultResetLevel = ResetLevel.complete,
        initializationTimeout = const Duration(seconds: 5),
        shutdownTimeout = const Duration(seconds: 2),
        enforceRegistration = false,
        preventUnregisteredState = false,
        enableRecoveryMode = true,
        requiredDomains = const {},
        enforceDomainNaming = false,
        validateDomainConsistency = false;
  
  RuntimeConfig copyWith({
    bool? enableDebugMode,
    bool? enableStrictValidation,
    bool? allowRuntimeReset,
    bool? trackLifecycleEvents,
    ResetLevel? defaultResetLevel,
    Duration? initializationTimeout,
    Duration? shutdownTimeout,
    bool? enforceRegistration,
    bool? preventUnregisteredState,
    bool? enableRecoveryMode,
    Set<String>? requiredDomains,
    bool? enforceDomainNaming,
    bool? validateDomainConsistency,
  }) {
    return RuntimeConfig(
      enableDebugMode: enableDebugMode ?? this.enableDebugMode,
      enableStrictValidation: enableStrictValidation ?? this.enableStrictValidation,
      allowRuntimeReset: allowRuntimeReset ?? this.allowRuntimeReset,
      trackLifecycleEvents: trackLifecycleEvents ?? this.trackLifecycleEvents,
      defaultResetLevel: defaultResetLevel ?? this.defaultResetLevel,
      initializationTimeout: initializationTimeout ?? this.initializationTimeout,
      shutdownTimeout: shutdownTimeout ?? this.shutdownTimeout,
      enforceRegistration: enforceRegistration ?? this.enforceRegistration,
      preventUnregisteredState: preventUnregisteredState ?? this.preventUnregisteredState,
      enableRecoveryMode: enableRecoveryMode ?? this.enableRecoveryMode,
      requiredDomains: requiredDomains ?? this.requiredDomains,
      enforceDomainNaming: enforceDomainNaming ?? this.enforceDomainNaming,
      validateDomainConsistency: validateDomainConsistency ?? this.validateDomainConsistency,
    );
  }
}
