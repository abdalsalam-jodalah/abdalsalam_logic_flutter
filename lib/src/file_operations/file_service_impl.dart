// lib/src/file_operations/file_service_impl.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../logging/logger_service.dart';
import 'file_service.dart';

class FileServiceImpl implements FileService {
  final LoggerService _logger;

  FileServiceImpl(this._logger);

  @override
  Future<void> initialize() async {
    _logger.info('File service initialized');
  }

  @override
  Future<void> dispose() async {
    _logger.info('File service disposed');
  }

  @override
  Future<File> saveFile(String filePath, List<int> bytes) async {
    try {
      final file = File(filePath);
      await file.create(recursive: true);
      await file.writeAsBytes(bytes);
      _logger.info('File saved: $filePath');
      return file;
    } catch (e) {
      _logger.error('Failed to save file: $filePath', error: e);
      rethrow;
    }
  }

  @override
  Future<File> saveFileFromString(String filePath, String content) async {
    try {
      final file = File(filePath);
      await file.create(recursive: true);
      await file.writeAsString(content);
      _logger.info('File saved from string: $filePath');
      return file;
    } catch (e) {
      _logger.error('Failed to save file from string: $filePath', error: e);
      rethrow;
    }
  }

  @override
  Future<String> readFileAsString(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist: $filePath');
      }
      return await file.readAsString();
    } catch (e) {
      _logger.error('Failed to read file as string: $filePath', error: e);
      rethrow;
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
      _logger.error('Failed to read file as bytes: $filePath', error: e);
      rethrow;
    }
  }

  @override
  Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      _logger.error('Failed to check file existence: $filePath', error: e);
      return false;
    }
  }

  @override
  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        _logger.info('File deleted: $filePath');
      }
    } catch (e) {
      _logger.error('Failed to delete file: $filePath', error: e);
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
      _logger.error('Failed to list files in directory: $directory', error: e);
      return [];
    }
  }

  @override
  Future<Directory> createDirectory(String directoryPath) async {
    try {
      final dir = Directory(directoryPath);
      await dir.create(recursive: true);
      _logger.info('Directory created: $directoryPath');
      return dir;
    } catch (e) {
      _logger.error('Failed to create directory: $directoryPath', error: e);
      rethrow;
    }
  }

  @override
  Future<void> deleteDirectory(String directoryPath) async {
    try {
      final dir = Directory(directoryPath);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        _logger.info('Directory deleted: $directoryPath');
      }
    } catch (e) {
      _logger.error('Failed to delete directory: $directoryPath', error: e);
      rethrow;
    }
  }

  @override
  Future<String> getAppDocumentsDirectory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } catch (e) {
      _logger.error('Failed to get app documents directory', error: e);
      rethrow;
    }
  }

  @override
  Future<String> getAppCacheDirectory() async {
    try {
      final directory = await getApplicationCacheDirectory();
      return directory.path;
    } catch (e) {
      _logger.error('Failed to get app cache directory', error: e);
      rethrow;
    }
  }

  @override
  Future<String> getAppTempDirectory() async {
    try {
      final directory = await getTemporaryDirectory();
      return directory.path;
    } catch (e) {
      _logger.error('Failed to get app temp directory', error: e);
      rethrow;
    }
  }
}

