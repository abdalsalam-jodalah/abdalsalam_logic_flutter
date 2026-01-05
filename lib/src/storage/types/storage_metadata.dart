// lib/src/storage/types/storage_metadata.dart

/// Comprehensive metadata about a storage implementation.
///
/// Provides detailed information for:
/// - Feature detection
/// - Capability checking
/// - Debugging and logging
/// - Performance optimization
class StorageMetadata {
  /// Name of the storage backend type.
  final String type;

  /// Version of the storage backend.
  final String version;

  /// Human-readable description.
  final String? description;

  // ==========================================================================
  // CAPABILITY FLAGS
  // ==========================================================================

  /// Whether this storage supports transactions.
  final bool supportsTransactions;

  /// Whether this storage supports nested transactions (savepoints).
  final bool supportsNestedTransactions;

  /// Whether this storage supports queries.
  final bool supportsQueries;

  /// Whether this storage supports query aggregations.
  final bool supportsAggregations;

  /// Whether this storage supports joins.
  final bool supportsJoins;

  /// Whether this storage supports concurrent access (thread-safe).
  final bool supportsConcurrency;

  /// Whether this storage supports batch operations.
  final bool supportsBatchOperations;

  /// Whether this storage supports partial updates.
  final bool supportsPartialUpdates;

  /// Whether this storage supports atomic increments.
  final bool supportsAtomicIncrements;

  /// Whether this storage supports schema management.
  final bool supportsSchema;

  /// Whether this storage supports migrations.
  final bool supportsMigrations;

  /// Whether this storage supports watch/observe changes.
  final bool supportsWatching;

  /// Whether this storage supports TTL/expiration.
  final bool supportsExpiration;

  /// Whether this storage supports versioning (optimistic locking).
  final bool supportsVersioning;

  /// Whether this storage provides entity metadata.
  final bool supportsEntityMetadata;

  /// Whether this storage provides value metadata.
  final bool supportsValueMetadata;

  /// Whether this storage supports key patterns/wildcards.
  final bool supportsKeyPattern;

  /// Whether this storage supports cursor-based pagination.
  final bool supportsCursorPagination;

  /// Whether this storage supports field projection (select).
  final bool supportsProjection;

  /// Whether this storage supports grouping (GROUP BY).
  final bool supportsGrouping;

  /// Whether this storage supports custom predicates.
  final bool supportsCustomPredicates;

  /// Whether this storage supports raw queries.
  final bool supportsRawQueries;

  /// Whether this storage is encrypted.
  final bool isEncrypted;

  /// Whether this storage is persistent (survives app restart).
  final bool isPersistent;

  /// Whether this storage is in-memory only.
  final bool isInMemory;

  // ==========================================================================
  // LIMITS
  // ==========================================================================

  /// Maximum size per value (in bytes), or `null` if unlimited.
  final int? maxValueSize;

  /// Maximum size per entity (in bytes), or `null` if unlimited.
  final int? maxEntitySize;

  /// Maximum number of keys, or `null` if unlimited.
  final int? maxKeys;

  /// Maximum number of entities, or `null` if unlimited.
  final int? maxEntities;

  /// Maximum key length (characters), or `null` if unlimited.
  final int? maxKeyLength;

  /// Maximum field name length, or `null` if unlimited.
  final int? maxFieldNameLength;

  /// Maximum nesting depth for objects, or `null` if unlimited.
  final int? maxNestingDepth;

  /// Maximum number of concurrent transactions, or `null` if unlimited.
  final int? maxConcurrentTransactions;

  /// Maximum batch size, or `null` if unlimited.
  final int? maxBatchSize;

  // ==========================================================================
  // PERFORMANCE CHARACTERISTICS
  // ==========================================================================

  /// Typical read latency in milliseconds.
  final int? typicalReadLatencyMs;

  /// Typical write latency in milliseconds.
  final int? typicalWriteLatencyMs;

  /// Whether reads are generally fast (< 10ms).
  final bool fastReads;

  /// Whether writes are generally fast (< 10ms).
  final bool fastWrites;

  /// Whether this storage is optimized for bulk operations.
  final bool optimizedForBulk;

  // ==========================================================================
  // PLATFORM INFO
  // ==========================================================================

  /// Platforms this storage supports (web, android, ios, macos, windows, linux).
  final List<String> supportedPlatforms;

  /// Minimum platform versions required.
  final Map<String, String> minimumPlatformVersions;

  // ==========================================================================
  // CUSTOM METADATA
  // ==========================================================================

  /// Additional custom metadata as key-value pairs.
  final Map<String, dynamic> custom;

