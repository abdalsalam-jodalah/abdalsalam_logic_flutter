// lib/examples/app_state_detection_example.dart
import 'package:flutter/material.dart';
import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';

class AppStateDetectionExample extends StatefulWidget {
  final AppStateManager appStateManager;

  const AppStateDetectionExample({required this.appStateManager, super.key});

  @override
  State<AppStateDetectionExample> createState() =>
      _AppStateDetectionExampleState();
}

class _AppStateDetectionExampleState extends State<AppStateDetectionExample> {
  bool _isRefreshing = false;

  Future<void> _refreshAll() async {
    setState(() => _isRefreshing = true);
    await widget.appStateManager.refreshAll();
    setState(() => _isRefreshing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ App state refreshed successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App State Detection Demo'),
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _refreshAll,
            tooltip: 'Refresh All State',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _AppLifecycleSection(appStateManager: widget.appStateManager),
            _DeviceInfoSection(appStateManager: widget.appStateManager),
            _DeviceOrientationSection(appStateManager: widget.appStateManager),
            _AppVersionSection(appStateManager: widget.appStateManager),
            _AppRuntimeSection(appStateManager: widget.appStateManager),
            _ConnectivitySection(appStateManager: widget.appStateManager),
            _WiFiSection(appStateManager: widget.appStateManager),
            _MobileDataSection(appStateManager: widget.appStateManager),
            _VpnSection(appStateManager: widget.appStateManager),
            _KeyboardSection(appStateManager: widget.appStateManager),
            _BatterySection(appStateManager: widget.appStateManager),
            _NetworkSection(appStateManager: widget.appStateManager),
            _StorageSection(appStateManager: widget.appStateManager),
            _ScreenMetricsSection(appStateManager: widget.appStateManager),
            _SystemSettingsSection(appStateManager: widget.appStateManager),
            _AudioStateSection(appStateManager: widget.appStateManager),
            _AccessibilitySection(appStateManager: widget.appStateManager),
            _MemorySection(appStateManager: widget.appStateManager),
            _AuthenticationSection(appStateManager: widget.appStateManager),
            _PermissionsSection(appStateManager: widget.appStateManager),
            _ThemeSection(appStateManager: widget.appStateManager),
            _LocaleSection(appStateManager: widget.appStateManager),
            _NavigationSection(appStateManager: widget.appStateManager),
            _FullStateSection(appStateManager: widget.appStateManager),
          ],
        ),
      ),
    );
  }
}

class _AppLifecycleSection extends StatelessWidget {
  final AppStateManager appStateManager;

  const _AppLifecycleSection({required this.appStateManager});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppStateInfo>(
      stream: appStateManager.stateStream,
      initialData: appStateManager.currentState,
      builder: (context, snapshot) {
        final state = snapshot.data!;

        return _Section(
          title: '📱 App Lifecycle & Connectivity',
          children: [
            _StateRow('Lifecycle', state.lifecycle.name),
            _StateRow('Focus', state.focus.name),
            _StateRow('Connectivity', state.connectivity.name),
            _StateRow(
              'Is Online',
              state.connectivity == ConnectivityState.online ? '✅ Yes' : '❌ No',
            ),
            _StateRow(
              'Is Foreground',
              state.focus == AppFocusState.foreground ? '✅ Yes' : '❌ No',
            ),
            _StateRow('Timestamp', _formatTime(state.timestamp)),
          ],
        );
      },
    );
  }
}

class _DeviceInfoSection extends StatelessWidget {
  final AppStateManager appStateManager;

