# Firebase Cloud Messaging (FCM)

**Version:** 1.0.0  
**Last Updated:** January 6, 2026  
**Package:** abdalsalam_logic_flutter

---

## Overview

The FCM Service provides a unified interface for Firebase Cloud Messaging operations including token management, topic subscriptions, and message handling.

### Key Features

✅ **Token Management** - Get and refresh FCM tokens  
✅ **Topic Subscriptions** - Subscribe/unsubscribe from topics  
✅ **Message Streams** - Real-time notification handling  
✅ **Background Messages** - Handle messages when app is closed  
✅ **Deep Linking** - Navigate based on notification data  

---

## API Reference

### Interface: FcmService

```dart
abstract class FcmService extends ServiceInterface {
  Future<String?> getToken();
  Future<void> subscribeToTopic(String topic);
  Future<void> unsubscribeFromTopic(String topic);
  Stream<String> get onTokenRefresh;
  Stream<Map<String, dynamic>> get onMessage;
  Stream<Map<String, dynamic>> get onMessageOpenedApp;
}
```

### Methods

#### getToken()
```dart
Future<String?> getToken()
```
Retrieves the current FCM registration token.

**Returns:** FCM token string, or `null` if unavailable

**Example:**
```dart
final token = await fcmService.getToken();
if (token != null) {
  print('FCM Token: $token');
  sendTokenToServer(token);
}
```

---

#### subscribeToTopic()
```dart
Future<void> subscribeToTopic(String topic)
```
Subscribes the device to a specific topic for targeted messaging.

**Parameters:**
- `topic` - Topic name (e.g., 'news', 'updates', 'sports')

**Example:**
```dart
await fcmService.subscribeToTopic('breaking_news');
print('Subscribed to breaking news');
```

---

#### unsubscribeFromTopic()
```dart
Future<void> unsubscribeFromTopic(String topic)
```
Unsubscribes the device from a topic.

**Parameters:**
- `topic` - Topic name to unsubscribe from

**Example:**
```dart
await fcmService.unsubscribeFromTopic('sports');
print('Unsubscribed from sports');
```

---

### Streams

#### onTokenRefresh
```dart
Stream<String> get onTokenRefresh
```
Streams FCM token refresh events. Listen to update your server with the new token.

**Example:**
```dart
fcmService.onTokenRefresh.listen((newToken) {
  print('Token refreshed: $newToken');
  sendTokenToServer(newToken);
});
```

---

#### onMessage
```dart
Stream<Map<String, dynamic>> get onMessage
```
Streams messages received while the app is in the **foreground**.

**Example:**
```dart
fcmService.onMessage.listen((message) {
  print('Foreground message: $message');
  showInAppNotification(message);
});
```

---

#### onMessageOpenedApp
```dart
Stream<Map<String, dynamic>> get onMessageOpenedApp
```
Streams messages that opened the app (tapped while app was in **background** or **terminated**).

**Example:**
```dart
fcmService.onMessageOpenedApp.listen((message) {
  print('App opened from notification: $message');
  handleDeepLink(message['data']);
});
```

---

## Message Structure

FCM messages typically have this structure:

```dart
{
  'notification': {
    'title': 'New Message',
    'body': 'You have a new message from John',
  },
  'data': {
    'type': 'chat',
    'chatId': '12345',
    'senderId': '67890',
  },
}
```

---

## Usage Examples

### Example 1: Basic Setup

