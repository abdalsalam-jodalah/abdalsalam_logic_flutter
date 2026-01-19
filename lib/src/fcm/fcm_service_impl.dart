// lib/src/fcm/fcm_service_impl.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'fcm_service.dart';

class FcmServiceImpl implements FcmService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  FcmServiceImpl();

  @override
  Future<void> initialize() async {
    try {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Stream<String> get onTokenRefresh => _firebaseMessaging.onTokenRefresh;

  @override
  Stream<Map<String, dynamic>> get onMessage {
    return FirebaseMessaging.onMessage.map((message) {
      return {
        'notification': message.notification != null
            ? {
                'title': message.notification?.title,
                'body': message.notification?.body,
              }
            : null,
        'data': message.data,
      };
    });
  }

  @override
  Stream<Map<String, dynamic>> get onMessageOpenedApp {
    return FirebaseMessaging.onMessageOpenedApp.map((message) {
      return {
        'notification': message.notification != null
            ? {
                'title': message.notification?.title,
                'body': message.notification?.body,
              }
            : null,
        'data': message.data,
      };
    });
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message
}