  const StorageMetadata({
    required this.type,
    required this.version,
    this.description,
    // Capabilities
    this.supportsTransactions = false,
    this.supportsNestedTransactions = false,
    this.supportsQueries = false,
    this.supportsAggregations = false,
    this.supportsJoins = false,
    this.supportsConcurrency = false,
    this.supportsBatchOperations = false,
    this.supportsPartialUpdates = false,
    this.supportsAtomicIncrements = false,
    this.supportsSchema = false,
    this.supportsMigrations = false,
    this.supportsWatching = false,
    this.supportsExpiration = false,
    this.supportsVersioning = false,
    this.supportsEntityMetadata = false,
    this.supportsValueMetadata = false,
    this.supportsKeyPattern = false,
    this.supportsCursorPagination = false,
    this.supportsProjection = false,
    this.supportsGrouping = false,
    this.supportsCustomPredicates = false,
    this.supportsRawQueries = false,
    this.isEncrypted = false,
    this.isPersistent = true,
    this.isInMemory = false,
    // Limits
    this.maxValueSize,
    this.maxEntitySize,
    this.maxKeys,
    this.maxEntities,
    this.maxKeyLength,
    this.maxFieldNameLength,
    this.maxNestingDepth,
    this.maxConcurrentTransactions,
    this.maxBatchSize,
    // Performance
    this.typicalReadLatencyMs,
    this.typicalWriteLatencyMs,
    this.fastReads = false,
    this.fastWrites = false,
    this.optimizedForBulk = false,
    // Platform
    this.supportedPlatforms = const [],
    this.minimumPlatformVersions = const {},
    // Custom
    this.custom = const {},
  });

  /// Returns `true` if this storage supports the given feature.
  ///
  /// Feature names can be capability flags or custom features.
  bool supports(String feature) {
    switch (feature.toLowerCase()) {
      case 'transactions':
        return supportsTransactions;
      case 'nested_transactions':
      case 'savepoints':
        return supportsNestedTransactions;
      case 'queries':
        return supportsQueries;
      case 'aggregations':
        return supportsAggregations;
      case 'joins':
        return supportsJoins;
      case 'concurrency':
        return supportsConcurrency;
      case 'batch':
      case 'batch_operations':
        return supportsBatchOperations;
      case 'partial_updates':
        return supportsPartialUpdates;
      case 'atomic_increments':
        return supportsAtomicIncrements;
      case 'schema':
        return supportsSchema;
      case 'migrations':
        return supportsMigrations;
      case 'watching':
      case 'observe':
        return supportsWatching;
      case 'expiration':
      case 'ttl':
        return supportsExpiration;
      case 'versioning':
      case 'optimistic_locking':
        return supportsVersioning;
      case 'entity_metadata':
        return supportsEntityMetadata;
      case 'value_metadata':
        return supportsValueMetadata;
      case 'key_pattern':
      case 'wildcards':
        return supportsKeyPattern;
      case 'cursor_pagination':
        return supportsCursorPagination;
      case 'projection':
      case 'select':
        return supportsProjection;
      case 'grouping':
      case 'group_by':
        return supportsGrouping;
      case 'custom_predicates':
        return supportsCustomPredicates;
      case 'raw_queries':
        return supportsRawQueries;
      case 'encryption':
        return isEncrypted;
      default:
        return custom[feature] == true;
    }
  }

  @override
  String toString() {
    return 'StorageMetadata(type: $type, version: $version, '
        'capabilities: ${_getCapabilitySummary()})';
  }

  String _getCapabilitySummary() {
    final capabilities = <String>[];
    if (supportsTransactions) capabilities.add('transactions');
    if (supportsQueries) capabilities.add('queries');
    if (supportsSchema) capabilities.add('schema');
    if (supportsMigrations) capabilities.add('migrations');
    if (supportsWatching) capabilities.add('watching');
    if (isEncrypted) capabilities.add('encrypted');
    return capabilities.join(', ');
  }

  /// Creates a copy with updated fields.
  StorageMetadata copyWith({
    String? type,
    String? version,
    String? description,
    bool? supportsTransactions,
    bool? supportsQueries,
    // ... add other fields as needed
    Map<String, dynamic>? custom,
  }) {
    return StorageMetadata(
      type: type ?? this.type,
      version: version ?? this.version,
      description: description ?? this.description,
      supportsTransactions: supportsTransactions ?? this.supportsTransactions,
      supportsQueries: supportsQueries ?? this.supportsQueries,
      // ... copy other fields
      custom: custom ?? this.custom,
    );
  }
}