  const _DeviceInfoSection({required this.appStateManager});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DeviceInfo>(
      stream: appStateManager.deviceStream,
      initialData: appStateManager.deviceInfo,
      builder: (context, snapshot) {
        final device = snapshot.data;

        if (device == null) {
          return const SizedBox.shrink();
        }

        return _Section(
          title: '📱 Device Information',
          children: [
            _StateRow('Device Type', device.type.name),
            _StateRow('OS', device.os.name),
            _StateRow('OS Version', device.osVersion ?? 'N/A'),
            _StateRow('Device Model', device.deviceModel ?? 'N/A'),
            _StateRow(
              'Screen Size',
              '${device.screenWidth.toStringAsFixed(0)}x${device.screenHeight.toStringAsFixed(0)}',
            ),
            _StateRow('Orientation', device.orientation.name),
            _StateRow('Breakpoint', device.breakpoint.name),
            _StateRow('Pixel Ratio', device.pixelRatio.toStringAsFixed(2)),
            _StateRow('Text Scale', device.textScaleFactor.toStringAsFixed(2)),
            _StateRow('Has Notch', device.hasNotch ? '✅' : '❌'),
            _StateRow(
              'Has Notch/Island',
              device.hasNotchOrDynamicIsland ? '✅' : '❌',
            ),
            _StateRow('Is Full Screen', device.isFullScreen ? '✅' : '❌'),
            _StateRow(
              'Status Bar Height',
              '${device.statusBarHeight.toStringAsFixed(1)}px',
            ),
            _StateRow('Is Mobile', device.isMobile ? '✅' : '❌'),
            _StateRow('Is Landscape', device.isLandscape ? '✅' : '❌'),
          ],
        );
      },
    );
  }
}

class _ConnectivitySection extends StatelessWidget {
  final AppStateManager appStateManager;

  const _ConnectivitySection({required this.appStateManager});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppStateInfo>(
      stream: appStateManager.stateStream,
      initialData: appStateManager.currentState,
      builder: (context, snapshot) {
        final state = snapshot.data!;

        return _Section(
          title: '🌐 Connectivity Status',
          children: [
            _StateRow(
              'Status',
              state.connectivity == ConnectivityState.online
                  ? '🟢 Online'
                  : '🔴 Offline',
            ),
            _StateRow(
              'Can Sync',
              state.connectivity == ConnectivityState.online &&
                      state.focus == AppFocusState.foreground
                  ? '✅ Yes (Foreground & Online)'
                  : '❌ No',
            ),
          ],
        );
      },
    );
  }
}

class _KeyboardSection extends StatelessWidget {
  final AppStateManager appStateManager;

  const _KeyboardSection({required this.appStateManager});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<KeyboardInfo>(
      stream: appStateManager.keyboardStream,
      initialData: appStateManager.keyboardInfo,
      builder: (context, snapshot) {
        final keyboard = snapshot.data;

        return _Section(
          title: '⌨️ Keyboard State',
          children: [
            _StateRow(
              'Visible',
              keyboard?.isVisible == true ? '✅ Showing' : '❌ Hidden',
            ),
            _StateRow(
              'Height',
              keyboard != null
                  ? '${keyboard.height.toStringAsFixed(1)}px'
                  : 'N/A',
            ),
            if (keyboard != null)
              _StateRow('Last Update', _formatTime(keyboard.timestamp)),
          ],
        );
      },
    );
  }
}

class _BatterySection extends StatelessWidget {
  final AppStateManager appStateManager;

  const _BatterySection({required this.appStateManager});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BatteryInfo>(
      stream: appStateManager.batteryStream,
      initialData: appStateManager.batteryInfo,
      builder: (context, snapshot) {
        final battery = snapshot.data;

        if (battery == null) {
          return _Section(
            title: '🔋 Battery Status',
            children: [_StateRow('Status', 'Not available on this platform')],
          );
        }

        return _Section(
          title: '🔋 Battery Status',
          onRefresh: () => appStateManager.refreshBattery(),
          children: [
            _StateRow(
              'Level',
              battery.batteryLevel != null
                  ? '${battery.batteryLevel}%'
                  : 'Unknown',
            ),
            _StateRow('State', battery.batteryState.name),
            _StateRow('Charging', battery.isCharging ? '⚡ Yes' : '❌ No'),
            if (battery.chargingSource != null)
              _StateRow('Charging Source', battery.chargingSource!.name.toUpperCase()),
            _StateRow(
              'Power Mode',
              battery.isLowPowerMode ? '🔴 Low Power' : '🟢 Normal',
            ),
            if (battery.health != null) ...[
              _StateRow('Health', battery.health!.name),
              _StateRow('Health Status', battery.healthStatus),
            ],
            if (battery.temperature != null)
              _StateRow('Temperature', '${battery.temperatureCelsius}°C'),
            if (battery.voltage != null)
              _StateRow('Voltage', '${battery.voltageVolts}V'),
            if (battery.technology != null)
              _StateRow('Technology', battery.technology!),
            if (battery.capacity != null)
              _StateRow('Capacity', '${battery.capacity} mAh'),
            if (battery.currentNow != null)
              _StateRow('Current', '${(battery.currentNow! / 1000).toStringAsFixed(1)} mA'),
            if (battery.isLowBattery)
              _StateRow('⚠️ Alert', 'Low battery detected'),
            if (battery.isCriticalBattery)
              _StateRow('🚨 Critical', 'Battery critical!'),
            _StateRow('Timestamp', _formatTime(battery.timestamp)),
          ],
        );
      },
    );
  }
}

