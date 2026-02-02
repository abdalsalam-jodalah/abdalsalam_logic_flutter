// lib/src/runtime_control/platform/app_restart.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Platform-specific app restart functionality that mimics Flutter's hot restart behavior
class AppRestart {
  static const MethodChannel _androidChannel = MethodChannel('runtime_control/android');
  static const MethodChannel _iosChannel = MethodChannel('runtime_control/ios');

  /// Restart the application like Flutter's hot restart.
  /// 
  /// This completely reloads the app as if you pressed the hot restart button in your IDE.
  /// Returns true if the restart was initiated successfully.
  /// 
  /// **Behavior:**
  /// - Android: Starts a new app instance and kills the current one (visible reload)
  /// - iOS: Shows restart overlay and exits (user must manually reopen)
  /// - Other platforms: Returns false
  static Future<bool> restartApp() async {
    debugPrint('🚀 Initiating app restart (like hot restart)...');
    
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _restartAndroid();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return await _restartIOS();
    }
    
    debugPrint('❌ App restart not supported on this platform');
    return false; // Unsupported platform
  }

  /// Force kill and restart the app (more aggressive than hot restart).
  /// 
  /// This method forcibly terminates the current app and starts a fresh instance.
  /// Similar to stopping and rerunning your app from the IDE.
  /// 
  /// ⚠️ **Warning:** This may cause data loss if not properly handled.
  static Future<bool> forceKillAndRestart() async {
    debugPrint('💀 Force killing and restarting app...');
    
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _forceKillAndroidApp();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return await _forceKillIOSApp();
    }
    
    debugPrint('❌ Force restart not supported on this platform');
    return false; // Unsupported platform
  }

  /// Check if the platform restart functionality is available
  static Future<bool> isRestartSupported() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        // Test if the Android plugin is available
        await _androidChannel.invokeMethod('getPlatformVersion').timeout(const Duration(seconds: 2));
        return true;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        // Test if the iOS plugin is available  
        await _iosChannel.invokeMethod('getPlatformVersion').timeout(const Duration(seconds: 2));
        return true;
      }
    } catch (e) {
      debugPrint('Platform restart not supported: $e');
    }
    return false;
  }

  static Future<bool> _restartAndroid() async {
    try {
      debugPrint('📱 Executing Android app restart...');
      
      // Add timeout to prevent hanging
      final result = await _androidChannel
          .invokeMethod('restartApp')
          .timeout(const Duration(seconds: 5));
          
      debugPrint('✅ Android restart initiated: $result');
      return result == true;
    } catch (e) {
      debugPrint('❌ Android restart failed: $e');
      
      // If plugin is missing, show helpful message
      if (e.toString().contains('MissingPluginException')) {
        debugPrint('🔧 Plugin not registered. Make sure the AbdalsalamLogicFlutterPlugin is properly registered in MainActivity.');
      }
      
      return false;
    }
  }

  static Future<bool> _restartIOS() async {
    try {
      debugPrint('🍎 Executing iOS app restart...');
      final result = await _iosChannel.invokeMethod('restartApp');
      debugPrint('✅ iOS restart initiated: $result');
      return result == true;
    } catch (e) {
      debugPrint('❌ iOS restart failed: $e');
      return false;
    }
  }

  static Future<bool> _forceKillAndroidApp() async {
    try {
      debugPrint('📱💀 Force killing Android app...');
      
      // Add timeout to prevent hanging
      final result = await _androidChannel
          .invokeMethod('forceKillAndRestart')
          .timeout(const Duration(seconds: 5));
          
      debugPrint('✅ Android force restart initiated: $result');
      return result == true;
    } catch (e) {
      debugPrint('❌ Android force kill failed: $e');
      
      // If the method channel fails, provide fallback
      if (e.toString().contains('MissingPluginException')) {
        debugPrint('🔧 Plugin not found - trying regular restart fallback');
        return await _restartAndroid();
      }
      
      return false;
    }
  }

  static Future<bool> _forceKillIOSApp() async {
    try {
      debugPrint('🍎💀 Force killing iOS app...');
      final result = await _iosChannel.invokeMethod('forceKillAndRestart');
      debugPrint('✅ iOS force restart initiated: $result');
      return result == true;
    } catch (e) {
      debugPrint('❌ iOS force kill failed: $e');
      return false;
    }
  }
}