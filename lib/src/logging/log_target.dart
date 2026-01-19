// lib/src/logging/log_target.dart
// Defines available log output targets

enum LogTarget {
  console,
  file,
  memory,
  remote;

  String get displayName {
    switch (this) {
      case LogTarget.console:
        return 'Console';
      case LogTarget.file:
        return 'File';
      case LogTarget.memory:
        return 'Memory';
      case LogTarget.remote:
        return 'Remote';
    }
  }
}
