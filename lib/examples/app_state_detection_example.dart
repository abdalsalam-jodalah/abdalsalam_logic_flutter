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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App State Detection Demo')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _AppLifecycleSection(appStateManager: widget.appStateManager),
            _DeviceInfoSection(appStateManager: widget.appStateManager),
            _ConnectivitySection(appStateManager: widget.appStateManager),
            _KeyboardSection(appStateManager: widget.appStateManager),
            _BatterySection(appStateManager: widget.appStateManager),
            _NetworkSection(appStateManager: widget.appStateManager),
            _AccessibilitySection(appStateManager: widget.appStateManager),
            _MemorySection(appStateManager: widget.appStateManager),
            _AuthenticationSection(appStateManager: widget.appStateManager),
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
          children: [
            _StateRow(
              'Level',
              battery.batteryLevel != null
                  ? '${battery.batteryLevel}%'
                  : 'Unknown',
            ),
            _StateRow('State', battery.batteryState.name),
            _StateRow('Charging', battery.isCharging ? '⚡ Yes' : '❌ No'),
            _StateRow(
              'Power Mode',
              battery.isLowPowerMode ? '🔴 Low Power' : '🟢 Normal',
            ),
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
          title: '💾 Memory Pressure',
          children: [
            _StateRow('Level', memory.pressureLevel.name.toUpperCase()),
            _StateRow(
              'Status',
              memory.isCritical
                  ? '🔴 Critical'
                  : memory.isWarning
                  ? '🟠 Warning'
                  : '🟢 Normal',
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
    buffer.writeln('  Screen: ${device?.screenSize.width.toStringAsFixed(0)} × ${device?.screenSize.height.toStringAsFixed(0)}');
    
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
    
    return buffer.toString();
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
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