class _NetworkSection extends StatelessWidget {
  final AppStateManager appStateManager;

  const _NetworkSection({required this.appStateManager});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<NetworkInfo>(
      stream: appStateManager.networkStream,
      initialData: appStateManager.networkInfo,
      builder: (context, snapshot) {
        final network = snapshot.data;

        if (network == null) {
          return const SizedBox.shrink();
        }

        return _Section(
          title: '📡 Network Type',
          children: [
            _StateRow('Type', network.type.name),
            if (network.isMobile && network.mobileType != null)
              _StateRow('Mobile Type', network.mobileType!.name),
            _StateRow('Online', network.isOnline ? '✅ Yes' : '❌ No'),
            _StateRow(
              'Fast Connection',
              network.isFastConnection ? '⚡ Yes' : '🐢 Slow',
            ),
            _StateRow('WiFi', network.isWifi ? '✅' : '❌'),
            _StateRow('Ethernet', network.isEthernet ? '✅' : '❌'),
            _StateRow('Timestamp', _formatTime(network.timestamp)),
          ],
        );
      },
    );
  }
}

class _AccessibilitySection extends StatelessWidget {
  final AppStateManager appStateManager;

  const _AccessibilitySection({required this.appStateManager});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AccessibilityInfo>(
      stream: appStateManager.accessibilityStream,
      initialData: appStateManager.accessibilityInfo,
      builder: (context, snapshot) {
        final a11y = snapshot.data;

        if (a11y == null) {
          return const SizedBox.shrink();
        }

        return _Section(
          title: '♿ Accessibility Features',
          children: [
            _StateRow('Screen Reader', a11y.isScreenReaderEnabled ? '✅' : '❌'),
            _StateRow('Bold Text', a11y.isBoldTextEnabled ? '✅' : '❌'),
            _StateRow('Reduce Motion', a11y.isReduceMotionEnabled ? '✅' : '❌'),
            _StateRow('High Contrast', a11y.isHighContrastEnabled ? '✅' : '❌'),
            _StateRow('Invert Colors', a11y.isInvertColorsEnabled ? '✅' : '❌'),
            _StateRow(
              'Text Scale',
              '${a11y.textScaleFactor.toStringAsFixed(2)}x',
            ),
            _StateRow(
              'Has Features',
              a11y.hasAccessibilityFeatures ? '✅ Yes' : '❌ No',
            ),
            _StateRow('Timestamp', _formatTime(a11y.timestamp)),
          ],
        );
      },
    );
  }
}

class _MemorySection extends StatelessWidget {
  final AppStateManager appStateManager;

  const _MemorySection({required this.appStateManager});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MemoryInfo>(
      stream: appStateManager.memoryStream,
      initialData: appStateManager.memoryInfo,
      builder: (context, snapshot) {
        final memory = snapshot.data;

        if (memory == null) {
          return const SizedBox.shrink();
        }

        return _Section(
          title: '💾 Memory State',
          onRefresh: () => appStateManager.refreshMemory(),
          children: [
            _StateRow('Level', memory.pressureLevel.name.toUpperCase()),
            _StateRow('Status', memory.memoryStatus),
            if (memory.totalMemory != null)
              _StateRow('Total Memory', memory.totalMemoryGB),
            if (memory.usedMemory != null)
              _StateRow('Used Memory', memory.usedMemoryMB),
            if (memory.freeMemory != null)
              _StateRow('Free Memory', memory.freeMemoryMB),
            if (memory.availableMemory != null)
              _StateRow('Available', memory.availableMemoryMB),
            if (memory.memoryUsagePercentage != null)
              _StateRow(
                'Usage',
                '${memory.memoryUsagePercentage!.toStringAsFixed(1)}%',
              ),
            _StateRow(
              'Should Reduce Usage',
              memory.shouldReduceMemoryUsage ? '⚠️ Yes' : '✅ No',
            ),
            _StateRow(
              'Reduce Usage',
              memory.shouldReduceMemoryUsage ? '✅ Yes' : '❌ No',
            ),
            _StateRow('Timestamp', _formatTime(memory.timestamp)),
          ],
        );
      },
    );
  }
}

