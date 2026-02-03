// lib/src/file_operations/file_downloader.dart

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import '../core/errors/file_exception.dart';
import '../core/errors/exception_mapper.dart';
import 'file_metadata.dart';

class FileDownloadProgress {
  final int bytesReceived;
  final int totalBytes;
  final double speedBytesPerSecond;
  final Duration elapsedTime;

  const FileDownloadProgress({
    required this.bytesReceived,
    required this.totalBytes,
    required this.speedBytesPerSecond,
    required this.elapsedTime,
  });

  double get progressPercentage =>
      totalBytes > 0 ? (bytesReceived / totalBytes) * 100 : 0.0;

  String get formattedSpeed {
    final speedKB = speedBytesPerSecond / 1024;
    if (speedKB < 1024) {
      return '${speedKB.toStringAsFixed(1)} KB/s';
    } else {
      final speedMB = speedKB / 1024;
      return '${speedMB.toStringAsFixed(1)} MB/s';
    }
  }

  Duration get estimatedTimeRemaining {
    if (speedBytesPerSecond <= 0 || bytesReceived >= totalBytes) {
      return Duration.zero;
    }
    final remainingBytes = totalBytes - bytesReceived;
    final remainingSeconds = remainingBytes / speedBytesPerSecond;
    return Duration(seconds: remainingSeconds.round());
  }

  @override
  String toString() {
    return 'FileDownloadProgress(${progressPercentage.toStringAsFixed(1)}%, $formattedSpeed)';
  }
}

class FileDownloader {
  final Dio _dio;
  final Map<String, CancelToken> _activeDownloads = {};

  FileDownloader({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.followRedirects = true;
    _dio.options.maxRedirects = 5;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
  }

  Future<FileMetadata> downloadFile({
    required String url,
    required String destinationPath,
    String? subfolder,
    void Function(FileDownloadProgress)? onProgress,
  }) async {
    try {
      _validateUrl(url);

      final cancelToken = CancelToken();
      _activeDownloads[url] = cancelToken;

      final fileName = _extractFileName(url, destinationPath);
      final finalDestinationPath = path.join(destinationPath, fileName);
      
      await _ensureDirectoryExists(destinationPath);

      final startTime = DateTime.now();
      int lastReceivedBytes = 0;
      DateTime lastProgressTime = startTime;

      final response = await _dio.download(
        url,
        finalDestinationPath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          final now = DateTime.now();
          final elapsedTime = now.difference(startTime);
          
          double speed = 0.0;
          if (received > lastReceivedBytes) {
            final timeDiff = now.difference(lastProgressTime).inMilliseconds;
            if (timeDiff > 0) {
              final bytesDiff = received - lastReceivedBytes;
              speed = (bytesDiff * 1000.0) / timeDiff;
            }
            lastReceivedBytes = received;
            lastProgressTime = now;
          }

          final progress = FileDownloadProgress(
            bytesReceived: received,
            totalBytes: total,
            speedBytesPerSecond: speed,
            elapsedTime: elapsedTime,
          );
          
          onProgress?.call(progress);
        },
      );

      _activeDownloads.remove(url);

      if (response.statusCode != 200) {
        throw FileDownloadException(
          message: 'Download failed with status code: ${response.statusCode}',
          code: 'DOWNLOAD_HTTP_ERROR',
        );
      }

      final file = File(finalDestinationPath);
      if (!await file.exists()) {
        throw FileDownloadException(
          message: 'Downloaded file does not exist at expected location',
          code: 'DOWNLOAD_FILE_MISSING',
        );
      }

      final fileStats = await file.stat();
      final mimeType = _detectMimeType(fileName, response.headers);

      return FileMetadata(
        fileName: fileName,
        absolutePath: file.absolute.path,
        sizeInBytes: fileStats.size,
        mimeType: mimeType,
        sourceUrl: url,
        downloadTimestamp: DateTime.now(),
        subfolder: subfolder,
      );
    } catch (e, stackTrace) {
      _activeDownloads.remove(url);
      
      if (e is DioException) {
        throw _handleDioException(e, url);
      } else if (e is FileException) {
        rethrow;
      } else {
        throw ExceptionMapper.mapException(e, stackTrace);
      }
    }
  }

