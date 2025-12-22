// lib/src/app_initialization/app_initializer.dart
import '../core/interfaces/service_interface.dart';

abstract class AppInitializer extends ServiceInterface {
  Future<void> initializeServices();
  Future<void> initializeStorage();
  Future<void> initializeNetworking();
  Future<void> initializeAuth();
  Future<void> initializeFCM();
}