class _AuthenticationSection extends StatelessWidget {
  final AppStateManager appStateManager;

  const _AuthenticationSection({required this.appStateManager});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthInfo>(
      stream: appStateManager.authStream,
      initialData: appStateManager.authInfo,
      builder: (context, snapshot) {
        final auth = snapshot.data!;

        return _Section(
          title: '🔐 Authentication',
          children: [
            _StateRow('Status', auth.status.name),
            _StateRow('Authenticated', auth.isAuthenticated ? '✅ Yes' : '❌ No'),
            _StateRow('Valid Session', auth.hasValidSession ? '✅ Yes' : '❌ No'),
            if (auth.lastLoginTime != null)
              _StateRow('Last Login', _formatTime(auth.lastLoginTime!)),
            _StateRow('Has Token', auth.accessToken != null ? '✅' : '❌'),
            _StateRow('Timestamp', _formatTime(auth.timestamp)),
          ],
        );
      },
    );
  }
}

class _PermissionsSection extends StatelessWidget {
  final AppStateManager appStateManager;

  const _PermissionsSection({required this.appStateManager});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PermissionsInfo>(
      stream: appStateManager.permissionsStream,
      initialData: appStateManager.permissionsInfo,
      builder: (context, snapshot) {
        final permissions = snapshot.data!;

        return _Section(
          title: '🔒 Permissions',
          children: [
            _StateRow('Total Permissions', '${permissions.permissions.length}'),
            _StateRow(
              'Granted',
              '${permissions.getGrantedPermissions().length} ✅',
            ),
            _StateRow(
              'Denied',
              '${permissions.getDeniedPermissions().length} ❌',
            ),
            _StateRow(
              'Restricted',
              '${permissions.getRestrictedPermissions().length} ⚠️',
            ),
            _StateRow(
              'Permanently Denied',
              '${permissions.getPermanentlyDeniedPermissions().length} 🚫',
            ),
            if (permissions.permissions.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
                child: Text(
                  'Permission Details:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              ...permissions.permissions.values.map((permission) {
                final statusIcon = _getPermissionStatusIcon(permission.status);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: _StateRow(
                    permission.type.name,
                    '$statusIcon ${permission.status.name}',
                  ),
                );
              }),
            ],
            _StateRow('Timestamp', _formatTime(permissions.lastUpdated)),
          ],
        );
      },
    );
  }

  String _getPermissionStatusIcon(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return '✅';
      case PermissionStatus.denied:
        return '❌';
      case PermissionStatus.restricted:
        return '⚠️';
      case PermissionStatus.permanentlyDenied:
        return '🚫';
      case PermissionStatus.limited:
        return '⚡';
      case PermissionStatus.provisional:
        return '📝';
    }
  }
}

class _DeviceOrientationSection extends StatelessWidget {
  final AppStateManager appStateManager;

  const _DeviceOrientationSection({required this.appStateManager});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DeviceOrientationInfo>(
      stream: appStateManager.deviceOrientationStream,
      initialData: appStateManager.deviceOrientationInfo,
      builder: (context, snapshot) {
        final orientation = snapshot.data!;

        return _Section(
          title: '📱 Device Orientation',
          children: [
            _StateRow('Current', orientation.currentOrientation.name),
            _StateRow('Is Portrait', orientation.isPortrait ? '✅ Yes' : '❌ No'),
            _StateRow(
              'Is Landscape',
              orientation.isLandscape ? '✅ Yes' : '❌ No',
            ),
            _StateRow('Timestamp', _formatTime(orientation.timestamp)),
          ],
        );
      },
    );
  }
}

class _AppVersionSection extends StatelessWidget {
  final AppStateManager appStateManager;