  bool cancelDownload(String url) {
    final cancelToken = _activeDownloads[url];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel('User cancelled download');
      _activeDownloads.remove(url);
      return true;
    }
    return false;
  }

  List<String> getActiveDownloads() {
    return _activeDownloads.keys.toList();
  }

  void _validateUrl(String url) {
    if (url.isEmpty) {
      throw const InvalidFileUrlException(
        message: 'URL cannot be empty',
        code: 'INVALID_URL_EMPTY',
      );
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      throw InvalidFileUrlException(
        message: 'Invalid URL format: $url',
        code: 'INVALID_URL_FORMAT',
      );
    }

    if (!uri.hasScheme || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      throw InvalidFileUrlException(
        message: 'URL must use HTTP or HTTPS protocol: $url',
        code: 'INVALID_URL_PROTOCOL',
      );
    }
  }

  String _extractFileName(String url, String destinationPath) {
    final uri = Uri.parse(url);
    String fileName = path.basename(uri.path);
    
    if (fileName.isEmpty || fileName == '/') {
      fileName = 'downloaded_file_${DateTime.now().millisecondsSinceEpoch}';
    }

    fileName = _sanitizeFileName(fileName);

    final fullPath = path.join(destinationPath, fileName);
    return _getUniqueFileName(fullPath);
  }

  String _sanitizeFileName(String fileName) {
    return fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }

  String _getUniqueFileName(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) {
      return path.basename(filePath);
    }

    final dir = path.dirname(filePath);
    final nameWithoutExt = path.basenameWithoutExtension(filePath);
    final ext = path.extension(filePath);

    int counter = 1;
    String uniquePath;
    do {
      final uniqueName = '${nameWithoutExt}_$counter$ext';
      uniquePath = path.join(dir, uniqueName);
      counter++;
    } while (File(uniquePath).existsSync());

    return path.basename(uniquePath);
  }

  Future<void> _ensureDirectoryExists(String directoryPath) async {
    final directory = Directory(directoryPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  String? _detectMimeType(String fileName, Headers? headers) {
    final contentType = headers?.value('content-type');
    if (contentType != null && !contentType.contains('text/html')) {
      return contentType.split(';').first.trim();
    }

    final extension = path.extension(fileName).toLowerCase();
    switch (extension) {
      case '.pdf':
        return 'application/pdf';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.mp4':
        return 'video/mp4';
      case '.mp3':
        return 'audio/mpeg';
      case '.zip':
        return 'application/zip';
      case '.txt':
        return 'text/plain';
      case '.doc':
        return 'application/msword';
      case '.docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case '.xls':
        return 'application/vnd.ms-excel';
      case '.xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      default:
        return null;
    }
  }

  FileException _handleDioException(DioException dioError, String url) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return FileDownloadException(
          message: 'Download timeout for URL: $url',
          code: 'DOWNLOAD_TIMEOUT',
          originalException: dioError,
        );
      case DioExceptionType.badResponse:
        final statusCode = dioError.response?.statusCode ?? 0;
        if (statusCode == 404) {
          return FileNotFoundException(
            message: 'File not found at URL: $url',
            code: 'DOWNLOAD_NOT_FOUND',
            originalException: dioError,
          );
        }
        return FileDownloadException(
          message: 'Server error ($statusCode) for URL: $url',
          code: 'DOWNLOAD_SERVER_ERROR',
          originalException: dioError,
        );
      case DioExceptionType.cancel:
        return FileDownloadException(
          message: 'Download was cancelled for URL: $url',
          code: 'DOWNLOAD_CANCELLED',
          originalException: dioError,
        );
      case DioExceptionType.connectionError:
        return FileDownloadException(
          message: 'Network connection error for URL: $url',
          code: 'DOWNLOAD_CONNECTION_ERROR',
          originalException: dioError,
        );
      default:
        return FileDownloadException(
          message: 'Unknown download error for URL: $url',
          code: 'DOWNLOAD_UNKNOWN_ERROR',
          originalException: dioError,
        );
    }
  }

  void dispose() {
    for (final cancelToken in _activeDownloads.values) {
      if (!cancelToken.isCancelled) {
        cancelToken.cancel('FileDownloader disposed');
      }
    }
    _activeDownloads.clear();
  }
}