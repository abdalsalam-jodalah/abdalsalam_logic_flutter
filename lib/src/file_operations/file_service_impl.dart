// lib/src/file_operations/file_service_impl.dart

import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../core/errors/file_exception.dart';
import '../core/errors/exception_mapper.dart';
import 'file_service.dart';
import 'file_metadata.dart';
import 'file_downloader.dart';
import 'file_opener.dart';

class FileServiceImpl implements FileService {
  final String _appName;
  late final FileDownloader _downloader;
  late final FileOpener _opener;
  String? _downloadsPath;

  FileServiceImpl({required String appName}) 
    : _appName = appName,
      _downloader = FileDownloader(),
      _opener = FileOpenerImpl();

  @override
  Future<void> initialize() async {
    try {
      await _initializeDownloadsPath();
    } catch (e, stackTrace) {
      throw ExceptionMapper.mapException(e, stackTrace);
    }
  }

  @override
  Future<void> dispose() async {
    _downloader.dispose();
  }

  @override
  Future<FileMetadata> downloadFile({
    required String url,
    String? subfolder,
    String? customFileName,
    void Function(FileDownloadProgress)? onProgress,
  }) async {
    try {
      final downloadPath = await _getAppDownloadPath(subfolder);
      final metadata = await _downloader.downloadFile(
        url: url,
        destinationPath: downloadPath,
        subfolder: subfolder,
        onProgress: onProgress,
      );
      
      if (customFileName != null) {
        final newPath = path.join(downloadPath, customFileName);
        final oldFile = File(metadata.absolutePath);
        final newFile = await oldFile.rename(newPath);
        
        return metadata.copyWith(
          fileName: customFileName,
          absolutePath: newFile.absolute.path,
        );
      }
      
      return metadata;
    } catch (e, stackTrace) {
      if (e is FileException) {
        rethrow;
      } else {
        throw ExceptionMapper.mapException(e, stackTrace);
      }
    }
  }

  @override
  Future<bool> openFile(String filePath) async {
    try {
      return await _opener.openFile(filePath);
    } catch (e, stackTrace) {
      if (e is FileException) {
        rethrow;
      } else {
        throw ExceptionMapper.mapException(e, stackTrace);
      }
    }
  }

  @override
  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      
      if (!await file.exists()) {
        throw FileNotFoundException(
          message: 'File does not exist: $filePath',
          code: 'FILE_NOT_FOUND',
        );
      }