  const _AppVersionSection({required this.appStateManager});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppVersionInfo>(
      stream: appStateManager.appVersionStream,
      initialData: appStateManager.appVersionInfo,
      builder: (context, snapshot) {
        final version = snapshot.data!;

        return _Section(
          title: '📦 App Version',
          children: [
            _StateRow('App Name', version.appName),
            _StateRow('Version', version.version),
            _StateRow('Build Number', version.buildNumber),
            _StateRow('Package Name', version.packageName),
            _StateRow('Timestamp', _formatTime(version.timestamp)),
          ],
        );
      },
    );
  }
}

class _AppRuntimeSection extends StatelessWidget {
  final AppStateManager appStateManager;

  const _AppRuntimeSection({required this.appStateManager});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppRuntimeInfo>(
      stream: appStateManager.appRuntimeStream,
      initialData: appStateManager.appRuntimeInfo,
      builder: (context, snapshot) {
        final runtime = snapshot.data!;

        return _Section(
          title: '⏱️ App Runtime',
          children: [
            _StateRow('Launch Time', _formatTime(runtime.appLaunchTime)),
            _StateRow('Uptime', runtime.uptime),
            _StateRow('Session Starts', '${runtime.sessionStartCount}'),
            _StateRow('Timestamp', _formatTime(runtime.timestamp)),
          ],
        );
      },
    );
  }
}

class _WiFiSection extends StatelessWidget {
  final AppStateManager appStateManager;

  const _WiFiSection({required this.appStateManager});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<WiFiInfo>(
      stream: appStateManager.wifiStream,
      initialData: appStateManager.wifiInfo,
      builder: (context, snapshot) {
        final wifi = snapshot.data!;

        return _Section(
          title: '📶 WiFi',
          onRefresh: () => appStateManager.refreshWiFi(),
          children: [
            _StateRow('Connected', wifi.isConnected ? '✅ Yes' : '❌ No'),
            if (wifi.ssid != null) _StateRow('SSID', wifi.ssid!),
            if (wifi.bssid != null) _StateRow('BSSID', wifi.bssid!),
            if (wifi.ipAddress != null) _StateRow('IP Address', wifi.ipAddress!),
            if (wifi.gateway != null) _StateRow('Gateway', wifi.gateway!),
            if (wifi.subnet != null) _StateRow('Subnet', wifi.subnet!),
            if (wifi.signalStrength != null)
              _StateRow('Signal Strength', '${wifi.signalStrength} dBm'),
            _StateRow('Signal Quality', wifi.signalQuality),
            if (wifi.linkSpeed != null)
              _StateRow('Link Speed', '${wifi.linkSpeed} Mbps'),
            if (wifi.frequency != null) ...[
              _StateRow('Frequency', '${wifi.frequency} MHz'),
              _StateRow('Band', wifi.frequencyBand),
            ],
            if (wifi.securityType != null)
              _StateRow('Security', wifi.securityType!),
            _StateRow('Timestamp', _formatTime(wifi.timestamp)),
          ],
        );
      },
    );
  }
}

class _MobileDataSection extends StatelessWidget {
  final AppStateManager appStateManager;

  const _MobileDataSection({required this.appStateManager});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MobileDataInfo>(
      stream: appStateManager.mobileDataStream,
      initialData: appStateManager.mobileDataInfo,
      builder: (context, snapshot) {
        final mobileData = snapshot.data!;

        return _Section(
          title: '📱 Mobile Data',
          onRefresh: () => appStateManager.refreshMobileData(),
          children: [
            _StateRow('Connected', mobileData.isConnected ? '✅ Yes' : '❌ No'),
            _StateRow('Data Type', mobileData.dataTypeDisplay),
            _StateRow('Signal Strength', '${mobileData.signalStrength} dBm'),
            _StateRow('Signal Quality', mobileData.signalQuality),
            _StateRow('Signal Percentage', '${mobileData.signalPercentage}%'),
            if (mobileData.operatorName != null)
              _StateRow('Operator', mobileData.operatorName!),
            if (mobileData.isoCountryCode != null)
              _StateRow('Country Code', mobileData.isoCountryCode!),
            if (mobileData.mobileNetworkCode != null)
              _StateRow('Network Code', mobileData.mobileNetworkCode!),
            if (mobileData.mobileCountryCode != null)
              _StateRow('Country Code (MCC)', mobileData.mobileCountryCode!),
            _StateRow('Timestamp', _formatTime(mobileData.timestamp)),
          ],
        );
      },
    );
  }
}

