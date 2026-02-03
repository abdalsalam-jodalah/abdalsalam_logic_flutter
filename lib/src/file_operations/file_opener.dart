// lib/src/file_operations/file_opener.dart

import 'dart:io';
import '../core/errors/file_exception.dart';
import '../core/errors/exception_mapper.dart';

abstract class FileOpener {
  Future<bool> openFile(String filePath);
  Future<bool> canOpenFile(String filePath);
  Future<List<String>> getSupportedMimeTypes();
}

class FileOpenerImpl implements FileOpener {
  @override
  Future<bool> openFile(String filePath) async {
    try {
      final file = File(filePath);
      
      if (!await file.exists()) {
        throw FileNotFoundException(
          message: 'File does not exist: $filePath',
          code: 'FILE_NOT_FOUND',
        );
      }

      return await _openFileNative(filePath);
    } catch (e, stackTrace) {
      if (e is FileException) {
        rethrow;
      } else {
        throw ExceptionMapper.mapException(e, stackTrace);
      }
    }
  }

  @override
  Future<bool> canOpenFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return false;
      }

      return await _canOpenFileNative(filePath);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<String>> getSupportedMimeTypes() async {
    try {
      return await _getSupportedMimeTypesNative();
    } catch (e) {
      return [];
    }
  }

  Future<bool> _openFileNative(String filePath) async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        return await _openFileMobile(filePath);
      } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        return await _openFileDesktop(filePath);
      } else {
        throw UnsupportedFileTypeException(
          message: 'Platform not supported for file opening: ${Platform.operatingSystem}',
          code: 'PLATFORM_NOT_SUPPORTED',
        );
      }
    } catch (e, stackTrace) {
      if (e is FileException) {
        rethrow;
      }
      
      throw FileOpenException(
        message: 'Failed to open file: $filePath',
        code: 'FILE_OPEN_FAILED',
        originalException: e is Exception ? e : null,
        stackTrace: stackTrace,
      );
    }
  }

  Future<bool> _openFileMobile(String filePath) async {
    try {
      final result = await Process.run('open', [filePath]);
      return result.exitCode == 0;
    } catch (e) {
      try {
        final result = await Process.run('xdg-open', [filePath]);
        return result.exitCode == 0;
      } catch (e2) {
        return false;
      }
    }
  }

  Future<bool> _openFileDesktop(String filePath) async {
    try {
      if (Platform.isWindows) {
        final result = await Process.run('cmd', ['/c', 'start', '', filePath]);
        return result.exitCode == 0;
      } else if (Platform.isMacOS) {
        final result = await Process.run('open', [filePath]);
        return result.exitCode == 0;
      } else if (Platform.isLinux) {
        final result = await Process.run('xdg-open', [filePath]);
        return result.exitCode == 0;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _canOpenFileNative(String filePath) async {
    if (Platform.isAndroid || Platform.isIOS) {
      return true;
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      final commonExtensions = {
        '.txt', '.pdf', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx',
        '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.svg',
        '.mp3', '.wav', '.mp4', '.avi', '.mov', '.wmv',
        '.zip', '.rar', '.7z', '.tar', '.gz',
        '.html', '.htm', '.xml', '.json', '.csv'
      };
      
      final extension = _getFileExtension(filePath).toLowerCase();
      return commonExtensions.contains(extension);
    }
    return false;
  }

  Future<List<String>> _getSupportedMimeTypesNative() async {
    return [
      'text/plain',
      'application/pdf',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'application/vnd.ms-excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'application/vnd.ms-powerpoint',
      'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'image/jpeg',
      'image/png',
      'image/gif',
      'image/bmp',
      'image/svg+xml',
      'audio/mpeg',
      'audio/wav',
      'video/mp4',
      'video/avi',
      'video/quicktime',
      'application/zip',
      'application/x-rar-compressed',
      'application/x-7z-compressed',
      'text/html',
      'application/xml',
      'application/json',
      'text/csv',
    ];
  }

  String _getFileExtension(String filePath) {
    final lastDot = filePath.lastIndexOf('.');
    if (lastDot == -1) return '';
    return filePath.substring(lastDot);
  }
}