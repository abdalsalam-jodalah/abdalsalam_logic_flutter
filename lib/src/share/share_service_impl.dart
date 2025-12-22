// lib/src/share/share_service_impl.dart
import 'package:share_plus/share_plus.dart';
import '../logging/logger_service.dart';
import 'share_service.dart';

class ShareServiceImpl implements ShareService {
  final LoggerService _logger;

  ShareServiceImpl(this._logger);

  @override
  Future<void> initialize() async {
    _logger.info('Share service initialized');
  }

  @override
  Future<void> dispose() async {
    _logger.info('Share service disposed');
  }

  @override
  Future<void> shareText(String text, {String? subject}) async {
    try {
      await Share.share(
        text,
        subject: subject,
      );
      _logger.info('Text shared successfully');
    } catch (e) {
      _logger.error('Failed to share text', error: e);
      rethrow;
    }
  }

  @override
  Future<void> shareFile(String filePath, {String? text}) async {
    try {
      final file = XFile(filePath);
      await Share.shareXFiles(
        [file],
        text: text,
      );
      _logger.info('File shared successfully: $filePath');
    } catch (e) {
      _logger.error('Failed to share file: $filePath', error: e);
      rethrow;
    }
  }

  @override
  Future<void> shareMultipleFiles(
    List<String> filePaths, {
    String? text,
  }) async {
    try {
      final files = filePaths.map((path) => XFile(path)).toList();
      await Share.shareXFiles(
        files,
        text: text,
      );
      _logger.info('Multiple files shared successfully');
    } catch (e) {
      _logger.error('Failed to share multiple files', error: e);
      rethrow;
    }
  }
}