class _VpnSection extends StatelessWidget {
  final AppStateManager appStateManager;

  const _VpnSection({required this.appStateManager});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<VpnInfo>(
      stream: appStateManager.vpnStream,
      initialData: appStateManager.vpnInfo,
      builder: (context, snapshot) {
        final vpn = snapshot.data!;

        return _Section(
          title: '🔐 VPN',
          children: [
            _StateRow('Connected', vpn.isConnected ? '✅ Yes' : '❌ No'),
            if (vpn.vpnName != null) _StateRow('VPN Name', vpn.vpnName!),
            _StateRow('Timestamp', _formatTime(vpn.timestamp)),
          ],
        );
      },
    );
  }
}

class _StorageSection extends StatelessWidget {
  final AppStateManager appStateManager;

  const _StorageSection({required this.appStateManager});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StorageInfo>(
      stream: appStateManager.storageStream,
      initialData: appStateManager.storageInfo,
      builder: (context, snapshot) {
        final storage = snapshot.data!;

        return _Section(
          title: '� Storage',
          children: [
            _StateRow('Total Space', storage.totalSpaceGB),
            _StateRow('Used Space', storage.usedSpaceGB),
            _StateRow('Free Space', storage.freeSpaceGB),
            _StateRow(
              'Usage',
              storage.totalSpace > 0
                  ? '${storage.usagePercentage.toStringAsFixed(1)}%'
                  : 'Not available',
            ),
            if (storage.usagePercentage >= 90)
              _StateRow('⚠️ Alert', 'Low storage space!'),
            _StateRow('Timestamp', _formatTime(storage.timestamp)),
          ],
        );
      },
    );
  }
}

class _ScreenMetricsSection extends StatelessWidget {
  final AppStateManager appStateManager;

  const _ScreenMetricsSection({required this.appStateManager});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ScreenMetricsInfo>(
      stream: appStateManager.screenMetricsStream,
      initialData: appStateManager.screenMetricsInfo,
      builder: (context, snapshot) {
        final metrics = snapshot.data!;

        return _Section(
          title: '📐 Screen Metrics',
          children: [
            _StateRow('Pixel Ratio', metrics.pixelRatio.toStringAsFixed(2)),
            _StateRow('DPI', metrics.dpi.toStringAsFixed(1)),
            _StateRow('Has Notch', metrics.hasNotch ? '✅ Yes' : '❌ No'),
            _StateRow(
              'Safe Area Top',
              '${metrics.totalSafeAreaTop.toStringAsFixed(1)}px',
            ),
            _StateRow(
              'Safe Area Bottom',
              '${metrics.totalSafeAreaBottom.toStringAsFixed(1)}px',
            ),
            _StateRow(
              'View Inset Top',
              '${metrics.viewInsetTop.toStringAsFixed(1)}px',
            ),
            _StateRow(
              'View Inset Bottom',
              '${metrics.viewInsetBottom.toStringAsFixed(1)}px',
            ),
            _StateRow('Timestamp', _formatTime(metrics.timestamp)),
          ],
        );
      },
    );
  }
}

class _SystemSettingsSection extends StatelessWidget {
  final AppStateManager appStateManager;

  const _SystemSettingsSection({required this.appStateManager});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SystemSettingsInfo>(
      stream: appStateManager.systemSettingsStream,
      initialData: appStateManager.systemSettingsInfo,
      builder: (context, snapshot) {
        final settings = snapshot.data!;

        return _Section(
          title: '⚙️ System Settings',
          children: [
            _StateRow(
              'Low Power Mode',
              settings.isLowPowerMode ? '✅ On' : '❌ Off',
            ),
            _StateRow(
              'Airplane Mode',
              settings.isAirplaneMode ? '✅ On' : '❌ Off',
            ),
            _StateRow(
              'Dark Mode',
              settings.isDarkModeEnabled ? '🌙 On' : '☀️ Off',
            ),
            _StateRow('Timestamp', _formatTime(settings.timestamp)),
          ],
        );
      },
    );
  }
}

class _AudioStateSection extends StatelessWidget {
  final AppStateManager appStateManager;

