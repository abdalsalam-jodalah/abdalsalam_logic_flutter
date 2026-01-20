// lib/examples/runtime_control_comprehensive_ui.dart

import 'dart:async';
import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  AppControl.initialize(config: const RuntimeConfig.development());
  
  AppControl.registerDomains([
    LoggingDomain(),
    StorageDomain(),
    NetworkingDomain(),
    AuthDomain(),
    AppStateDomain(),
    CacheDomain(),
    SyncDomain(),
  ]);
  
  await AppControl.start();
  
  runApp(const RuntimeControlDemoApp());
}

class RuntimeControlDemoApp extends StatelessWidget {
  const RuntimeControlDemoApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Runtime Control Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const RuntimeControlHomePage(),
    );
  }
}

class RuntimeControlHomePage extends StatefulWidget {
  const RuntimeControlHomePage({super.key});
  
  @override
  State<RuntimeControlHomePage> createState() => _RuntimeControlHomePageState();
}

class _RuntimeControlHomePageState extends State<RuntimeControlHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _eventLog = [];
  final ScrollController _logScrollController = ScrollController();
  StreamSubscription<RuntimeEvent>? _runtimeEventSub;
  StreamSubscription<StateEvent>? _stateEventSub;
  StreamSubscription<UITreeEvent>? _uiEventSub;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _listenToEvents();
  }
  
  void _listenToEvents() {
    _runtimeEventSub = AppControl.eventStream.listen((event) {
      setState(() {
        _eventLog.insert(0, '[${_formatTime(event.timestamp)}] Runtime: ${event.type.name}');
        if (_eventLog.length > 100) _eventLog.removeLast();
      });
      _scrollToTop();
    });
    
    _stateEventSub = AppControl.stateController.eventStream.listen((event) {
      setState(() {
        _eventLog.insert(0, '[${_formatTime(event.timestamp)}] State: ${event.type.name} ${event.domainId ?? ""}');
        if (_eventLog.length > 100) _eventLog.removeLast();
      });
      _scrollToTop();
    });
    
    _uiEventSub = AppControl.uiController.eventStream.listen((event) {
      setState(() {
        _eventLog.insert(0, '[${_formatTime(event.timestamp)}] UI: ${event.type.name} ${event.treeId ?? ""}');
        if (_eventLog.length > 100) _eventLog.removeLast();
      });
      _scrollToTop();
    });
  }
  
  void _scrollToTop() {
    if (_logScrollController.hasClients) {
      _logScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}.${time.millisecond.toString().padLeft(3, '0')}';
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _runtimeEventSub?.cancel();
    _stateEventSub?.cancel();
    _uiEventSub?.cancel();
    _logScrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Runtime Control - Complete Demo'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.control_camera), text: 'Controls'),
            Tab(icon: Icon(Icons.account_tree), text: 'Domains'),
            Tab(icon: Icon(Icons.event_note), text: 'Events'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(),
          _buildControlsTab(),
          _buildDomainsTab(),
          _buildEventsTab(context),
          _buildSettingsTab(),
        ],
      ),
    );
  }
  
  Widget _buildDashboardTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildRuntimeStatusCard(),
        const SizedBox(height: 16),
        _buildQuickStatsCard(),
        const SizedBox(height: 16),
        _buildPhaseTimelineCard(),
        const SizedBox(height: 16),
        _buildQuickActionsCard(),
      ],
    );
  }
  
  Widget _buildRuntimeStatusCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, size: 28, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                const Text(
                  'Runtime Status',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 32),
            StreamBuilder<LifecyclePhase>(
              stream: AppControl.phaseStream,
              initialData: AppControl.currentPhase,
              builder: (context, snapshot) {
                final phase = snapshot.data ?? LifecyclePhase.uninitialized;
                return Column(
                  children: [
                    _buildStatusRow(
                      'Current Phase',
                      phase.name,
                      _getPhaseIcon(phase),
                      _getPhaseColor(phase),
                    ),
                    const SizedBox(height: 12),
                    _buildStatusRow(
                      'Running',
                      AppControl.isRunning ? 'Active' : 'Inactive',
                      AppControl.isRunning ? Icons.check_circle : Icons.cancel,
                      AppControl.isRunning ? Colors.green : Colors.red,
                    ),
                    const SizedBox(height: 12),
                    _buildStatusRow(
                      'Initialized',
                      AppControl.isInitialized ? 'Yes' : 'No',
                      AppControl.isInitialized ? Icons.verified : Icons.warning,
                      AppControl.isInitialized ? Colors.green : Colors.orange,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusRow(String label, String value, IconData icon, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color, width: 1.5),
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildQuickStatsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Stats',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Domains',
                  '${AppControl.registry.domainCount}',
                  Icons.account_tree,
                  Colors.blue,
                ),
                _buildStatItem(
                  'Initialized',
                  '${AppControl.registry.initializedCount}',
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatItem(
                  'Events',
                  '${_eventLog.length}',
                  Icons.event,
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 40, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
  
  Widget _buildPhaseTimelineCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lifecycle Phases',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            StreamBuilder<LifecyclePhase>(
              stream: AppControl.phaseStream,
              initialData: AppControl.currentPhase,
              builder: (context, snapshot) {
                final currentPhase = snapshot.data ?? LifecyclePhase.uninitialized;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: LifecyclePhase.values.map((phase) {
                    final isCurrent = phase == currentPhase;
                    return Chip(
                      avatar: Icon(
                        isCurrent ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        size: 18,
                      ),
                      label: Text(phase.name),
                      backgroundColor: isCurrent ? _getPhaseColor(phase) : null,
                      labelStyle: TextStyle(
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickActionsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildActionButton(
                  'Refresh UI',
                  Icons.refresh,
                  Colors.blue,
                  () => _executeAction('Refresh UI', AppControl.refreshUI),
                ),
                _buildActionButton(
                  'Soft Reset',
                  Icons.refresh_outlined,
                  Colors.green,
                  () => _executeAction('Soft Reset', AppControl.refreshApp),
                ),
                _buildActionButton(
                  'Hard Reset',
                  Icons.restore_page,
                  Colors.orange,
                  () => _executeAction('Hard Reset', () => AppControl.resetStates(ResetLevel.hard)),
                ),
                _buildActionButton(
                  'Restart',
                  Icons.restart_alt,
                  Colors.red,
                  () => _executeAction('Restart', AppControl.restart),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
  
  Widget _buildControlsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildResetLevelsCard(),
        const SizedBox(height: 16),
        _buildLifecycleControlsCard(),
        const SizedBox(height: 16),
        _buildUIControlsCard(),
        const SizedBox(height: 16),
        _buildDomainControlsCard(),
      ],
    );
  }
  
  Widget _buildResetLevelsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.layers, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                const Text(
                  'Reset Levels',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...ResetLevel.values.map((level) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildResetLevelTile(level),
            )),
          ],
        ),
      ),
    );
  }
  
  Widget _buildResetLevelTile(ResetLevel level) {
    return ListTile(
      leading: Icon(_getResetLevelIcon(level), color: _getResetLevelColor(level)),
      title: Text(
        level.name.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        level.description,
        style: const TextStyle(fontSize: 12),
      ),
      trailing: ElevatedButton(
        onPressed: () => _executeAction(
          'Reset ${level.name}',
          () => AppControl.resetStates(level),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _getResetLevelColor(level),
          foregroundColor: Colors.white,
        ),
        child: const Text('Execute'),
      ),
    );
  }
  
  Widget _buildLifecycleControlsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                const Text(
                  'Lifecycle Controls',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildControlTile(
              'Start Runtime',
              'Initialize and start the runtime',
              Icons.play_arrow,
              Colors.green,
              () => _executeAction('Start', AppControl.start),
            ),
            _buildControlTile(
              'Restart Runtime',
              'Complete restart with full disposal',
              Icons.restart_alt,
              Colors.orange,
              () => _executeAction('Restart', AppControl.restart),
            ),
            _buildControlTile(
              'Reset Runtime',
              'Reset execution without killing process',
              Icons.settings_backup_restore,
              Colors.red,
              () => _executeAction('Reset Runtime', AppControl.resetRuntime),
            ),
            _buildControlTile(
              'Stop Runtime',
              'Clean shutdown and disposal',
              Icons.stop,
              Colors.grey,
              () => _executeAction('Stop', AppControl.stop),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUIControlsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.desktop_windows, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                const Text(
                  'UI Tree Controls',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildControlTile(
              'Refresh UI',
              'Trigger UI rebuild callbacks',
              Icons.refresh,
              Colors.blue,
              () => _executeAction('Refresh UI', AppControl.refreshUI),
            ),
            _buildControlTile(
              'Rebuild All Trees',
              'Rebuild all registered widget trees',
              Icons.account_tree,
              Colors.indigo,
              () => _executeAction('Rebuild All Trees', AppControl.refreshAllTrees),
            ),
            _buildControlTile(
              'Recreate All Trees',
              'Force recreation with new keys',
              Icons.auto_fix_high,
              Colors.purple,
              () => _executeAction('Recreate Trees', AppControl.uiController.recreateAllTrees),
            ),
            _buildControlTile(
              'Clear Cached State',
              'Clear cached render state',
              Icons.clear_all,
              Colors.teal,
              () => _executeAction('Clear Cache', AppControl.uiController.clearCachedRenderState),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDomainControlsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.dns, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                const Text(
                  'Domain Controls',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildControlTile(
              'Initialize All Domains',
              'Initialize all registered domains',
              Icons.play_circle,
              Colors.green,
              () => _executeAction('Init All', AppControl.stateController.initializeAll),
            ),
            _buildControlTile(
              'Reinitialize All',
              'Reset and reinitialize all domains',
              Icons.replay,
              Colors.orange,
              () => _executeAction('Reinit All', AppControl.stateController.reinitializeAll),
            ),
            _buildControlTile(
              'Dispose All Domains',
              'Dispose all domains and clear registry',
              Icons.delete_sweep,
              Colors.red,
              () => _executeAction('Dispose All', AppControl.stateController.disposeAll),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildControlTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: onPressed,
          color: color,
        ),
      ),
    );
  }
  
  Widget _buildDomainsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDomainListCard(),
        const SizedBox(height: 16),
        _buildDomainDependencyCard(),
      ],
    );
  }
  
  Widget _buildDomainListCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Registered Domains',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text('${AppControl.registry.domainCount} total'),
                  backgroundColor: Colors.blue.shade100,
                ),
              ],
            ),
            const Divider(height: 32),
            ...AppControl.registry.getInitializationOrder().map((domain) {
              final initialized = AppControl.registry.isInitialized(domain.domainId);
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: initialized ? Colors.green.shade50 : Colors.grey.shade50,
                child: ExpansionTile(
                  leading: Icon(
                    initialized ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: initialized ? Colors.green : Colors.grey,
                    size: 28,
                  ),
                  title: Text(
                    domain.domainName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('ID: ${domain.domainId}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDomainInfoRow('Priority', '${domain.initializationPriority}'),
                          _buildDomainInfoRow('Initialized', initialized ? 'Yes' : 'No'),
                          _buildDomainInfoRow('Can Reset', domain.canReset ? 'Yes' : 'No'),
                          _buildDomainInfoRow('Dependencies', domain.dependencies.isEmpty ? 'None' : domain.dependencies.join(', ')),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: [
                              ElevatedButton.icon(
                                onPressed: initialized ? null : () => _executeAction(
                                  'Init ${domain.domainId}',
                                  () => AppControl.stateController.initializeDomain(domain.domainId),
                                ),
                                icon: const Icon(Icons.play_arrow, size: 16),
                                label: const Text('Initialize'),
                              ),
                              ElevatedButton.icon(
                                onPressed: domain.canReset ? () => _executeAction(
                                  'Reset ${domain.domainId}',
                                  () => AppControl.stateController.resetDomain(domain.domainId, ResetLevel.hard),
                                ) : null,
                                icon: const Icon(Icons.refresh, size: 16),
                                label: const Text('Reset'),
                              ),
                              ElevatedButton.icon(
                                onPressed: initialized ? () => _executeAction(
                                  'Dispose ${domain.domainId}',
                                  () => AppControl.stateController.disposeDomain(domain.domainId),
                                ) : null,
                                icon: const Icon(Icons.delete, size: 16),
                                label: const Text('Dispose'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDomainInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDomainDependencyCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Initialization Order',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Domains are initialized in dependency-resolved order:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ...AppControl.registry.getInitializationOrder().asMap().entries.map((entry) {
              final index = entry.key;
              final domain = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.blue,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        domain.domainName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (domain.dependencies.isNotEmpty)
                      Chip(
                        label: Text('Deps: ${domain.dependencies.length}'),
                        backgroundColor: Colors.orange.shade100,
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEventsTab(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.event_note, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 12),
                  Text(
                    'Event Log (${_eventLog.length})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.clear_all),
                    onPressed: () => setState(() => _eventLog.clear()),
                    tooltip: 'Clear log',
                  ),
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: _exportLog,
                    tooltip: 'Export log',
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _eventLog.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No events yet',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Perform actions to see events here',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _logScrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: _eventLog.length,
                  itemBuilder: (context, index) {
                    final event = _eventLog[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 4),
                      child: ListTile(
                        dense: true,
                        leading: _getEventIcon(event),
                        title: Text(
                          event,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
  
  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildConfigurationCard(),
        const SizedBox(height: 16),
        _buildDebugControlsCard(),
        const SizedBox(height: 16),
        _buildAboutCard(),
      ],
    );
  }
  
  Widget _buildConfigurationCard() {
    final config = AppControl.config;
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Runtime Configuration',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 32),
            _buildConfigRow('Debug Mode', config.enableDebugMode),
            _buildConfigRow('Strict Validation', config.enableStrictValidation),
            _buildConfigRow('Runtime Reset', config.allowRuntimeReset),
            _buildConfigRow('Track Events', config.trackLifecycleEvents),
            _buildConfigRow('Enforce Registration', config.enforceRegistration),
            _buildConfigRow('Prevent Unregistered State', config.preventUnregisteredState),
            _buildConfigRow('Recovery Mode', config.enableRecoveryMode),
            const SizedBox(height: 16),
            _buildConfigTextRow('Default Reset Level', config.defaultResetLevel.name),
            _buildConfigTextRow('Init Timeout', '${config.initializationTimeout.inSeconds}s'),
            _buildConfigTextRow('Shutdown Timeout', '${config.shutdownTimeout.inSeconds}s'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildConfigRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: value ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }
  
  Widget _buildConfigTextRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
  
  Widget _buildDebugControlsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Debug Controls',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('Force Error State'),
              subtitle: const Text('Trigger error phase for testing'),
              trailing: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error simulation not implemented')),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Trigger'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.memory),
              title: const Text('Memory Stats'),
              subtitle: Text('Domains: ${AppControl.registry.domainCount}, Events: ${_eventLog.length}'),
            ),
            ListTile(
              leading: const Icon(Icons.speed),
              title: const Text('Performance'),
              subtitle: const Text('Monitor runtime performance metrics'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAboutCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Runtime Control System v1.0.0'),
            const SizedBox(height: 8),
            const Text(
              'A comprehensive app control runtime that provides full lifecycle authority over Flutter applications.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text('Features:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...[
              'Complete lifecycle management',
              'Graduated reset levels',
              'Domain registration & dependency resolution',
              'UI tree control',
              'Event streaming',
              'Configurable behavior',
            ].map((feature) => Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.check, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(feature),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
  
  Future<void> _executeAction(String actionName, Future<void> Function() action) async {
    try {
      await action();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ $actionName completed successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ $actionName failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
  
  void _exportLog() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exported ${_eventLog.length} events'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {},
        ),
      ),
    );
  }
  
  IconData _getPhaseIcon(LifecyclePhase phase) {
    switch (phase) {
      case LifecyclePhase.uninitialized:
        return Icons.radio_button_unchecked;
      case LifecyclePhase.initializing:
        return Icons.hourglass_empty;
      case LifecyclePhase.initialized:
        return Icons.check_circle_outline;
      case LifecyclePhase.running:
        return Icons.play_circle;
      case LifecyclePhase.paused:
        return Icons.pause_circle;
      case LifecyclePhase.refreshing:
        return Icons.refresh;
      case LifecyclePhase.restarting:
        return Icons.restart_alt;
      case LifecyclePhase.resetting:
        return Icons.settings_backup_restore;
      case LifecyclePhase.disposing:
        return Icons.delete;
      case LifecyclePhase.disposed:
        return Icons.cancel;
      case LifecyclePhase.error:
        return Icons.error;
    }
  }
  
  Color _getPhaseColor(LifecyclePhase phase) {
    if (phase.isActive) return Colors.green.shade100;
    if (phase.isTransitioning) return Colors.orange.shade100;
    if (phase.isTerminal) return Colors.red.shade100;
    return Colors.grey.shade100;
  }
  
  IconData _getResetLevelIcon(ResetLevel level) {
    switch (level) {
      case ResetLevel.uiOnly:
        return Icons.refresh;
      case ResetLevel.soft:
        return Icons.refresh_outlined;
      case ResetLevel.medium:
        return Icons.restore;
      case ResetLevel.hard:
        return Icons.restore_page;
      case ResetLevel.complete:
        return Icons.settings_backup_restore;
    }
  }
  
  Color _getResetLevelColor(ResetLevel level) {
    switch (level) {
      case ResetLevel.uiOnly:
        return Colors.blue;
      case ResetLevel.soft:
        return Colors.green;
      case ResetLevel.medium:
        return Colors.orange;
      case ResetLevel.hard:
        return Colors.red;
      case ResetLevel.complete:
        return Colors.purple;
    }
  }
  
  Widget _getEventIcon(String event) {
    if (event.contains('Runtime')) {
      return const Icon(Icons.settings, size: 20, color: Colors.blue);
    } else if (event.contains('State')) {
      return const Icon(Icons.data_object, size: 20, color: Colors.green);
    } else if (event.contains('UI')) {
      return const Icon(Icons.desktop_windows, size: 20, color: Colors.orange);
    }
    return const Icon(Icons.circle, size: 20, color: Colors.grey);
  }
}

class LoggingDomain implements RuntimeDomain, RuntimeDomainMetadata {
  bool _initialized = false;
  
  @override
  String get domainId => 'logging';
  
  @override
  String get domainName => 'Logging System';
  
  @override
  int get initializationPriority => 100;
  
  @override
  List<String> get dependencies => [];
  
  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 50));
    _initialized = true;
  }
  
  @override
  Future<void> reset(ResetLevel level) async {}
  
  @override
  Future<void> dispose() async {
    _initialized = false;
  }
  
  @override
  bool get isInitialized => _initialized;
  
  @override
  bool get canReset => false;
  
  @override
  String get category => 'core';
  
  @override
  bool get isCore => true;
  
  @override
  bool get isPersistent => false;
  
  @override
  bool get isOptional => false;
}

class StorageDomain implements RuntimeDomain, RuntimeDomainMetadata {
  bool _initialized = false;
  
  @override
  String get domainId => 'storage';
  
  @override
  String get domainName => 'Storage System';
  
  @override
  int get initializationPriority => 95;
  
  @override
  List<String> get dependencies => [];
  
  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _initialized = true;
  }
  
  @override
  Future<void> reset(ResetLevel level) async {
    if (level.shouldResetPersistentState) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }
  
  @override
  Future<void> dispose() async {
    _initialized = false;
  }
  
  @override
  bool get isInitialized => _initialized;
  
  @override
  bool get canReset => true;
  
  @override
  String get category => 'storage';
  
  @override
  bool get isCore => true;
  
  @override
  bool get isPersistent => true;
  
  @override
  bool get isOptional => false;
}

class NetworkingDomain implements RuntimeDomain, RuntimeDomainMetadata {
  bool _initialized = false;
  
  @override
  String get domainId => 'networking';
  
  @override
  String get domainName => 'Networking & API';
  
  @override
  int get initializationPriority => 85;
  
  @override
  List<String> get dependencies => ['storage'];
  
  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 80));
    _initialized = true;
  }
  
  @override
  Future<void> reset(ResetLevel level) async {
    if (level.shouldResetTransientState) {
      await Future.delayed(const Duration(milliseconds: 30));
    }
  }
  
  @override
  Future<void> dispose() async {
    _initialized = false;
  }
  
  @override
  bool get isInitialized => _initialized;
  
  @override
  bool get canReset => true;
  
  @override
  String get category => 'networking';
  
  @override
  bool get isCore => true;
  
  @override
  bool get isPersistent => false;
  
  @override
  bool get isOptional => false;
}

class AuthDomain implements RuntimeDomain, RuntimeDomainMetadata {
  bool _initialized = false;
  
  @override
  String get domainId => 'auth';
  
  @override
  String get domainName => 'Authentication';
  
  @override
  int get initializationPriority => 80;
  
  @override
  List<String> get dependencies => ['storage', 'networking'];
  
  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 120));
    _initialized = true;
  }
  
  @override
  Future<void> reset(ResetLevel level) async {
    if (level.shouldResetPersistentState) {
      await Future.delayed(const Duration(milliseconds: 40));
    }
  }
  
  @override
  Future<void> dispose() async {
    _initialized = false;
  }
  
  @override
  bool get isInitialized => _initialized;
  
  @override
  bool get canReset => true;
  
  @override
  String get category => 'authentication';
  
  @override
  bool get isCore => true;
  
  @override
  bool get isPersistent => true;
  
  @override
  bool get isOptional => false;
}

