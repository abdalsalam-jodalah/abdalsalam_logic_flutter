// lib/src/share/share_service.dart
import '../core/interfaces/service_interface.dart';

abstract class ShareService extends ServiceInterface {
  Future<void> shareText(String text, {String? subject});
  Future<void> shareFile(String filePath, {String? text});
  Future<void> shareMultipleFiles(List<String> filePaths, {String? text});
}

