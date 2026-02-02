// lib/src/file_operations/file_service_impl.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../core/errors/storage_exception.dart';
import '../core/errors/exception_mapper.dart';
import 'file_service.dart';

class FileServiceImpl implements FileService {
  FileServiceImpl();

  @override
  Future<void> initialize() async {
  }

  @override
  Future<void> dispose() async {
  }

  @override
  Future<File> saveFile(String filePath, List<int> bytes) async {
    try {
      final file = File(filePath);
      await file.create(recursive: true);
      await file.writeAsBytes(bytes);
      return file;
    } catch (e, stackTrace) {
      throw ExceptionMapper.mapException(e, stackTrace);
    }
  }

  @override
  Future<File> saveFileFromString(String filePath, String content) async {
    try {
      final file = File(filePath);
      await file.create(recursive: true);
      await file.writeAsString(content);
      return file;
    } catch (e, stackTrace) {
      throw ExceptionMapper.mapException(e, stackTrace);
    }
  }

  @override
  Future<String> readFileAsString(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw StorageException(
          message: 'File does not exist: $filePath',
          code: 'FILE_NOT_FOUND',
        );
      }
      return await file.readAsString();
    } catch (e, stackTrace) {
      throw ExceptionMapper.mapException(e, stackTrace);
    }
  }

  @override
  Future<List<int>> readFileAsBytes(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist: $filePath');
      }
      return await file.readAsBytes();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<FileSystemEntity>> listFiles(String directory) async {
    try {
      final dir = Directory(directory);
      if (!await dir.exists()) {
        return [];
      }
      return dir.listSync();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Directory> createDirectory(String directoryPath) async {
    try {
      final dir = Directory(directoryPath);
      await dir.create(recursive: true);
      return dir;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteDirectory(String directoryPath) async {
    try {
      final dir = Directory(directoryPath);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> getAppDocumentsDirectory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> getAppCacheDirectory() async {
    try {
      final directory = await getApplicationCacheDirectory();
      return directory.path;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> getAppTempDirectory() async {
    try {
      final directory = await getTemporaryDirectory();
      return directory.path;
    } catch (e) {
      rethrow;
    }
  }
}

