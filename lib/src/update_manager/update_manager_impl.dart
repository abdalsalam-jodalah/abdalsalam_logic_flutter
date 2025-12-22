// lib/src/update_manager/update_manager_impl.dart
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:async';
import '../logging/logger_service.dart';
import 'update_manager.dart';

class UpdateManagerImpl implements UpdateManager {
  final LoggerService _logger;
  final StreamController<double> _downloadProgressController =
      StreamController<double>.broadcast();

  UpdateManagerImpl(this._logger);

  @override
  Future<void> initialize() async {
    _logger.info('Update manager initialized');
  }

  @override
  Future<void> dispose() async {
    await _downloadProgressController.close();
    _logger.info('Update manager disposed');
  }

  @override
  Future<bool> checkForUpdates() async {
    try {
      final currentVersion = await getCurrentVersion();
      final latestVersion = await getLatestVersion();
      
      final needsUpdate = _compareVersions(currentVersion, latestVersion) < 0;
      _logger.info(
        'Update check: current=$currentVersion, latest=$latestVersion, needsUpdate=$needsUpdate',
      );
      
      return needsUpdate;
    } catch (e) {
      _logger.error('Failed to check for updates', error: e);
      return false;
    }
  }

  @override
  Future<void> downloadUpdate() async {
    try {
      _logger.info('Starting update download...');
      // Simulate download progress
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 100));
        _downloadProgressController.add(i / 100);
      }
      _logger.info('Update download completed');
    } catch (e) {
      _logger.error('Failed to download update', error: e);
      rethrow;
    }
  }

  @override
  Future<void> installUpdate() async {
    try {
      _logger.info('Installing update...');
      // Implementation depends on platform-specific update mechanism
      await Future.delayed(const Duration(seconds: 1));
      _logger.info('Update installed successfully');
    } catch (e) {
      _logger.error('Failed to install update', error: e);
      rethrow;
    }
  }

  @override
  Future<String> getCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      _logger.error('Failed to get current version', error: e);
      return '0.0.0';
    }
  }

  @override
  Future<String> getLatestVersion() async {
    try {
      // This should call your API to get the latest version
      // For now, returning a placeholder
      return '1.0.0';
    } catch (e) {
      _logger.error('Failed to get latest version', error: e);
      return '0.0.0';
    }
  }

  @override
  Stream<double> get downloadProgress => _downloadProgressController.stream;

  int _compareVersions(String version1, String version2) {
    final v1Parts = version1.split('.').map(int.parse).toList();
    final v2Parts = version2.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      final v1Part = i < v1Parts.length ? v1Parts[i] : 0;
      final v2Part = i < v2Parts.length ? v2Parts[i] : 0;

      if (v1Part < v2Part) return -1;
      if (v1Part > v2Part) return 1;
    }

    return 0;
  }
}

