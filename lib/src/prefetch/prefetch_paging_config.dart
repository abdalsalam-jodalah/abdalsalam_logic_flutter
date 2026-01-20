// lib/src/prefetch/prefetch_paging_config.dart
// Pagination configuration for prefetch requests

class PrefetchPagingConfig {
  final int pageSize;
  final int? maxPages;
  final String pageParamName;
  final String pageSizeParamName;
  final int startPage;

  const PrefetchPagingConfig({
    required this.pageSize,
    this.maxPages,
    this.pageParamName = 'page',
    this.pageSizeParamName = 'pageSize',
    this.startPage = 1,
  });

  PrefetchPagingConfig copyWith({
    int? pageSize,
    int? maxPages,
    String? pageParamName,
    String? pageSizeParamName,
    int? startPage,
  }) {
    return PrefetchPagingConfig(
      pageSize: pageSize ?? this.pageSize,
      maxPages: maxPages ?? this.maxPages,
      pageParamName: pageParamName ?? this.pageParamName,
      pageSizeParamName: pageSizeParamName ?? this.pageSizeParamName,
      startPage: startPage ?? this.startPage,
    );
  }
}
