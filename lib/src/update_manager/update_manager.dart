// lib/src/update_manager/update_manager.dart
import '../core/interfaces/service_interface.dart';

abstract class UpdateManager extends ServiceInterface {
  Future<bool> checkForUpdates();
  Future<void> downloadUpdate();
  Future<void> installUpdate();
  Future<String> getCurrentVersion();
  Future<String> getLatestVersion();
  Stream<double> get downloadProgress;
}


