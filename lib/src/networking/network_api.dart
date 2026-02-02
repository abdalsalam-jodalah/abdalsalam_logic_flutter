// lib/src/networking/network_api.dart
import 'models/http_method.dart';
import 'models/api_url.dart';

abstract class NetworkApi<TRequest, TResponse> {
  String get apiTypeIdentifier;
  
  HttpMethod get method;
  
  ApiUrl get urlObject;
  
  TRequest? get bodyModel;
  
  bool get needAuth;
  
  bool get queueFlag;
  
  int get priority;
  
  bool get cacheFlag;
  
  Map<String, dynamic>? toRequestBody();
  
  TResponse parseResponse(Map<String, dynamic> responseData);
  
  Map<String, String> getHeaders() => {};
}