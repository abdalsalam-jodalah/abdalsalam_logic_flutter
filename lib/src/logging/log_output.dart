// lib/src/logging/log_output.dart
// Output sink interfaces and implementations for logging

import 'package:flutter/foundation.dart';

abstract class LogOutput {
  void write(String message);
  void close();
}

class ConsoleOutput implements LogOutput {
  final bool enableInRelease;

  const ConsoleOutput({this.enableInRelease = false});

  @override
  void write(String message) {
    if (kReleaseMode && !enableInRelease) {
      return;
    }

    debugPrint(message);
  }

  @override
  void close() {}
}

class MultiOutput implements LogOutput {
  final List<LogOutput> outputs;

  const MultiOutput(this.outputs);

  @override
  void write(String message) {
    for (final output in outputs) {
      output.write(message);
    }
  }

  @override
  void close() {
    for (final output in outputs) {
      output.close();
    }
  }
}