      await file.delete();
    } catch (e, stackTrace) {
      if (e is FileException) {
        rethrow;
      } else {
        throw ExceptionMapper.mapException(e, stackTrace);
      }
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
  Future<FileMetadata?> getFileInfo(String filePath) async {
    try {
      final file = File(filePath);
      
      if (!await file.exists()) {
        return null;
      }

      final stats = await file.stat();
      final fileName = path.basename(filePath);
      final appDownloadsPath = await _getAppDownloadPath();
      
      String? subfolder;
      if (filePath.startsWith(appDownloadsPath)) {
        final relativePath = path.relative(filePath, from: appDownloadsPath);
        final pathSegments = path.split(relativePath);
        if (pathSegments.length > 1) {
          subfolder = pathSegments.first;
        }
      }

      return FileMetadata(
        fileName: fileName,
        absolutePath: file.absolute.path,
        sizeInBytes: stats.size,
        downloadTimestamp: stats.modified,
        subfolder: subfolder,
      );
    } catch (e, stackTrace) {
      if (e is FileException) {
        rethrow;
      } else {
        throw ExceptionMapper.mapException(e, stackTrace);
      }
    }
  }

  @override
  Future<List<FileMetadata>> listFiles({String? subfolder}) async {
    try {
      final downloadPath = await _getAppDownloadPath(subfolder);
      final directory = Directory(downloadPath);
      
      if (!await directory.exists()) {
        return [];
      }

      final entities = await directory.list().toList();
      final files = entities.whereType<File>();
      final metadataList = <FileMetadata>[];

      for (final file in files) {
        final metadata = await getFileInfo(file.path);
        if (metadata != null) {
          metadataList.add(metadata);
        }
      }

      metadataList.sort((a, b) => b.downloadTimestamp.compareTo(a.downloadTimestamp));
      return metadataList;
    } catch (e, stackTrace) {
      if (e is FileException) {
        rethrow;
      } else {
        throw ExceptionMapper.mapException(e, stackTrace);
      }
    }
  }

  @override
  Future<void> clearFiles({String? subfolder}) async {
    try {
      final downloadPath = await _getAppDownloadPath(subfolder);
      final directory = Directory(downloadPath);
      
      if (!await directory.exists()) {
        return;
      }

      final entities = await directory.list().toList();
      
      for (final entity in entities) {
        if (entity is File) {
          await entity.delete();
        } else if (entity is Directory && subfolder == null) {
          await entity.delete(recursive: true);
        }
      }
    } catch (e, stackTrace) {
      if (e is FileException) {
        rethrow;
      } else {
        throw ExceptionMapper.mapException(e, stackTrace);
      }
    }
  }

  @override
  Future<String> getDownloadsPath() async {
    return await _getAppDownloadPath();
  }

  @override
  Future<List<String>> getSubfolders() async {
    try {
      final appDownloadsPath = await _getAppDownloadPath();
      final directory = Directory(appDownloadsPath);
      
      if (!await directory.exists()) {
        return [];
      }

      final entities = await directory.list().toList();
      final subfolders = entities
          .whereType<Directory>()
          .map((dir) => path.basename(dir.path))
          .toList();
          
      subfolders.sort();
      return subfolders;
    } catch (e, stackTrace) {
      if (e is FileException) {
        rethrow;
      } else {
        throw ExceptionMapper.mapException(e, stackTrace);
      }
    }
  }

  @override
  Future<int> getTotalStorageUsage({String? subfolder}) async {
    try {
      final files = await listFiles(subfolder: subfolder);
      return files.fold<int>(0, (total, file) => total + file.sizeInBytes);
    } catch (e, stackTrace) {
      if (e is FileException) {
        rethrow;
      } else {
        throw ExceptionMapper.mapException(e, stackTrace);
      }
    }
  }

  @override
  bool cancelDownload(String url) {
    return _downloader.cancelDownload(url);
  }

  @override
  List<String> getActiveDownloads() {
    return _downloader.getActiveDownloads();
  }

  Future<void> _initializeDownloadsPath() async {
    try {
      _downloadsPath = await _getSystemDownloadsPath();
      final appDownloadsPath = await _getAppDownloadPath();
      final directory = Directory(appDownloadsPath);
      
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      
      if (!await _hasWritePermission(appDownloadsPath)) {
        throw const FilePermissionException(
          message: 'No write permission for downloads directory',
          code: 'PERMISSION_DENIED',
        );
      }
    } catch (e, stackTrace) {
      if (e is FileException) {
        rethrow;
      } else {
        throw ExceptionMapper.mapException(e, stackTrace);
      }
    }
  }

  Future<String> _getSystemDownloadsPath() async {
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        final directory = await getExternalStorageDirectory();
        if (directory != null) {
          return path.join(directory.path, 'Downloads');
        }
      } catch (e) {
      }
      
      final directory = await getApplicationDocumentsDirectory();
      return path.join(directory.path, 'Downloads');
    } else if (Platform.isWindows) {
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile != null) {
        return path.join(userProfile, 'Downloads');
      }
      final directory = await getApplicationDocumentsDirectory();
      return path.join(directory.path, 'Downloads');
    } else if (Platform.isMacOS || Platform.isLinux) {
      final home = Platform.environment['HOME'];
      if (home != null) {
        return path.join(home, 'Downloads');
      }
      final directory = await getApplicationDocumentsDirectory();
      return path.join(directory.path, 'Downloads');
    } else {
      final directory = await getApplicationDocumentsDirectory();
      return path.join(directory.path, 'Downloads');
    }
  }

  Future<String> _getAppDownloadPath([String? subfolder]) async {
    final systemDownloads = _downloadsPath ?? await _getSystemDownloadsPath();
    final appDownloads = path.join(systemDownloads, _appName);
    
    if (subfolder != null && subfolder.isNotEmpty) {
      return path.join(appDownloads, subfolder);
    }
    
    return appDownloads;
  }

  Future<bool> _hasWritePermission(String directoryPath) async {
    try {
      final testFile = File(path.join(directoryPath, '.write_test'));
      await testFile.writeAsString('test');
      await testFile.delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}

