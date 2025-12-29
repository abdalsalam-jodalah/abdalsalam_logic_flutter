// lib/src/app_state/models/permissions_info.dart

enum PermissionStatus {
  denied,
  granted,
  restricted,
  limited,
  permanentlyDenied,
  provisional,
}

enum PermissionType {
  camera,
  microphone,
  location,
  locationAlways,
  locationWhenInUse,
  calendar,
  contacts,
  photos,
  videos,
  storage,
  documents,
  downloads,
  notifications,
  phone,
  sms,
  sensors,
  activityRecognition,
  bluetooth,
  schedule,
  appTrackingTransparency,
  mediaLibrary,
  reminders,
  speechRecognition,
}

class PermissionInfo {
  final PermissionType type;
  final PermissionStatus status;
  final bool isDetermined;
  final bool isGranted;
  final bool isDenied;
  final bool isRestricted;
  final bool isLimited;
  final bool isPermanentlyDenied;
  final DateTime? lastRequestTime;

  const PermissionInfo({
    required this.type,
    required this.status,
    required this.isDetermined,
    required this.isGranted,
    required this.isDenied,
    required this.isRestricted,
    required this.isLimited,
    required this.isPermanentlyDenied,
    this.lastRequestTime,
  });

  factory PermissionInfo.denied(PermissionType type) => PermissionInfo(
        type: type,
        status: PermissionStatus.denied,
        isDetermined: true,
        isGranted: false,
        isDenied: true,
        isRestricted: false,
        isLimited: false,
        isPermanentlyDenied: false,
      );

  factory PermissionInfo.granted(PermissionType type) => PermissionInfo(
        type: type,
        status: PermissionStatus.granted,
        isDetermined: true,
        isGranted: true,
        isDenied: false,
        isRestricted: false,
        isLimited: false,
        isPermanentlyDenied: false,
      );

  factory PermissionInfo.restricted(PermissionType type) => PermissionInfo(
        type: type,
        status: PermissionStatus.restricted,
        isDetermined: true,
        isGranted: false,
        isDenied: false,
        isRestricted: true,
        isLimited: false,
        isPermanentlyDenied: false,
      );

  factory PermissionInfo.permanentlyDenied(PermissionType type) =>
      PermissionInfo(
        type: type,
        status: PermissionStatus.permanentlyDenied,
        isDetermined: true,
        isGranted: false,
        isDenied: false,
        isRestricted: false,
        isLimited: false,
        isPermanentlyDenied: true,
      );

  PermissionInfo copyWith({
    PermissionType? type,
    PermissionStatus? status,
    bool? isDetermined,
    bool? isGranted,
    bool? isDenied,
    bool? isRestricted,
    bool? isLimited,
    bool? isPermanentlyDenied,
    DateTime? lastRequestTime,
  }) =>
      PermissionInfo(
        type: type ?? this.type,
        status: status ?? this.status,
        isDetermined: isDetermined ?? this.isDetermined,
        isGranted: isGranted ?? this.isGranted,
        isDenied: isDenied ?? this.isDenied,
        isRestricted: isRestricted ?? this.isRestricted,
        isLimited: isLimited ?? this.isLimited,
        isPermanentlyDenied: isPermanentlyDenied ?? this.isPermanentlyDenied,
        lastRequestTime: lastRequestTime ?? this.lastRequestTime,
      );

  Map<String, dynamic> toJson() => {
        'type': type.toString(),
        'status': status.toString(),
        'isDetermined': isDetermined,
        'isGranted': isGranted,
        'isDenied': isDenied,
        'isRestricted': isRestricted,
        'isLimited': isLimited,
        'isPermanentlyDenied': isPermanentlyDenied,
        'lastRequestTime': lastRequestTime?.toIso8601String(),
      };

  @override
  String toString() =>
      'PermissionInfo(type: ${type.name}, status: ${status.name}, granted: $isGranted)';
}

class PermissionsInfo {
  final Map<PermissionType, PermissionInfo> permissions;
  final DateTime lastUpdated;

  const PermissionsInfo({
    required this.permissions,
    required this.lastUpdated,
  });

  factory PermissionsInfo.initial() => PermissionsInfo(
        permissions: {},
        lastUpdated: DateTime.now(),
      );

  bool isGranted(PermissionType type) =>
      permissions[type]?.isGranted ?? false;

  bool isDenied(PermissionType type) => permissions[type]?.isDenied ?? false;

  bool isRestricted(PermissionType type) =>
      permissions[type]?.isRestricted ?? false;

  bool isPermanentlyDenied(PermissionType type) =>
      permissions[type]?.isPermanentlyDenied ?? false;

  bool isLimited(PermissionType type) => permissions[type]?.isLimited ?? false;

  PermissionStatus? getStatus(PermissionType type) =>
      permissions[type]?.status;

  List<PermissionType> getDeniedPermissions() =>
      permissions.entries
          .where((e) => e.value.isDenied)
          .map((e) => e.key)
          .toList();

  List<PermissionType> getGrantedPermissions() =>
      permissions.entries
          .where((e) => e.value.isGranted)
          .map((e) => e.key)
          .toList();

  List<PermissionType> getRestrictedPermissions() =>
      permissions.entries
          .where((e) => e.value.isRestricted)
          .map((e) => e.key)
          .toList();

  List<PermissionType> getPermanentlyDeniedPermissions() =>
      permissions.entries
          .where((e) => e.value.isPermanentlyDenied)
          .map((e) => e.key)
          .toList();

  PermissionsInfo updatePermission(PermissionInfo permissionInfo) {
    final updatedPermissions = Map<PermissionType, PermissionInfo>.from(permissions);
    updatedPermissions[permissionInfo.type] = permissionInfo;
    return PermissionsInfo(
      permissions: updatedPermissions,
      lastUpdated: DateTime.now(),
    );
  }

  PermissionsInfo updatePermissions(List<PermissionInfo> permissionsList) {
    final updatedPermissions = Map<PermissionType, PermissionInfo>.from(permissions);
    for (final permission in permissionsList) {
      updatedPermissions[permission.type] = permission;
    }
    return PermissionsInfo(
      permissions: updatedPermissions,
      lastUpdated: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'permissions': permissions.map((key, value) =>
            MapEntry(key.toString(), value.toJson())),
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  @override
  String toString() =>
      'PermissionsInfo(permissions: ${permissions.length}, lastUpdated: $lastUpdated)';
}
