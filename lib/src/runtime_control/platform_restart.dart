// lib/src/runtime_control/platform_restart.dart
// Platform-specific app restart implementations

import 'dart:async';
import 'dart:io' show Platform, exit;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract class PlatformRestart {
  static PlatformRestart? _instance;
  
  static PlatformRestart get instance {
    _instance ??= _createInstance();
    return _instance!;
  }
  
  static PlatformRestart _createInstance() {
    if (kIsWeb) {
      return WebPlatformRestart();
    } else if (Platform.isAndroid) {
      return AndroidPlatformRestart();
    } else if (Platform.isIOS) {
      return IOSPlatformRestart();
    } else if (Platform.isWindows) {
      return WindowsPlatformRestart();
    } else if (Platform.isMacOS) {
      return MacOSPlatformRestart();
    } else if (Platform.isLinux) {
      return LinuxPlatformRestart();
    } else {
      return DefaultPlatformRestart();
    }
  }
  
  Future<bool> restartApp();
  Future<void> forceKillAndRestart();
  bool get supportsRestart;
  String get platformName;
}

class AndroidPlatformRestart extends PlatformRestart {
  static const MethodChannel _channel = MethodChannel('runtime_control/android');
  
  @override
  Future<bool> restartApp() async {
    try {
      // Try to use native Android restart first
      final result = await _channel.invokeMethod<bool>('restartApp');
      if (result == true) {
        return true;
      }
    } catch (e) {
      debugPrint('Native Android restart failed: $e');
    }
    
    // Fallback to process restart
    return await _processRestart();
  }
  
  @override
  Future<void> forceKillAndRestart() async {
    try {
      await _channel.invokeMethod('forceKillAndRestart');
    } catch (e) {
      debugPrint('Force kill restart failed: $e');
      exit(0);
    }
  }
  
  Future<bool> _processRestart() async {
    try {
      // Android process restart via system exit
      exit(0);
    } catch (e) {
      debugPrint('Process restart failed: $e');
      return false;
    }
  }
  
  @override
  bool get supportsRestart => true;
  
  @override
  String get platformName => 'Android';
}

class IOSPlatformRestart extends PlatformRestart {
  static const MethodChannel _channel = MethodChannel('runtime_control/ios');
  
  @override
  Future<bool> restartApp() async {
    try {
      // iOS doesn't support programmatic restart in App Store apps
      // This is primarily for development/enterprise apps
      final result = await _channel.invokeMethod<bool>('restartApp');
      if (result == true) {
        return true;
      }
    } catch (e) {
      debugPrint('Native iOS restart failed: $e');
    }
    
    // iOS fallback - exit and let the system handle it
    return await _processExit();
  }
  
  @override
  Future<void> forceKillAndRestart() async {
    try {
      await _channel.invokeMethod('forceKillAndRestart');
    } catch (e) {
      debugPrint('Force kill restart failed: $e');
      exit(0);
    }
  }
  
  Future<bool> _processExit() async {
    try {
      // iOS process exit - system will handle restart if enabled
      exit(0);
    } catch (e) {
      debugPrint('Process exit failed: $e');
      return false;
    }
  }
  
  @override
  bool get supportsRestart => false; // Limited support on iOS
  
  @override
  String get platformName => 'iOS';
}

class WebPlatformRestart extends PlatformRestart {
  @override
  Future<bool> restartApp() async {
    try {
      // Web restart via page reload
      // ignore: avoid_web_libraries_in_flutter
      final window = _getWindow();
      window?.location?.reload();
      return true;
    } catch (e) {
      debugPrint('Web restart failed: $e');
      return false;
    }
  }
  
  @override
  Future<void> forceKillAndRestart() async {
    await restartApp();
  }
  
  dynamic _getWindow() {
    try {
      // This would need to be implemented with dart:html in web builds
      return null; // Placeholder - actual implementation would use dart:html
    } catch (e) {
      return null;
    }
  }
  
  @override
  bool get supportsRestart => true;
  
  @override
  String get platformName => 'Web';
}

class WindowsPlatformRestart extends PlatformRestart {
  static const MethodChannel _channel = MethodChannel('runtime_control/windows');
  
  @override
  Future<bool> restartApp() async {
    try {
      final result = await _channel.invokeMethod<bool>('restartApp');
      if (result == true) {
        return true;
      }
    } catch (e) {
      debugPrint('Native Windows restart failed: $e');
    }
    
    return await _processRestart();
  }
  
  @override
  Future<void> forceKillAndRestart() async {
    try {
      await _channel.invokeMethod('forceKillAndRestart');
    } catch (e) {
      debugPrint('Force kill restart failed: $e');
      exit(0);
    }
  }
  
  Future<bool> _processRestart() async {
    try {
      exit(0);
    } catch (e) {
      debugPrint('Process restart failed: $e');
      return false;
    }
  }
  
  @override
  bool get supportsRestart => true;
  
  @override
  String get platformName => 'Windows';
}

class MacOSPlatformRestart extends PlatformRestart {
  static const MethodChannel _channel = MethodChannel('runtime_control/macos');
  
  @override
  Future<bool> restartApp() async {
    try {
      final result = await _channel.invokeMethod<bool>('restartApp');
      if (result == true) {
        return true;
      }
    } catch (e) {
      debugPrint('Native macOS restart failed: $e');
    }
    
    return await _processRestart();
  }
  
  @override
  Future<void> forceKillAndRestart() async {
    try {
      await _channel.invokeMethod('forceKillAndRestart');
    } catch (e) {
      debugPrint('Force kill restart failed: $e');
      exit(0);
    }
  }
  
  Future<bool> _processRestart() async {
    try {
      exit(0);
    } catch (e) {
      debugPrint('Process restart failed: $e');
      return false;
    }
  }
  
  @override
  bool get supportsRestart => true;
  
  @override
  String get platformName => 'macOS';
}

class LinuxPlatformRestart extends PlatformRestart {
  static const MethodChannel _channel = MethodChannel('runtime_control/linux');
  
  @override
  Future<bool> restartApp() async {
    try {
      final result = await _channel.invokeMethod<bool>('restartApp');
      if (result == true) {
        return true;
      }
    } catch (e) {
      debugPrint('Native Linux restart failed: $e');
    }
    
    return await _processRestart();
  }
  
  @override
  Future<void> forceKillAndRestart() async {
    try {
      await _channel.invokeMethod('forceKillAndRestart');
    } catch (e) {
      debugPrint('Force kill restart failed: $e');
      exit(0);
    }
  }
  
  Future<bool> _processRestart() async {
    try {
      exit(0);
    } catch (e) {
      debugPrint('Process restart failed: $e');
      return false;
    }
  }
  
  @override
  bool get supportsRestart => true;
  
  @override
  String get platformName => 'Linux';
}

class DefaultPlatformRestart extends PlatformRestart {
  @override
  Future<bool> restartApp() async {
    try {
      exit(0);
    } catch (e) {
      debugPrint('Default restart failed: $e');
      return false;
    }
  }
  
  @override
  Future<void> forceKillAndRestart() async {
    await restartApp();
  }
  
  @override
  bool get supportsRestart => false;
  
  @override
  String get platformName => 'Unknown';
}