```dart
class NotificationService {
  final FcmService _fcmService;
  
  NotificationService(this._fcmService);
  
  Future<void> initialize() async {
    // Initialize FCM
    await _fcmService.initialize();
    
    // Get and send token to server
    final token = await _fcmService.getToken();
    if (token != null) {
      await _sendTokenToServer(token);
    }
    
    // Listen for token refresh
    _fcmService.onTokenRefresh.listen((newToken) {
      _sendTokenToServer(newToken);
    });
    
    // Handle foreground messages
    _fcmService.onMessage.listen(_handleForegroundMessage);
    
    // Handle notification taps
    _fcmService.onMessageOpenedApp.listen(_handleNotificationTap);
  }
  
  Future<void> _sendTokenToServer(String token) async {
    // Send to your backend
    await apiClient.post('/user/fcm-token', data: {'token': token});
  }
  
  void _handleForegroundMessage(Map<String, dynamic> message) {
    // Show in-app notification
    showOverlayNotification(
      title: message['notification']['title'],
      body: message['notification']['body'],
    );
  }
  
  void _handleNotificationTap(Map<String, dynamic> message) {
    // Navigate based on data
    final data = message['data'];
    if (data['type'] == 'chat') {
      navigateToChatScreen(data['chatId']);
    }
  }
}
```

### Example 2: Topic Management

```dart
class TopicManager {
  final FcmService _fcmService;
  
  TopicManager(this._fcmService);
  
  Future<void> updateUserTopics(List<String> interests) async {
    // Subscribe to topics based on user interests
    for (final interest in interests) {
      await _fcmService.subscribeToTopic(interest);
    }
    
    print('Subscribed to: ${interests.join(", ")}');
  }
  
  Future<void> subscribeToUserGroup(String userId) async {
    // Subscribe to user-specific topic
    await _fcmService.subscribeToTopic('user_$userId');
  }
  
  Future<void> unsubscribeFromAll(List<String> topics) async {
    for (final topic in topics) {
      await _fcmService.unsubscribeFromTopic(topic);
    }
  }
}
```

### Example 3: Notification Permission

```dart
class NotificationPermissionManager {
  final FcmService _fcmService;
  
  NotificationPermissionManager(this._fcmService);
  
  Future<bool> requestPermission() async {
    // Request notification permission (iOS mainly)
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      
      // Get token after permission granted
      final token = await _fcmService.getToken();
      if (token != null) {
        await _sendTokenToServer(token);
      }
      
      return true;
    }
    
    return false;
  }
  
  Future<void> _sendTokenToServer(String token) async {
    // Implementation
  }
}
```

### Example 4: Deep Linking

```dart
class DeepLinkHandler {
  final FcmService _fcmService;
  final NavigatorKey navigatorKey;
  
  DeepLinkHandler(this._fcmService, this.navigatorKey);
  
  void initialize() {
    // Handle notification taps
    _fcmService.onMessageOpenedApp.listen(_handleDeepLink);
  }
  
  void _handleDeepLink(Map<String, dynamic> message) {
    final data = message['data'];
    final type = data['type'];
    
    switch (type) {
      case 'chat':
        _navigateToChat(data['chatId']);
        break;
      case 'profile':
        _navigateToProfile(data['userId']);
        break;
      case 'order':
        _navigateToOrder(data['orderId']);
        break;
      default:
        _navigateToHome();
    }
  }
  
  void _navigateToChat(String chatId) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(chatId: chatId),
      ),
    );
  }
  
  void _navigateToProfile(String userId) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => ProfileScreen(userId: userId),
      ),
    );
  }
  
  void _navigateToOrder(String orderId) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => OrderScreen(orderId: orderId),
      ),
    );
  }
  
  void _navigateToHome() {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => HomeScreen()),
      (route) => false,
    );
  }
}
```

### Example 5: User Preferences

```dart
class NotificationPreferences {
  final FcmService _fcmService;
  final KeyValueStorage<bool> _storage;
  
  NotificationPreferences(this._fcmService, this._storage);
  
  Future<void> updatePreferences({
    bool? enableNews,
    bool? enablePromotions,
    bool? enableUpdates,
  }) async {
    if (enableNews != null) {
      await _updateTopic('news', enableNews);
      await _storage.set('notif_news', enableNews);
    }
    
    if (enablePromotions != null) {
      await _updateTopic('promotions', enablePromotions);
      await _storage.set('notif_promotions', enablePromotions);
    }
    
    if (enableUpdates != null) {
      await _updateTopic('updates', enableUpdates);
      await _storage.set('notif_updates', enableUpdates);
    }
  }
  
  Future<void> _updateTopic(String topic, bool enable) async {
    if (enable) {
      await _fcmService.subscribeToTopic(topic);
    } else {
      await _fcmService.unsubscribeFromTopic(topic);
    }
  }
  
  Future<Map<String, bool>> getPreferences() async {
    return {
      'news': await _storage.get('notif_news') ?? true,
      'promotions': await _storage.get('notif_promotions') ?? false,
      'updates': await _storage.get('notif_updates') ?? true,
    };
  }
}
```

