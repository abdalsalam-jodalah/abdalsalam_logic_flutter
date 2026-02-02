// lib/src/networking/request_manager.dart
import '../core/interfaces/service_interface.dart';
import 'network_api.dart';
import 'models/network_response.dart';

abstract class RequestManager extends ServiceInterface {
  Future<NetworkResponse<TResponse>> execute<TRequest, TResponse>(
    NetworkApi<TRequest, TResponse> api,
  );
  
  void enable();
  
  void disable();
  
  bool get isEnabled;
  
  Future<void> processQueue();
  
  Future<int> getPendingCount();
  
  Future<void> clearQueue();
  
  Stream<int> get queueCountStream;
}