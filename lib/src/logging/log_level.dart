// lib/src/logging/log_level.dart
// Defines log severity levels and module types for the logging system

enum LogLevel {
  trace(0),
  debug(1),
  info(2),
  warning(3),
  error(4),
  fatal(5);

  const LogLevel(this.value);

  final int value;

  bool operator >=(LogLevel other) => value >= other.value;
  bool operator >(LogLevel other) => value > other.value;
  bool operator <=(LogLevel other) => value <= other.value;
  bool operator <(LogLevel other) => value < other.value;

  String get displayName {
    switch (this) {
      case LogLevel.trace:
        return 'TRACE';
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARN';
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.fatal:
        return 'FATAL';
    }
  }

  String get ansiColor {
    switch (this) {
      case LogLevel.trace:
        return '\x1B[90m';
      case LogLevel.debug:
        return '\x1B[36m';
      case LogLevel.info:
        return '\x1B[32m';
      case LogLevel.warning:
        return '\x1B[33m';
      case LogLevel.error:
        return '\x1B[31m';
      case LogLevel.fatal:
        return '\x1B[35m';
    }
  }
}

enum ModuleType {
  service,
  repository,
  view,
  viewModel,
  state,
  network,
  storage,
  websocket,
  api,
  database,
  cache,
  authentication,
  authorization,
  background,
  scheduler,
  analytics,
  crashReporting,
  payment,
  media,
  location,
  push,
  deepLink,
  biometric,
  encryption,
  sync,
  prefetch,
  fileSystem,
  other;

  String get displayName {
    switch (this) {
      case ModuleType.service:
        return 'SVC';
      case ModuleType.repository:
        return 'REPO';
      case ModuleType.view:
        return 'VIEW';
      case ModuleType.viewModel:
        return 'VM';
      case ModuleType.state:
        return 'STATE';
      case ModuleType.network:
        return 'NET';
      case ModuleType.storage:
        return 'STRG';
      case ModuleType.websocket:
        return 'WS';
      case ModuleType.api:
        return 'API';
      case ModuleType.database:
        return 'DB';
      case ModuleType.cache:
        return 'CACHE';
      case ModuleType.authentication:
        return 'AUTH';
      case ModuleType.authorization:
        return 'AUTHZ';
      case ModuleType.background:
        return 'BG';
      case ModuleType.scheduler:
        return 'SCHED';
      case ModuleType.analytics:
        return 'ANLYT';
      case ModuleType.crashReporting:
        return 'CRASH';
      case ModuleType.payment:
        return 'PAY';
      case ModuleType.media:
        return 'MEDIA';
      case ModuleType.location:
        return 'LOC';
      case ModuleType.push:
        return 'PUSH';
      case ModuleType.deepLink:
        return 'LINK';
      case ModuleType.biometric:
        return 'BIO';
      case ModuleType.encryption:
        return 'ENCR';
      case ModuleType.sync:
        return 'SYNC';
      case ModuleType.prefetch:
        return 'FETCH';
      case ModuleType.fileSystem:
        return 'FS';
      case ModuleType.other:
        return 'OTHER';
    }
  }
}
