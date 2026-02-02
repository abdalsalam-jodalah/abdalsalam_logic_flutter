// lib/src/networking/models/http_method.dart
enum HttpMethod {
  get('GET'),
  post('POST'),
  put('PUT'),
  delete('DELETE'),
  patch('PATCH'),
  head('HEAD'),
  options('OPTIONS');

  const HttpMethod(this.value);
  
  final String value;

  @override
  String toString() => value;
}