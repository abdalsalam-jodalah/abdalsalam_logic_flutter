// lib/examples/logging_simple_working_example.dart

import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';

void main() {
  final config = LogConfig(
    coreConfig: LoggerCoreConfig(
      environment: LogEnvironment.development,
      environmentLevels: const {
        LogEnvironment.development: LogLevel.debug,
        LogEnvironment.profile: LogLevel.info,
        LogEnvironment.release: LogLevel.warning,
      },
      targetsPerEnvironment: const {
        LogEnvironment.development: {LogTarget.console},
        LogEnvironment.profile: {LogTarget.console},
        LogEnvironment.release: {LogTarget.console, LogTarget.file},
      },
      allowUnregisteredModules: true,
      strictMode: false,
    ),
    moduleConfig: const LoggerModuleRegistryConfig(
      globalLevel: LogLevel.debug,
      enableColors: true,
      modules: {},
    ),
  );
  
  LoggerImpl.initialize(config);
  
  final logger = LoggerImpl.forModule(const LogModule(name: 'App'));
  
  logger.debug(() => 'Debug message');
  logger.info(() => 'Info message');
  logger.warning(() => 'Warning message');
  logger.error(() => 'Error message');
  
  try {
    throw Exception('Test error');
  } catch (e, stackTrace) {
    logger.fatal(() => 'Fatal error occurred', e, stackTrace);
  }
}
