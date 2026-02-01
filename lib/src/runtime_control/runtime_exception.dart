// lib/src/runtime_control/runtime_exception.dart
// Runtime control specific exceptions

class RuntimeException implements Exception {
  final String message;
  final String? code;
  final dynamic details;
  
  RuntimeException(this.message, {this.code, this.details});
  
  @override
  String toString() => 'RuntimeException: $message${code != null ? ' ($code)' : ''}';
}

class IllegalLifecycleTransitionException extends RuntimeException {
  IllegalLifecycleTransitionException(String from, String to)
      : super(
          'Illegal lifecycle transition from $from to $to',
          code: 'ILLEGAL_TRANSITION',
        );
}

class DomainRegistrationException extends RuntimeException {
  DomainRegistrationException(super.message)
      : super(code: 'DOMAIN_REGISTRATION_ERROR');
}

class DomainDependencyException extends RuntimeException {
  DomainDependencyException(String domainId, List<String> missingDependencies)
      : super(
          'Domain $domainId has unmet dependencies: ${missingDependencies.join(", ")}',
          code: 'UNMET_DEPENDENCIES',
          details: missingDependencies,
        );
}

class RuntimeInitializationException extends RuntimeException {
  RuntimeInitializationException(super.message, {super.details})
      : super(code: 'INITIALIZATION_ERROR');
}

class UnregisteredDomainException extends RuntimeException {
  UnregisteredDomainException(super.message)
      : super(code: 'UNREGISTERED_DOMAIN');
}
