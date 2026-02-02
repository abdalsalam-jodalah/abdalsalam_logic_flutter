// lib/src/networking/models/network_response.dart
import 'package:equatable/equatable.dart';

class NetworkResponse<T> extends Equatable {
  final int? httpStatus;
  final String? internalStatus;
  final T? parsedModel;
  final Map<String, dynamic>? rawResponse;
  final String? error;
  final bool isSuccess;

  const NetworkResponse({
    this.httpStatus,
    this.internalStatus,
    this.parsedModel,
    this.rawResponse,
    this.error,
    required this.isSuccess,
  });

  factory NetworkResponse.success({
    required T data,
    int? httpStatus,
    String? internalStatus,
    Map<String, dynamic>? rawResponse,
  }) {
    return NetworkResponse<T>(
      httpStatus: httpStatus,
      internalStatus: internalStatus,
      parsedModel: data,
      rawResponse: rawResponse,
      isSuccess: true,
    );
  }

  factory NetworkResponse.failure({
    required String error,
    int? httpStatus,
    String? internalStatus,
    Map<String, dynamic>? rawResponse,
  }) {
    return NetworkResponse<T>(
      httpStatus: httpStatus,
      internalStatus: internalStatus,
      rawResponse: rawResponse,
      error: error,
      isSuccess: false,
    );
  }

  factory NetworkResponse.offline() {
    return NetworkResponse<T>(
      error: 'Device is offline',
      isSuccess: false,
    );
  }

  @override
  List<Object?> get props => [
        httpStatus,
        internalStatus,
        parsedModel,
        rawResponse,
        error,
        isSuccess,
      ];
}