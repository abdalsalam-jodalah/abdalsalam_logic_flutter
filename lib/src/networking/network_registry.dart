// lib/src/networking/network_registry.dart
import '../core/interfaces/service_interface.dart';
import 'network_api.dart';

abstract class NetworkRegistry extends ServiceInterface {
  void register<T extends NetworkApi>(T api);
  
  T? getApi<T extends NetworkApi>();
  
  List<NetworkApi> listApis();
  
  bool isRegistered<T extends NetworkApi>();
  
  void unregister<T extends NetworkApi>();
  
  void clear();
}