// lib/src/share/share_service_impl.dart
import 'package:share_plus/share_plus.dart';
import '../core/errors/exception_mapper.dart';
import 'share_service.dart';

class ShareServiceImpl implements ShareService {
  ShareServiceImpl();

  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> shareText(String text, {String? subject}) async {
    try {
      await Share.share(
        text,
        subject: subject,
      );
    } catch (e, stackTrace) {
      throw ExceptionMapper.mapException(e, stackTrace);
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
    } catch (e) {
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
    } catch (e) {
      rethrow;
    }
  }
}

