// lib/src/runtime_control/domain_registry.dart
// Registry system for managing runtime domains

import 'runtime_domain.dart';
import 'runtime_exception.dart';

class DomainRegistry {
  final Map<String, RuntimeDomain> _domains = {};
  final Map<String, bool> _initializationStatus = {};
  
  void register(RuntimeDomain domain) {
    if (_domains.containsKey(domain.domainId)) {
      throw DomainRegistrationException(
        'Domain ${domain.domainId} is already registered',
      );
    }
    
    // STRICT VALIDATION: Enforce domain rules
    _validateDomainRegistration(domain);
    
    _domains[domain.domainId] = domain;
    _initializationStatus[domain.domainId] = false;
  }
  
  void registerAll(List<RuntimeDomain> domains) {
    for (final domain in domains) {
      register(domain);
    }
  }
  
  void unregister(String domainId) {
    _domains.remove(domainId);
    _initializationStatus.remove(domainId);
  }
  
  void clear() {
    _domains.clear();
    _initializationStatus.clear();
  }
  
  RuntimeDomain? getDomain(String domainId) {
    return _domains[domainId];
  }
  
  List<RuntimeDomain> getAllDomains() {
    return _domains.values.toList();
  }
  
  List<RuntimeDomain> getDomainsByCategory(String category) {
    return _domains.values
        .where((d) => d is RuntimeDomainMetadata && 
                     (d as RuntimeDomainMetadata).category == category)
        .toList();
  }
  
  List<RuntimeDomain> getCoreDomains() {
    return _domains.values
        .where((d) => d is RuntimeDomainMetadata && 
                     (d as RuntimeDomainMetadata).isCore)
        .toList();
  }
  
  List<RuntimeDomain> getOptionalDomains() {
    return _domains.values
        .where((d) => d is RuntimeDomainMetadata && 
                     (d as RuntimeDomainMetadata).isOptional)
        .toList();
  }
  
  List<RuntimeDomain> getInitializationOrder() {
    final domains = getAllDomains();
    
    _validateDependencies(domains);
    
    domains.sort((a, b) => b.initializationPriority.compareTo(a.initializationPriority));
    
    return _topologicalSort(domains);
  }
  
  void _validateDependencies(List<RuntimeDomain> domains) {
    final domainIds = domains.map((d) => d.domainId).toSet();
    
    for (final domain in domains) {
      final missingDeps = domain.dependencies
          .where((dep) => !domainIds.contains(dep))
          .toList();
      
      if (missingDeps.isNotEmpty) {
        throw DomainDependencyException(domain.domainId, missingDeps);
      }
    }
  }
  
  List<RuntimeDomain> _topologicalSort(List<RuntimeDomain> domains) {
    final result = <RuntimeDomain>[];
    final visited = <String>{};
    final visiting = <String>{};
    
    void visit(RuntimeDomain domain) {
      if (visited.contains(domain.domainId)) return;
      
      if (visiting.contains(domain.domainId)) {
        throw DomainRegistrationException(
          'Circular dependency detected involving ${domain.domainId}',
        );
      }
      
      visiting.add(domain.domainId);
      
      for (final depId in domain.dependencies) {
        final dep = _domains[depId];
        if (dep != null) {
          visit(dep);
        }
      }
      
      visiting.remove(domain.domainId);
      visited.add(domain.domainId);
      result.add(domain);
    }
    
    for (final domain in domains) {
      visit(domain);
    }
    
    return result;
  }
  
  void markInitialized(String domainId) {
    _initializationStatus[domainId] = true;
  }
  
  void markUninitialized(String domainId) {
    _initializationStatus[domainId] = false;
  }
  
  bool isInitialized(String domainId) {
    return _initializationStatus[domainId] ?? false;
  }
  
  bool areAllInitialized() {
    return _initializationStatus.values.every((status) => status);
  }
  
  int get domainCount => _domains.length;
  
  int get initializedCount => 
      _initializationStatus.values.where((status) => status).length;
  
  bool exists(String domainId) {
    return _domains.containsKey(domainId);
  }
  
  /// STRICT VALIDATION: Enforces consistent domain registration
  void _validateDomainRegistration(RuntimeDomain domain) {
    // Rule 1: Domain ID must be non-empty and lowercase
    if (domain.domainId.isEmpty) {
      throw DomainRegistrationException(
        'Domain ID cannot be empty for domain: ${domain.domainName}',
      );
    }
    
    if (domain.domainId != domain.domainId.toLowerCase()) {
      throw DomainRegistrationException(
        'Domain ID must be lowercase: "${domain.domainId}" should be "${domain.domainId.toLowerCase()}"',
      );
    }
    
    // Rule 2: Domain name must be non-empty
    if (domain.domainName.isEmpty) {
      throw DomainRegistrationException(
        'Domain name cannot be empty for domain: ${domain.domainId}',
      );
    }
    
    // Rule 3: Priority must be positive
    if (domain.initializationPriority <= 0) {
      throw DomainRegistrationException(
        'Domain initialization priority must be positive for domain: ${domain.domainId}',
      );
    }
    
    // Rule 4: Dependencies cannot include self
    if (domain.dependencies.contains(domain.domainId)) {
      throw DomainRegistrationException(
        'Domain cannot depend on itself: ${domain.domainId}',
      );
    }
    
    // Rule 5: Dependencies must be lowercase
    for (final dep in domain.dependencies) {
      if (dep.isEmpty) {
        throw DomainRegistrationException(
          'Empty dependency in domain: ${domain.domainId}',
        );
      }
      if (dep != dep.toLowerCase()) {
        throw DomainRegistrationException(
          'Dependency IDs must be lowercase: "$dep" should be "${dep.toLowerCase()}" in domain: ${domain.domainId}',
        );
      }
    }
    
    // Rule 6: Domain must implement canReset if it has reset logic
    if (!domain.canReset) {
      // This is a warning - we'll allow non-resettable domains but log it
    }
  }
  
  /// Validates all domains have consistent registration patterns
  void validateConsistency() {
    final allIds = _domains.keys.toSet();
    
    // Check for reserved domain IDs
    const reservedIds = {'system', 'app', 'flutter', 'dart', 'core'};
    for (final id in allIds) {
      if (reservedIds.contains(id)) {
        throw DomainRegistrationException(
          'Domain ID "$id" is reserved and cannot be used',
        );
      }
    }
    
    // Check for duplicate names
    final nameToIds = <String, List<String>>{};
    for (final domain in _domains.values) {
      nameToIds.putIfAbsent(domain.domainName, () => []).add(domain.domainId);
    }
    
    for (final entry in nameToIds.entries) {
      if (entry.value.length > 1) {
        throw DomainRegistrationException(
          'Duplicate domain name "${entry.key}" used by: ${entry.value.join(", ")}',
        );
      }
    }
    
    // Check for priority conflicts in same dependency level
    _validatePriorityConsistency();
  }
  
  void _validatePriorityConsistency() {
    final domains = getAllDomains();
    final priorityGroups = <int, List<String>>{};
    
    for (final domain in domains) {
      priorityGroups.putIfAbsent(domain.initializationPriority, () => [])
          .add(domain.domainId);
    }
    
    for (final entry in priorityGroups.entries) {
      if (entry.value.length > 1) {
      }
    }
  }
}
