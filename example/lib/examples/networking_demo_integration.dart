// lib/examples/networking_demo_integration.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';
import 'networking_advanced_example.dart';

class NetworkingDemoWidget extends StatefulWidget {
  const NetworkingDemoWidget({super.key});

  @override
  State<NetworkingDemoWidget> createState() => _NetworkingDemoWidgetState();
}

class _NetworkingDemoWidgetState extends State<NetworkingDemoWidget> {
  late NetworkRegistry _registry;
  late RequestManager _requestManager;
  late AppStateManager _appStateManager;
  late AuthTokenProviderImpl _authTokenProvider;
  
  StreamSubscription<int>? _queueSubscription;
  StreamSubscription<AppStateInfo>? _connectivitySubscription;
  
  bool _isInitialized = false;
  bool _isLoading = false;
  int _queueCount = 0;
  bool _isOnline = true;
  String _lastResponse = '';
  String _logs = '';

  @override
  void initState() {
    super.initState();
    _initializeNetworking();
  }

  Future<void> _initializeNetworking() async {
    try {
      _authTokenProvider = AuthTokenProviderImpl();
      _registry = NetworkRegistryImpl();
      _appStateManager = AppStateManagerImpl.create();
      _requestManager = RequestManagerImpl(
        registry: _registry,
        appStateManager: _appStateManager,
        authTokenProvider: _authTokenProvider,
        statusCodeStrategy: InternalStatusCodeStrategy(),
      );

      await _registry.initialize();
      await _appStateManager.initialize();
      await _requestManager.initialize();

      // Register demo APIs
      _registry.register(LoginApi(LoginRequest(
        email: 'demo@example.com',
        password: 'password123',
      )));
      _registry.register(GetProfileApi());

      // Set up listeners
      _queueSubscription = _requestManager.queueCountStream.listen((count) {
        if (mounted) {
          setState(() {
            _queueCount = count;
          });
          _addLog('Queue count updated: $count');
        }
      });

      _connectivitySubscription = _appStateManager.stateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isOnline = state.isOnline;
          });
          _addLog('Connectivity: ${state.isOnline ? "Online" : "Offline"}');
        }
      });

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _addLog('✓ Networking system initialized');
      }
    } catch (e) {
      _addLog('❌ Initialization error: $e');
    }
  }

  void _addLog(String message) {
    if (mounted) {
      setState(() {
        _logs += '${DateTime.now().toIso8601String().substring(11, 19)} - $message\n';
      });
    }
  }

  Future<void> _performLogin() async {
    if (!_isInitialized || _isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    _addLog('🔐 Attempting login...');

    try {
      final loginApi = LoginApi(LoginRequest(
        email: 'demo@example.com',
        password: 'password123',
      ));
      
      final response = await _requestManager.execute(loginApi);
      
      if (response.isSuccess && response.parsedModel != null) {
        _authTokenProvider.accessToken = response.parsedModel!.accessToken;
        _authTokenProvider.refreshTokenValue = response.parsedModel!.refreshToken;
        
        setState(() {
          _lastResponse = 'Login successful! Token: ${response.parsedModel!.accessToken.substring(0, 10)}...';
        });
        _addLog('✓ Login successful');
      } else {
        setState(() {
          _lastResponse = 'Login failed: ${response.error}';
        });
        _addLog('❌ Login failed: ${response.error}');
      }
    } catch (e) {
      setState(() {
        _lastResponse = 'Login error: $e';
      });
      _addLog('❌ Login error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getProfile() async {
    if (!_isInitialized || _isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    _addLog('👤 Getting profile...');

    try {
      final profileApi = GetProfileApi();
      final response = await _requestManager.execute(profileApi);
      
      if (response.isSuccess && response.parsedModel != null) {
        setState(() {
          _lastResponse = 'Profile: ${response.parsedModel!.name} (${response.parsedModel!.email})';
        });
        _addLog('✓ Profile retrieved');
      } else {
        setState(() {
          _lastResponse = 'Profile failed: ${response.error}';
        });
        _addLog('❌ Profile failed: ${response.error}');
      }
    } catch (e) {
      setState(() {
        _lastResponse = 'Profile error: $e';
      });
      _addLog('❌ Profile error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleRequestManager() async {
    if (!_isInitialized) return;
    
    if (_requestManager.isEnabled) {
      _requestManager.disable();
      _addLog('📵 Request manager disabled');
    } else {
      _requestManager.enable();
      _addLog('📶 Request manager enabled');
      await _requestManager.processQueue();
      _addLog('🔄 Queue processed');
    }
    setState(() {});
  }

  Future<void> _clearQueue() async {
    if (!_isInitialized) return;
    
    await _requestManager.clearQueue();
    _addLog('🗑️ Queue cleared');
  }

  void _clearLogs() {
    setState(() {
      _logs = '';
    });
  }

  @override
  void dispose() {
    _queueSubscription?.cancel();
    _connectivitySubscription?.cancel();
    if (_isInitialized) {
      _requestManager.dispose();
      _appStateManager.dispose();
      _registry.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Networking Demo'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status indicators
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isInitialized ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _isInitialized ? 'Initialized' : 'Not Ready',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isOnline ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _isOnline ? 'Online' : 'Offline',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isInitialized && _requestManager.isEnabled ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _isInitialized && _requestManager.isEnabled ? 'Enabled' : 'Disabled',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _queueCount > 0 ? Colors.orange : Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Queue: $_queueCount',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _isInitialized && !_isLoading ? _performLogin : null,
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Login'),
                ),
                ElevatedButton(
                  onPressed: _isInitialized && !_isLoading ? _getProfile : null,
                  child: const Text('Get Profile'),
                ),
                ElevatedButton(
                  onPressed: _isInitialized ? _toggleRequestManager : null,
                  child: Text(_isInitialized && _requestManager.isEnabled ? 'Disable' : 'Enable'),
                ),
                ElevatedButton(
                  onPressed: _isInitialized ? _clearQueue : null,
                  child: const Text('Clear Queue'),
                ),
                ElevatedButton(
                  onPressed: _clearLogs,
                  child: const Text('Clear Logs'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Last response
            if (_lastResponse.isNotEmpty) ...[
              const Text('Last Response:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(_lastResponse),
              ),
              const SizedBox(height: 16),
            ],
            
            // Logs
            const Text('Logs:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _logs.isEmpty ? 'No logs yet...' : _logs,
                    style: const TextStyle(
                      color: Colors.green,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}