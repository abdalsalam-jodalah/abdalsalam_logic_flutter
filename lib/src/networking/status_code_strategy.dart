// lib/src/networking/status_code_strategy.dart

abstract class StatusCodeStrategy {
  bool isSuccess(int? httpStatus, Map<String, dynamic>? responseBody);
  
  String? getInternalStatus(Map<String, dynamic>? responseBody);
  
  String? getErrorMessage(int? httpStatus, Map<String, dynamic>? responseBody);
}

class HttpStatusCodeStrategy implements StatusCodeStrategy {
  @override
  bool isSuccess(int? httpStatus, Map<String, dynamic>? responseBody) {
    if (httpStatus == null) return false;
    return httpStatus >= 200 && httpStatus < 300;
  }

  @override
  String? getInternalStatus(Map<String, dynamic>? responseBody) {
    return null;
  }

  @override
  String? getErrorMessage(int? httpStatus, Map<String, dynamic>? responseBody) {
    if (httpStatus == null) return 'Unknown error';
    
    switch (httpStatus) {
      case 400:
        return responseBody?['message'] as String? ?? 'Bad request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Resource not found';
      case 409:
        return 'Conflict';
      case 422:
        return 'Validation error';
      case 429:
        return 'Too many requests';
      case 500:
        return 'Internal server error';
      case 502:
        return 'Bad gateway';
      case 503:
        return 'Service unavailable';
      case 504:
        return 'Gateway timeout';
      default:
        return 'HTTP error: $httpStatus';
    }
  }
}

class InternalStatusCodeStrategy implements StatusCodeStrategy {
  final String statusField;
  final String messageField;
  final List<String> successStatuses;

  const InternalStatusCodeStrategy({
    this.statusField = 'status',
    this.messageField = 'message',
    this.successStatuses = const ['success', 'ok'],
  });

  @override
  bool isSuccess(int? httpStatus, Map<String, dynamic>? responseBody) {
    if (httpStatus == null || httpStatus < 200 || httpStatus >= 300) {
      return false;
    }
    
    if (responseBody == null) return true;
    
    final internalStatus = responseBody[statusField] as String?;
    if (internalStatus == null) return true;
    
    return successStatuses.contains(internalStatus.toLowerCase());
  }

  @override
  String? getInternalStatus(Map<String, dynamic>? responseBody) {
    return responseBody?[statusField] as String?;
  }

  @override
  String? getErrorMessage(int? httpStatus, Map<String, dynamic>? responseBody) {
    final message = responseBody?[messageField] as String?;
    if (message != null) return message;
    
    final internalStatus = getInternalStatus(responseBody);
    if (internalStatus != null && !successStatuses.contains(internalStatus.toLowerCase())) {
      return 'Request failed with status: $internalStatus';
    }
    
    return HttpStatusCodeStrategy().getErrorMessage(httpStatus, responseBody);
  }
}