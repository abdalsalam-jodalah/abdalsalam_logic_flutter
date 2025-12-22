// lib/src/file_operations/file_service.dart
import '../core/interfaces/service_interface.dart';
import 'dart:io';

abstract class FileService extends ServiceInterface {
  Future<File> saveFile(String path, List<int> bytes);
  Future<File> saveFileFromString(String path, String content);
  Future<String> readFileAsString(String path);
  Future<List<int>> readFileAsBytes(String path);
  Future<bool> fileExists(String path);
  Future<void> deleteFile(String path);
  Future<List<FileSystemEntity>> listFiles(String directory);
  Future<Directory> createDirectory(String path);
  Future<void> deleteDirectory(String path);
  Future<String> getAppDocumentsDirectory();
  Future<String> getAppCacheDirectory();
  Future<String> getAppTempDirectory();
}


