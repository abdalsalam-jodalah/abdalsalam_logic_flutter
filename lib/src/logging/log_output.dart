// lib/src/logging/log_output.dart
// Output sink interfaces and implementations for logging

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

abstract class LogOutput {
  void write(String message);
  Future<void> close();
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
  Future<void> close() async {}
}

class FileOutput implements LogOutput {
  final String fileName;
  final int maxFileSizeBytes;
  final int maxBackupFiles;
  final bool enableInRelease;
  
  IOSink? _sink;
  File? _currentFile;
  int _currentFileSize = 0;
  bool _initialized = false;
  final List<String> _buffer = [];

  FileOutput({
    this.fileName = 'app_logs.txt',
    this.maxFileSizeBytes = 10 * 1024 * 1024,
    this.maxBackupFiles = 5,
    this.enableInRelease = true,
  });

  Future<void> _initialize() async {
    if (_initialized) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final logsDir = Directory(path.join(directory.path, 'logs'));
      
      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }

      _currentFile = File(path.join(logsDir.path, fileName));

      if (await _currentFile!.exists()) {
        _currentFileSize = await _currentFile!.length();
      }

      _sink = _currentFile!.openWrite(mode: FileMode.append);
      _initialized = true;

      for (final bufferedMessage in _buffer) {
        _sink!.writeln(bufferedMessage);
      }
      _buffer.clear();
      await _sink!.flush();
    } catch (e) {
      debugPrint('FileOutput initialization failed: $e');
    }
  }

  Future<void> _rotateFile() async {
    await _sink?.close();

    for (int i = maxBackupFiles - 1; i >= 0; i--) {
      final currentBackup = i == 0
          ? _currentFile
          : File('${_currentFile!.path}.$i');
      final nextBackup = File('${_currentFile!.path}.${i + 1}');

      if (await currentBackup!.exists()) {
        if (i == maxBackupFiles - 1) {
          await currentBackup.delete();
        } else {
          await currentBackup.rename(nextBackup.path);
        }
      }
    }

    _currentFile = File(_currentFile!.path);
    _sink = _currentFile!.openWrite(mode: FileMode.write);
    _currentFileSize = 0;
  }

  @override
  void write(String message) {
    if (kReleaseMode && !enableInRelease) {
      return;
    }

    if (!_initialized) {
      _buffer.add(message);
      _initialize();
      return;
    }

    try {
      _sink?.writeln(message);
      _currentFileSize += message.length + 1;

      if (_currentFileSize >= maxFileSizeBytes) {
        _rotateFile();
      }
    } catch (e) {
      debugPrint('FileOutput write failed: $e');
    }
  }

  @override
  Future<void> close() async {
    await _sink?.flush();
    await _sink?.close();
    _sink = null;
    _initialized = false;
  }
}

class RemoteOutput implements LogOutput {
  final String endpoint;
  final Map<String, String>? headers;
  final bool enableInRelease;
  final Duration batchInterval;
  final int maxBatchSize;
  final Set<String> allowedLevels;

  final List<String> _buffer = [];
  Timer? _flushTimer;

  RemoteOutput({
    required this.endpoint,
    this.headers,
    this.enableInRelease = true,
    this.batchInterval = const Duration(seconds: 30),
    this.maxBatchSize = 100,
    this.allowedLevels = const {'ERROR', 'FATAL'},
  }) {
    _flushTimer = Timer.periodic(batchInterval, (_) => _flush());
  }

  @override
  void write(String message) {
    if (kReleaseMode && !enableInRelease) {
      return;
    }

    final shouldSend = allowedLevels.any((level) => message.contains('[$level]'));
    if (!shouldSend) {
      return;
    }

    _buffer.add(message);

    if (_buffer.length >= maxBatchSize) {
      _flush();
    }
  }

  Future<void> _flush() async {
    if (_buffer.isEmpty) return;

    final batch = List<String>.from(_buffer);
    _buffer.clear();

    try {
      final client = HttpClient();
      final request = await client.postUrl(Uri.parse(endpoint));
      
      headers?.forEach((key, value) {
        request.headers.add(key, value);
      });

      request.headers.contentType = ContentType.json;
      request.write('{"logs":${batch.map((log) => '"${_escapeJson(log)}"').toList()}}');

      final response = await request.close();
      await response.drain();
      client.close();
    } catch (e) {
      debugPrint('RemoteOutput flush failed: $e');
      _buffer.insertAll(0, batch);
    }
  }

  String _escapeJson(String text) {
    return text
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
  }

  @override
  Future<void> close() async {
    _flushTimer?.cancel();
    await _flush();
  }
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
  Future<void> close() async {
    for (final output in outputs) {
      await output.close();
    }
  }
}
