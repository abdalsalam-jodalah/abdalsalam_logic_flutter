// lib/src/app_state/app_state_config.dart

/// Configuration for AppStateManager to enable/disable specific features.
///
/// This allows the package to be modular and only initialize features that
/// are explicitly requested by the client app. This ensures:
/// - No unnecessary dependencies are bundled
/// - No permissions are requested for unused features
/// - App store compliance (only request permissions for features actually used)
/// - Minimal app size and resource usage
///
/// Example:
/// ```dart
/// final config = AppStateConfig(
///   enableBattery: true,
///   enableWiFi: true,
///   enableStorage: false, // Don't need storage monitoring
///   enableAudio: false,   // Don't need audio monitoring
/// );
///
/// final appStateManager = AppStateManagerImpl.create(logger, config: config);
/// await appStateManager.initialize();
/// ```
class AppStateConfig {
  /// Core state features (always enabled)
  final bool enableAppLifecycle;
  final bool enableDeviceInfo;
  final bool enableConnectivity;

  /// Device state features (opt-in)
  final bool enableBattery;
  final bool enableWiFi;
  final bool enableMobileData;
  final bool enableVPN;
  final bool enableAudio;
  final bool enableStorage;
  final bool enableMemory;
  
  /// UI/Display features (opt-in)
  final bool enableOrientation;
  final bool enableScreenMetrics;
  final bool enableKeyboard;
  
  /// System features (opt-in)
  final bool enablePermissions;
  final bool enableSystemSettings;
  final bool enableAccessibility;
  
  /// App info features (opt-in)
  final bool enableAppVersion;
  final bool enableAppRuntime;
  
  /// Network features (opt-in)
  final bool enableNetworkType;

  const AppStateConfig({
    // Core features (always enabled by default)
    this.enableAppLifecycle = true,
    this.enableDeviceInfo = true,
    this.enableConnectivity = true,
    
    // Device state features (disabled by default)
    this.enableBattery = false,
    this.enableWiFi = false,
    this.enableMobileData = false,
    this.enableVPN = false,
    this.enableAudio = false,
    this.enableStorage = false,
    this.enableMemory = false,
    
    // UI/Display features (disabled by default)
    this.enableOrientation = false,
    this.enableScreenMetrics = false,
    this.enableKeyboard = false,
    
    // System features (disabled by default)
    this.enablePermissions = false,
    this.enableSystemSettings = false,
    this.enableAccessibility = false,
    
    // App info features (disabled by default)
    this.enableAppVersion = false,
    this.enableAppRuntime = false,
    
    // Network features (disabled by default)
    this.enableNetworkType = false,
  });

  /// Create a configuration with all features enabled (for testing/demo purposes)
  const AppStateConfig.all()
      : enableAppLifecycle = true,
        enableDeviceInfo = true,
        enableConnectivity = true,
        enableBattery = true,
        enableWiFi = true,
        enableMobileData = true,
        enableVPN = true,
        enableAudio = true,
        enableStorage = true,
        enableMemory = true,
        enableOrientation = true,
        enableScreenMetrics = true,
        enableKeyboard = true,
        enablePermissions = true,
        enableSystemSettings = true,
        enableAccessibility = true,
        enableAppVersion = true,
        enableAppRuntime = true,
        enableNetworkType = true;

  /// Create a minimal configuration with only core features enabled
  const AppStateConfig.minimal()
      : enableAppLifecycle = true,
        enableDeviceInfo = true,
        enableConnectivity = true,
        enableBattery = false,
        enableWiFi = false,
        enableMobileData = false,
        enableVPN = false,
        enableAudio = false,
        enableStorage = false,
        enableMemory = false,
        enableOrientation = false,
        enableScreenMetrics = false,
        enableKeyboard = false,
        enablePermissions = false,
        enableSystemSettings = false,
        enableAccessibility = false,
        enableAppVersion = false,
        enableAppRuntime = false,
        enableNetworkType = false;

