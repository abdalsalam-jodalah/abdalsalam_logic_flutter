// lib/src/app_state/models/auth_info.dart
class AuthInfo {
  final bool isAuthenticated;
  final String? userId;
  final String? userEmail;
  final DateTime? authenticatedAt;
  final DateTime timestamp;

  AuthInfo({
    this.isAuthenticated = false,
    this.userId,
    this.userEmail,
    this.authenticatedAt,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);

  AuthInfo copyWith({
    bool? isAuthenticated,
    String? userId,
    String? userEmail,
    DateTime? authenticatedAt,
    DateTime? timestamp,
  }) {
    return AuthInfo(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      authenticatedAt: authenticatedAt ?? this.authenticatedAt,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isAuthenticated': isAuthenticated,
      'userId': userId,
      'userEmail': userEmail,
      'authenticatedAt': authenticatedAt?.toIso8601String(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
