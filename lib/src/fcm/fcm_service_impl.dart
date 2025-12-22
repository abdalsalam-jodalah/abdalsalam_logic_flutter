// lib/src/fcm/fcm_service_impl.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import '../logging/logger_service.dart';
import 'fcm_service.dart';

class FcmServiceImpl implements FcmService {
  final LoggerService _logger;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  FcmServiceImpl(this._logger);

  @override
  Future<void> initialize() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        _logger.info('FCM permission granted');
      } else {
        _logger.warning('FCM permission denied');
      }

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    } catch (e) {
      _logger.error('Failed to initialize FCM', error: e);
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    _logger.info('FCM service disposed');
  }

  @override
  Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      _logger.error('Failed to get FCM token', error: e);
      return null;
    }
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      _logger.info('Subscribed to topic: $topic');
    } catch (e) {
      _logger.error('Failed to subscribe to topic: $topic', error: e);
      rethrow;
    }
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      _logger.info('Unsubscribed from topic: $topic');
    } catch (e) {
      _logger.error('Failed to unsubscribe from topic: $topic', error: e);
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

