class StorageInfo {
  final int totalSpace;
  final int freeSpace;
  final int usedSpace;
  final double usagePercentage;
  final DateTime timestamp;

  const StorageInfo({
    required this.totalSpace,
    required this.freeSpace,
    required this.usedSpace,
    required this.usagePercentage,
    required this.timestamp,
  });

  factory StorageInfo.initial() => StorageInfo(
        totalSpace: 0,
        freeSpace: 0,
        usedSpace: 0,
        usagePercentage: 0,
        timestamp: DateTime.now(),
      );

  StorageInfo copyWith({
    int? totalSpace,
    int? freeSpace,
    int? usedSpace,
    double? usagePercentage,
    DateTime? timestamp,
  }) =>
      StorageInfo(
        totalSpace: totalSpace ?? this.totalSpace,
        freeSpace: freeSpace ?? this.freeSpace,
        usedSpace: usedSpace ?? this.usedSpace,
        usagePercentage: usagePercentage ?? this.usagePercentage,
        timestamp: timestamp ?? this.timestamp,
      );

  String get totalSpaceGB => '${(totalSpace / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  String get freeSpaceGB => '${(freeSpace / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  String get usedSpaceGB => '${(usedSpace / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';

  Map<String, dynamic> toMap() => {
        'totalSpace': totalSpace,
        'freeSpace': freeSpace,
        'usedSpace': usedSpace,
        'usagePercentage': usagePercentage,
        'timestamp': timestamp.toIso8601String(),
      };

  @override
  String toString() => 'StorageInfo(total: $totalSpaceGB, free: $freeSpaceGB, usage: ${usagePercentage.toStringAsFixed(1)}%)';
}
