// lib/src/app_state/models/auth_info.dart

enum AppAuthStatus { unauthenticated, authenticated, refreshing, expired }

class AuthInfo {
  final AppAuthStatus status;
  final dynamic currentUser;
  final String? accessToken;
  final String? refreshToken;
  final bool hasValidSession;
  final DateTime? lastLoginTime;
  final DateTime timestamp;

  AuthInfo({
    this.status = AppAuthStatus.unauthenticated,
    this.currentUser,
    this.accessToken,
    this.refreshToken,
    this.hasValidSession = false,
    this.lastLoginTime,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory AuthInfo.empty() =>
      AuthInfo(status: AppAuthStatus.unauthenticated, hasValidSession: false);

  AuthInfo copyWith({
    AppAuthStatus? status,
    dynamic currentUser,
    String? accessToken,
    String? refreshToken,
    bool? hasValidSession,
    DateTime? lastLoginTime,
    DateTime? timestamp,
  }) {
    return AuthInfo(
      status: status ?? this.status,
      currentUser: currentUser ?? this.currentUser,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      hasValidSession: hasValidSession ?? this.hasValidSession,
      lastLoginTime: lastLoginTime ?? this.lastLoginTime,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  bool get isAuthenticated => status == AppAuthStatus.authenticated;
  bool get isUnauthenticated => status == AppAuthStatus.unauthenticated;
  bool get isRefreshing => status == AppAuthStatus.refreshing;
  bool get isExpired => status == AppAuthStatus.expired;

  Map<String, dynamic> toMap() {
    return {
      'status': status.name,
      'hasValidSession': hasValidSession,
      'lastLoginTime': lastLoginTime?.toIso8601String(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
