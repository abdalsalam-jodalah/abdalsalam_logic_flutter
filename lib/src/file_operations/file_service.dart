// lib/src/file_operations/file_service.dart

import '../core/interfaces/service_interface.dart';
import 'file_metadata.dart';
import 'file_downloader.dart';

abstract class FileService extends ServiceInterface {
  Future<FileMetadata> downloadFile({
    required String url,
    String? subfolder,
    String? customFileName,
    void Function(FileDownloadProgress)? onProgress,
  });
  
  Future<bool> openFile(String filePath);
  
  Future<void> deleteFile(String filePath);
  
  Future<bool> fileExists(String filePath);
  
  Future<FileMetadata?> getFileInfo(String filePath);
  
  Future<List<FileMetadata>> listFiles({String? subfolder});
  
  Future<void> clearFiles({String? subfolder});
  
  Future<String> getDownloadsPath();
  
  Future<List<String>> getSubfolders();
  
  Future<int> getTotalStorageUsage({String? subfolder});
  
  bool cancelDownload(String url);
  
  List<String> getActiveDownloads();
}


