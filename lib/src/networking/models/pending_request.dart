// lib/src/networking/models/pending_request.dart
import 'package:equatable/equatable.dart';
import 'http_method.dart';

class PendingRequest extends Equatable {
  final String id;
  final String apiTypeIdentifier;
  final HttpMethod method;
  final String fullUrl;
  final Map<String, dynamic>? requestBody;
  final Map<String, String>? headers;
  final bool needAuth;
  final int priority;
  final DateTime createdAt;
  final int retryCount;
  final DateTime? lastRetryAt;

  const PendingRequest({
    required this.id,
    required this.apiTypeIdentifier,
    required this.method,
    required this.fullUrl,
    this.requestBody,
    this.headers,
    required this.needAuth,
    required this.priority,
    required this.createdAt,
    this.retryCount = 0,
    this.lastRetryAt,
  });

  factory PendingRequest.fromJson(Map<String, dynamic> json) {
    return PendingRequest(
      id: json['id'] as String,
      apiTypeIdentifier: json['apiTypeIdentifier'] as String,
      method: HttpMethod.values.firstWhere(
        (e) => e.value == json['method'],
      ),
      fullUrl: json['fullUrl'] as String,
      requestBody: json['requestBody'] as Map<String, dynamic>?,
      headers: (json['headers'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v.toString())),
      needAuth: json['needAuth'] as bool,
      priority: json['priority'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
      lastRetryAt: json['lastRetryAt'] != null
          ? DateTime.parse(json['lastRetryAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'apiTypeIdentifier': apiTypeIdentifier,
      'method': method.value,
      'fullUrl': fullUrl,
      'requestBody': requestBody,
      'headers': headers,
      'needAuth': needAuth,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
      'lastRetryAt': lastRetryAt?.toIso8601String(),
    };
  }

  PendingRequest copyWith({
    String? id,
    String? apiTypeIdentifier,
    HttpMethod? method,
    String? fullUrl,
    Map<String, dynamic>? requestBody,
    Map<String, String>? headers,
    bool? needAuth,
    int? priority,
    DateTime? createdAt,
    int? retryCount,
    DateTime? lastRetryAt,
  }) {
    return PendingRequest(
      id: id ?? this.id,
      apiTypeIdentifier: apiTypeIdentifier ?? this.apiTypeIdentifier,
      method: method ?? this.method,
      fullUrl: fullUrl ?? this.fullUrl,
      requestBody: requestBody ?? this.requestBody,
      headers: headers ?? this.headers,
      needAuth: needAuth ?? this.needAuth,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastRetryAt: lastRetryAt ?? this.lastRetryAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        apiTypeIdentifier,
        method,
        fullUrl,
        requestBody,
        headers,
        needAuth,
        priority,
        createdAt,
        retryCount,
        lastRetryAt,
      ];
}