class AppStateDomain implements RuntimeDomain, RuntimeDomainMetadata {
  bool _initialized = false;
  
  @override
  String get domainId => 'app_state';
  
  @override
  String get domainName => 'App State Manager';
  
  @override
  int get initializationPriority => 90;
  
  @override
  List<String> get dependencies => [];
  
  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 70));
    _initialized = true;
  }
  
  @override
  Future<void> reset(ResetLevel level) async {
    if (level.shouldResetTransientState) {
      await Future.delayed(const Duration(milliseconds: 20));
    }
  }
  
  @override
  Future<void> dispose() async {
    _initialized = false;
  }
  
  @override
  bool get isInitialized => _initialized;
  
  @override
  bool get canReset => true;
  
  @override
  String get category => 'state';
  
  @override
  bool get isCore => true;
  
  @override
  bool get isPersistent => false;
  
  @override
  bool get isOptional => false;
}

class CacheDomain implements RuntimeDomain, RuntimeDomainMetadata {
  bool _initialized = false;
  
  @override
  String get domainId => 'cache';
  
  @override
  String get domainName => 'Cache Manager';
  
  @override
  int get initializationPriority => 75;
  
  @override
  List<String> get dependencies => ['storage'];
  
  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 60));
    _initialized = true;
  }
  
  @override
  Future<void> reset(ResetLevel level) async {
    if (level.shouldResetTransientState) {
      await Future.delayed(const Duration(milliseconds: 25));
    }
  }
  
  @override
  Future<void> dispose() async {
    _initialized = false;
  }
  
  @override
  bool get isInitialized => _initialized;
  
  @override
  bool get canReset => true;
  
  @override
  String get category => 'cache';
  
  @override
  bool get isCore => false;
  
  @override
  bool get isPersistent => true;
  
  @override
  bool get isOptional => true;
}

class SyncDomain implements RuntimeDomain, RuntimeDomainMetadata {
  bool _initialized = false;
  
  @override
  String get domainId => 'sync';
  
  @override
  String get domainName => 'Sync Service';
  
  @override
  int get initializationPriority => 70;
  
  @override
  List<String> get dependencies => ['storage', 'networking', 'auth'];
  
  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 90));
    _initialized = true;
  }
  
  @override
  Future<void> reset(ResetLevel level) async {
    if (level.shouldResetTransientState) {
      await Future.delayed(const Duration(milliseconds: 35));
    }
  }
  
  @override
  Future<void> dispose() async {
    _initialized = false;
  }
  
  @override
  bool get isInitialized => _initialized;
  
  @override
  bool get canReset => true;
  
  @override
  String get category => 'sync';
  
  @override
  bool get isCore => false;
  
  @override
  bool get isPersistent => false;
  
  @override
  bool get isOptional => true;
}
