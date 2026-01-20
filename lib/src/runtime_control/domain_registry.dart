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
}