---

## Setup

### 1. Firebase Configuration

Add Firebase to your project:

```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_messaging: ^14.7.0
```

### 2. Platform Setup

#### iOS

Add to `ios/Runner/Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
  <string>fetch</string>
  <string>remote-notification</string>
</array>
```

#### Android

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<application>
  <!-- FCM -->
  <meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="high_importance_channel" />
</application>
```

### 3. Initialize Firebase

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Setup FCM service
  final fcmService = GetIt.I<FcmService>();
  await fcmService.initialize();
  
  runApp(MyApp());
}
```

---

## Best Practices

### 1. Handle Token Updates

✅ **DO**: Update server when token changes
```dart
fcmService.onTokenRefresh.listen((token) {
  apiClient.post('/user/fcm-token', data: {'token': token});
});
```

### 2. Request Permission Explicitly

✅ **DO**: Ask for permission at appropriate time
```dart
if (userCompletedOnboarding) {
  await requestNotificationPermission();
}
```

❌ **DON'T**: Request on app launch
```dart
void main() {
  requestNotificationPermission(); // Too early!
}
```

### 3. Handle Foreground Messages

✅ **DO**: Show in-app notifications
```dart
fcmService.onMessage.listen((message) {
  showInAppNotification(message);
});
```

### 4. Validate Message Data

✅ **DO**: Check data before navigation
```dart
void handleMessage(Map<String, dynamic> message) {
  final data = message['data'];
  if (data != null && data['chatId'] != null) {
    navigateToChat(data['chatId']);
  }
}
```

### 5. Unsubscribe on Logout

✅ **DO**: Clean up topics on sign out
```dart
Future<void> logout() async {
  await fcmService.unsubscribeFromTopic('user_$userId');
  await authService.signOut();
}
```

---

## Message Types

### 1. Notification Messages

Displayed automatically by the system:

```json
{
  "notification": {
    "title": "Hello!",
    "body": "This is a notification"
  }
}
```

### 2. Data Messages

Handled by your app:

```json
{
  "data": {
    "type": "chat",
    "chatId": "123",
    "message": "Hello!"
  }
}
```

### 3. Combined Messages

Both notification and data:

```json
{
  "notification": {
    "title": "New Message",
    "body": "You have a new message"
  },
  "data": {
    "type": "chat",
    "chatId": "123"
  }
}
```

---

## Sending Messages

### From Server (Node.js)

```javascript
const admin = require('firebase-admin');

// Send to specific device
await admin.messaging().send({
  token: 'device_fcm_token',
  notification: {
    title: 'Hello',
    body: 'This is a test'
  },
  data: {
    type: 'test',
    id: '123'
  }
});

// Send to topic
await admin.messaging().send({
  topic: 'news',
  notification: {
    title: 'Breaking News',
    body: 'Important update'
  }
});
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Token is null | Check Firebase configuration and permissions |
| Messages not received | Verify APNs/FCM credentials |
| Background messages ignored | Implement background handler |
| Topic subscription fails | Check topic name format (alphanumeric + underscore) |

---

## Summary

The FCM Service provides:

✅ **Token management** - Get and refresh FCM tokens  
✅ **Topic subscriptions** - Subscribe to targeted messages  
✅ **Real-time streams** - Handle foreground and background messages  
✅ **Deep linking** - Navigate based on notification data  
✅ **User preferences** - Manage notification settings  

Integrate it to add push notifications to your Flutter app.