  const _AudioStateSection({required this.appStateManager});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AudioStateInfo>(
      stream: appStateManager.audioStateStream,
      initialData: appStateManager.audioStateInfo,
      builder: (context, snapshot) {
        final audio = snapshot.data!;

        return _Section(
          title: '🔊 Audio State',
          onRefresh: () => appStateManager.refreshAudio(),
          children: [
            _StateRow(
              'Volume Level',
              '${audio.volumeLevel}/${audio.maxVolume}',
            ),
            _StateRow(
              'Volume',
              '${audio.volumePercentage.toStringAsFixed(0)}%',
            ),
            _StateRow(
              'Volume Bar',
              '${"█" * (audio.volumeLevel)}${"░" * (audio.maxVolume - audio.volumeLevel)}',
            ),
            _StateRow('Output Type', audio.outputType.name.toUpperCase()),
            _StateRow('Muted', audio.isMuted ? '🔇 Yes' : '🔊 No'),
            if (audio.volumePercentage > 80)
              _StateRow('⚠️ Notice', 'High volume may damage hearing'),
            _StateRow('Timestamp', _formatTime(audio.timestamp)),
          ],
        );
      },
    );
  }
}

class _ThemeSection extends StatelessWidget {
  final AppStateManager appStateManager;

  const _ThemeSection({required this.appStateManager});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ThemeMode>(
      stream: appStateManager.themeStream,
      initialData: appStateManager.themeMode,
      builder: (context, snapshot) {
        final theme = snapshot.data!;

        return _Section(
          title: '🎨 Theme',
          children: [
            _StateRow(
              'Mode',
              theme == ThemeMode.dark
                  ? '🌙 Dark'
                  : theme == ThemeMode.light
                  ? '☀️ Light'
                  : '⚙️ System',
            ),
          ],
        );
      },
    );
  }
}

class _LocaleSection extends StatelessWidget {
  final AppStateManager appStateManager;

  const _LocaleSection({required this.appStateManager});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LocaleInfo>(
      stream: appStateManager.localeStream,
      initialData: appStateManager.localeInfo,
      builder: (context, snapshot) {
        final locale = snapshot.data!;

        return _Section(
          title: '🌍 Locale',
          children: [
            _StateRow('Current', locale.currentLocale.languageCode),
            _StateRow('Device', locale.deviceLocale?.languageCode ?? 'N/A'),
            _StateRow('Direction', locale.textDirection.name),
            _StateRow('RTL', locale.isRTL ? '✅ Yes' : '❌ No'),
            _StateRow('Timestamp', _formatTime(locale.timestamp)),
          ],
        );
      },
    );
  }
}

class _NavigationSection extends StatelessWidget {
  final AppStateManager appStateManager;

  const _NavigationSection({required this.appStateManager});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<NavigationState>(
      stream: appStateManager.navigationStream,
      initialData: appStateManager.navigationState,
      builder: (context, snapshot) {
        final nav = snapshot.data!;

        return _Section(
          title: '🗺️ Navigation',
          children: [
            _StateRow('Current Route', nav.currentRoute),
            _StateRow('Current Tab', nav.currentTabIndex.toString()),
            _StateRow('History Length', nav.routeHistory.length.toString()),
            if (nav.routeHistory.isNotEmpty)
              _StateRow('Routes', nav.routeHistory.join(' → ')),
            _StateRow('Timestamp', _formatTime(nav.timestamp)),
          ],
        );
      },
    );
  }
}

class _FullStateSection extends StatelessWidget {
  final AppStateManager appStateManager;

