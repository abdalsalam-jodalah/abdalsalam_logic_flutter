// lib/src/networking/models/api_url.dart
import 'package:equatable/equatable.dart';

class ApiUrl extends Equatable {
  final String baseUrl;
  final String path;
  final Map<String, String> pathVariables;
  final Map<String, dynamic> queryParameters;

  const ApiUrl({
    required this.baseUrl,
    required this.path,
    this.pathVariables = const {},
    this.queryParameters = const {},
  });

  String get fullUrl {
    var processedPath = path;
    
    pathVariables.forEach((key, value) {
      processedPath = processedPath.replaceAll('{$key}', value);
    });
    
    final uri = Uri.parse('$baseUrl$processedPath');
    
    if (queryParameters.isNotEmpty) {
      return uri.replace(queryParameters: queryParameters).toString();
    }
    
    return uri.toString();
  }

  ApiUrl copyWith({
    String? baseUrl,
    String? path,
    Map<String, String>? pathVariables,
    Map<String, dynamic>? queryParameters,
  }) {
    return ApiUrl(
      baseUrl: baseUrl ?? this.baseUrl,
      path: path ?? this.path,
      pathVariables: pathVariables ?? this.pathVariables,
      queryParameters: queryParameters ?? this.queryParameters,
    );
  }

  @override
  List<Object?> get props => [baseUrl, path, pathVariables, queryParameters];
}