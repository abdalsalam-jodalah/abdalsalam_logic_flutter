// lib/src/networking/network_registry_impl.dart
import 'network_registry.dart';
import 'network_api.dart';
import 'exceptions/networking_exceptions.dart';

class NetworkRegistryImpl implements NetworkRegistry {
  final Map<Type, NetworkApi> _registeredApis = {};
  final Map<String, Type> _identifierToType = {};

  @override
  Future<void> initialize() async {
    // Registry is ready immediately
  }

  @override
  Future<void> dispose() async {
    _registeredApis.clear();
    _identifierToType.clear();
  }

  @override
  void register<T extends NetworkApi>(T api) {
    _validateApiDefinition(api);
    
    final type = T;
    final identifier = api.apiTypeIdentifier;
    
    if (_registeredApis.containsKey(type)) {
      throw NetworkValidationException(
        message: 'API of type $type is already registered',
        code: 'DUPLICATE_REGISTRATION',
      );
    }
    
    if (_identifierToType.containsKey(identifier)) {
      throw NetworkValidationException(
        message: 'API with identifier "$identifier" is already registered',
        code: 'DUPLICATE_IDENTIFIER',
      );
    }
    
    _registeredApis[type] = api;
    _identifierToType[identifier] = type;
  }

  @override
  T? getApi<T extends NetworkApi>() {
    return _registeredApis[T] as T?;
  }

  @override
  List<NetworkApi> listApis() {
    return List.unmodifiable(_registeredApis.values);
  }

  @override
  bool isRegistered<T extends NetworkApi>() {
    return _registeredApis.containsKey(T);
  }

  @override
  void unregister<T extends NetworkApi>() {
    final api = _registeredApis.remove(T);
    if (api != null) {
      _identifierToType.remove(api.apiTypeIdentifier);
    }
  }

  @override
  void clear() {
    _registeredApis.clear();
    _identifierToType.clear();
  }

  void _validateApiDefinition(NetworkApi api) {
    if (api.apiTypeIdentifier.isEmpty) {
      throw NetworkValidationException(
        message: 'API type identifier cannot be empty',
        code: 'EMPTY_IDENTIFIER',
      );
    }
    
    if (api.urlObject.baseUrl.isEmpty) {
      throw NetworkValidationException(
        message: 'API base URL cannot be empty',
        code: 'EMPTY_BASE_URL',
      );
    }
    
    if (api.urlObject.path.isEmpty) {
      throw NetworkValidationException(
        message: 'API path cannot be empty',
        code: 'EMPTY_PATH',
      );
    }
    
    if (api.priority < 0) {
      throw NetworkValidationException(
        message: 'API priority must be non-negative, got: ${api.priority}',
        code: 'NEGATIVE_PRIORITY',
      );
    }
  }
}