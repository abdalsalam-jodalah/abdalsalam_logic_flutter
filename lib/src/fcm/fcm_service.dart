// lib/src/fcm/fcm_service.dart
import '../core/interfaces/service_interface.dart';

abstract class FcmService extends ServiceInterface {
  Future<String?> getToken();
  Future<void> subscribeToTopic(String topic);
  Future<void> unsubscribeFromTopic(String topic);
  Stream<String> get onTokenRefresh;
  Stream<Map<String, dynamic>> get onMessage;
  Stream<Map<String, dynamic>> get onMessageOpenedApp;
}