  const _FullStateSection({required this.appStateManager});

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: '📋 Full State Snapshot',
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _buildStateSnapshot(appStateManager),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _buildStateSnapshot(AppStateManager manager) {
    final buffer = StringBuffer();
    buffer.writeln('═══════════════════════════════════════════════════');
    buffer.writeln('APP STATE SNAPSHOT');
    buffer.writeln('═══════════════════════════════════════════════════');

    final state = manager.currentState;
    buffer.writeln('Lifecycle: ${state.lifecycle.name}');

    final device = manager.deviceInfo;
    buffer.writeln('\n[DEVICE]');
    buffer.writeln('  Model: ${device?.deviceModel}');
    buffer.writeln('  OS: ${device?.osVersion}');
    buffer.writeln(
      '  Screen: ${device?.screenSize.width.toStringAsFixed(0)} × ${device?.screenSize.height.toStringAsFixed(0)}',
    );

    final battery = manager.batteryInfo;
    buffer.writeln('\n[BATTERY]');
    buffer.writeln('  Level: ${battery?.batteryLevel}%');
    buffer.writeln('  State: ${battery?.batteryState.name}');

    final network = manager.networkInfo;
    buffer.writeln('\n[NETWORK]');
    buffer.writeln('  Online: ${network?.isOnline}');
    buffer.writeln('  Type: ${network?.type.name}');

    final keyboard = manager.keyboardInfo;
    buffer.writeln('\n[KEYBOARD]');
    buffer.writeln('  Visible: ${keyboard?.isVisible}');
    buffer.writeln('  Height: ${keyboard?.height.toStringAsFixed(0)}px');

    final memory = manager.memoryInfo;
    buffer.writeln('\n[MEMORY]');
    buffer.writeln('  Level: ${memory?.pressureLevel.name}');

    final a11y = manager.accessibilityInfo;
    buffer.writeln('\n[ACCESSIBILITY]');
    buffer.writeln('  Screen Reader: ${a11y?.isScreenReaderEnabled}');
    buffer.writeln('  Bold Text: ${a11y?.isBoldTextEnabled}');

    final permissions = manager.permissionsInfo;
    buffer.writeln('\n[PERMISSIONS]');
    buffer.writeln('  Granted: ${permissions.getGrantedPermissions().length}');
    buffer.writeln('  Denied: ${permissions.getDeniedPermissions().length}');
    buffer.writeln(
      '  Restricted: ${permissions.getRestrictedPermissions().length}',
    );

    final orientation = manager.deviceOrientationInfo;
    buffer.writeln('\n[ORIENTATION]');
    buffer.writeln('  Current: ${orientation.currentOrientation.name}');
    buffer.writeln('  Portrait: ${orientation.isPortrait}');

    final version = manager.appVersionInfo;
    buffer.writeln('\n[APP VERSION]');
    buffer.writeln('  Version: ${version.version}');
    buffer.writeln('  Build: ${version.buildNumber}');

    final runtime = manager.appRuntimeInfo;
    buffer.writeln('\n[RUNTIME]');
    buffer.writeln('  Uptime: ${runtime.uptime}');
    buffer.writeln('  Sessions: ${runtime.sessionStartCount}');

    final wifi = manager.wifiInfo;
    buffer.writeln('\n[WIFI]');
    buffer.writeln('  Connected: ${wifi.isConnected}');
    if (wifi.ssid != null) buffer.writeln('  SSID: ${wifi.ssid}');

    final vpn = manager.vpnInfo;
    buffer.writeln('\n[VPN]');
    buffer.writeln('  Connected: ${vpn.isConnected}');

    final storage = manager.storageInfo;
    buffer.writeln('\n[STORAGE]');
    buffer.writeln('  Free: ${storage.freeSpaceGB}');
    buffer.writeln('  Usage: ${storage.usagePercentage.toStringAsFixed(1)}%');

    final metrics = manager.screenMetricsInfo;
    buffer.writeln('\n[SCREEN METRICS]');
    buffer.writeln('  Pixel Ratio: ${metrics.pixelRatio}');
    buffer.writeln('  Has Notch: ${metrics.hasNotch}');

    final settings = manager.systemSettingsInfo;
    buffer.writeln('\n[SYSTEM SETTINGS]');
    buffer.writeln('  Low Power: ${settings.isLowPowerMode}');
    buffer.writeln('  Dark Mode: ${settings.isDarkModeEnabled}');

    final audio = manager.audioStateInfo;
    buffer.writeln('\n[AUDIO]');
    buffer.writeln('  Volume: ${audio.volumePercentage.toStringAsFixed(0)}%');
    buffer.writeln('  Output: ${audio.outputType.name}');

    return buffer.toString();
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback? onRefresh;

  const _Section({
    required this.title,
    required this.children,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (onRefresh != null)
              IconButton(
                icon: const Icon(Icons.refresh, size: 18),
                onPressed: onRefresh,
                tooltip: 'Refresh',
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
              ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _StateRow extends StatelessWidget {
  final String label;
  final String value;

  const _StateRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: Colors.blue.shade600,
                fontFamily: 'monospace',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatTime(DateTime time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
}