  /// Returns a list of required platform permissions based on enabled features
  List<String> getRequiredPermissions() {
    final permissions = <String>[];
    
    // WiFi requires location permissions on Android
    if (enableWiFi) {
      permissions.addAll([
        'android.permission.ACCESS_WIFI_STATE',
        'android.permission.ACCESS_NETWORK_STATE',
        'android.permission.ACCESS_FINE_LOCATION',
        'android.permission.ACCESS_COARSE_LOCATION',
      ]);
    }
    
    // Storage requires storage permissions
    if (enableStorage) {
      permissions.addAll([
        'android.permission.READ_EXTERNAL_STORAGE',
        'android.permission.WRITE_EXTERNAL_STORAGE',
      ]);
    }
    
    // Connectivity requires network state permission
    if (enableConnectivity || enableNetworkType) {
      permissions.add('android.permission.ACCESS_NETWORK_STATE');
    }
    
    return permissions;
  }

  /// Returns a list of required dependencies based on enabled features
  List<String> getRequiredDependencies() {
    final dependencies = <String>[];
    
    // Core dependencies (always needed)
    dependencies.addAll([
      'connectivity_plus',
      'device_info_plus',
    ]);
    
    if (enableBattery) dependencies.add('battery_plus');
    if (enableWiFi) dependencies.add('network_info_plus');
    if (enableStorage) dependencies.add('disk_space_plus');
    if (enableAudio) dependencies.add('volume_controller');
    if (enableAppVersion) dependencies.add('package_info_plus');
    if (enablePermissions) dependencies.add('permission_handler');
    
    return dependencies;
  }

  AppStateConfig copyWith({
    bool? enableAppLifecycle,
    bool? enableDeviceInfo,
    bool? enableConnectivity,
    bool? enableBattery,
    bool? enableWiFi,
    bool? enableMobileData,
    bool? enableVPN,
    bool? enableAudio,
    bool? enableStorage,
    bool? enableMemory,
    bool? enableOrientation,
    bool? enableScreenMetrics,
    bool? enableKeyboard,
    bool? enablePermissions,
    bool? enableSystemSettings,
    bool? enableAccessibility,
    bool? enableAppVersion,
    bool? enableAppRuntime,
    bool? enableNetworkType,
  }) {
    return AppStateConfig(
      enableAppLifecycle: enableAppLifecycle ?? this.enableAppLifecycle,
      enableDeviceInfo: enableDeviceInfo ?? this.enableDeviceInfo,
      enableConnectivity: enableConnectivity ?? this.enableConnectivity,
      enableBattery: enableBattery ?? this.enableBattery,
      enableWiFi: enableWiFi ?? this.enableWiFi,
      enableMobileData: enableMobileData ?? this.enableMobileData,
      enableVPN: enableVPN ?? this.enableVPN,
      enableAudio: enableAudio ?? this.enableAudio,
      enableStorage: enableStorage ?? this.enableStorage,
      enableMemory: enableMemory ?? this.enableMemory,
      enableOrientation: enableOrientation ?? this.enableOrientation,
      enableScreenMetrics: enableScreenMetrics ?? this.enableScreenMetrics,
      enableKeyboard: enableKeyboard ?? this.enableKeyboard,
      enablePermissions: enablePermissions ?? this.enablePermissions,
      enableSystemSettings: enableSystemSettings ?? this.enableSystemSettings,
      enableAccessibility: enableAccessibility ?? this.enableAccessibility,
      enableAppVersion: enableAppVersion ?? this.enableAppVersion,
      enableAppRuntime: enableAppRuntime ?? this.enableAppRuntime,
      enableNetworkType: enableNetworkType ?? this.enableNetworkType,
    );
  }

  @override
  String toString() {
    return 'AppStateConfig(\n'
        '  Core: lifecycle=$enableAppLifecycle, device=$enableDeviceInfo, connectivity=$enableConnectivity\n'
        '  Device: battery=$enableBattery, wifi=$enableWiFi, mobileData=$enableMobileData, vpn=$enableVPN, audio=$enableAudio, storage=$enableStorage, memory=$enableMemory\n'
        '  UI: orientation=$enableOrientation, screenMetrics=$enableScreenMetrics, keyboard=$enableKeyboard\n'
        '  System: permissions=$enablePermissions, settings=$enableSystemSettings, accessibility=$enableAccessibility\n'
        '  App: version=$enableAppVersion, runtime=$enableAppRuntime\n'
        '  Network: networkType=$enableNetworkType\n'
        ')';
  }
}
