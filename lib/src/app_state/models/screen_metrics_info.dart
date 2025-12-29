class ScreenMetricsInfo {
  final double pixelRatio;
  final double dpi;
  final double viewInsetTop;
  final double viewInsetBottom;
  final double viewInsetLeft;
  final double viewInsetRight;
  final double viewPaddingTop;
  final double viewPaddingBottom;
  final double viewPaddingLeft;
  final double viewPaddingRight;
  final DateTime timestamp;

  const ScreenMetricsInfo({
    required this.pixelRatio,
    required this.dpi,
    required this.viewInsetTop,
    required this.viewInsetBottom,
    required this.viewInsetLeft,
    required this.viewInsetRight,
    required this.viewPaddingTop,
    required this.viewPaddingBottom,
    required this.viewPaddingLeft,
    required this.viewPaddingRight,
    required this.timestamp,
  });

  factory ScreenMetricsInfo.initial() => ScreenMetricsInfo(
        pixelRatio: 1.0,
        dpi: 96.0,
        viewInsetTop: 0,
        viewInsetBottom: 0,
        viewInsetLeft: 0,
        viewInsetRight: 0,
        viewPaddingTop: 0,
        viewPaddingBottom: 0,
        viewPaddingLeft: 0,
        viewPaddingRight: 0,
        timestamp: DateTime.now(),
      );

  bool get hasNotch => viewInsetTop > 0;
  bool get hasBottomInset => viewInsetBottom > 0;
  double get totalSafeAreaTop => viewInsetTop + viewPaddingTop;
  double get totalSafeAreaBottom => viewInsetBottom + viewPaddingBottom;

  ScreenMetricsInfo copyWith({
    double? pixelRatio,
    double? dpi,
    double? viewInsetTop,
    double? viewInsetBottom,
    double? viewInsetLeft,
    double? viewInsetRight,
    double? viewPaddingTop,
    double? viewPaddingBottom,
    double? viewPaddingLeft,
    double? viewPaddingRight,
    DateTime? timestamp,
  }) =>
      ScreenMetricsInfo(
        pixelRatio: pixelRatio ?? this.pixelRatio,
        dpi: dpi ?? this.dpi,
        viewInsetTop: viewInsetTop ?? this.viewInsetTop,
        viewInsetBottom: viewInsetBottom ?? this.viewInsetBottom,
        viewInsetLeft: viewInsetLeft ?? this.viewInsetLeft,
        viewInsetRight: viewInsetRight ?? this.viewInsetRight,
        viewPaddingTop: viewPaddingTop ?? this.viewPaddingTop,
        viewPaddingBottom: viewPaddingBottom ?? this.viewPaddingBottom,
        viewPaddingLeft: viewPaddingLeft ?? this.viewPaddingLeft,
        viewPaddingRight: viewPaddingRight ?? this.viewPaddingRight,
        timestamp: timestamp ?? this.timestamp,
      );

  Map<String, dynamic> toMap() => {
        'pixelRatio': pixelRatio,
        'dpi': dpi,
        'viewInsetTop': viewInsetTop,
        'viewInsetBottom': viewInsetBottom,
        'viewInsetLeft': viewInsetLeft,
        'viewInsetRight': viewInsetRight,
        'viewPaddingTop': viewPaddingTop,
        'viewPaddingBottom': viewPaddingBottom,
        'viewPaddingLeft': viewPaddingLeft,
        'viewPaddingRight': viewPaddingRight,
        'hasNotch': hasNotch,
        'timestamp': timestamp.toIso8601String(),
      };

  @override
  String toString() =>
      'ScreenMetricsInfo(pixelRatio: $pixelRatio, dpi: $dpi, hasNotch: $hasNotch, safeAreaTop: $totalSafeAreaTop)';
}
