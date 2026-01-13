// lib/src/storage/implementations/storage_catalog_mixin.dart

import 'package:sqflite/sqflite.dart';
import '../abstractions/storage_interface.dart';
import '../exceptions/storage_exceptions.dart';

/// Entry in the storage catalog representing a table or key-value store.
class CatalogEntry {
  /// Unique name of the table/storage
  final String name;

  /// Type of storage: 'table', 'key_value', 'collection'
  final String type;

  /// Number of rows/items
  final int itemCount;

  /// Size in bytes (if available)
  final int? sizeInBytes;

  /// When this storage was created
  final DateTime createdAt;

  /// Last time data was modified
  final DateTime lastModifiedAt;

  /// Last time statistics were updated
  final DateTime lastStatsUpdate;

  /// Schema version (if applicable)
  final int? schemaVersion;

  /// Custom metadata as JSON
  final Map<String, dynamic> metadata;

  /// Additional statistics
  final Map<String, dynamic> statistics;

  CatalogEntry({
    required this.name,
    required this.type,
    required this.itemCount,
    this.sizeInBytes,
    required this.createdAt,
    required this.lastModifiedAt,
    required this.lastStatsUpdate,
    this.schemaVersion,
    this.metadata = const {},
    this.statistics = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'item_count': itemCount,
      'size_in_bytes': sizeInBytes,
      'created_at': createdAt.toIso8601String(),
      'last_modified_at': lastModifiedAt.toIso8601String(),
      'last_stats_update': lastStatsUpdate.toIso8601String(),
      'schema_version': schemaVersion,
      'metadata': _encodeJson(metadata),
      'statistics': _encodeJson(statistics),
    };
  }

  factory CatalogEntry.fromMap(Map<String, dynamic> map) {
    return CatalogEntry(
      name: map['name'] as String,
      type: map['type'] as String,
      itemCount: map['item_count'] as int,
      sizeInBytes: map['size_in_bytes'] as int?,
      createdAt: DateTime.parse(map['created_at'] as String),
      lastModifiedAt: DateTime.parse(map['last_modified_at'] as String),
      lastStatsUpdate: DateTime.parse(map['last_stats_update'] as String),
      schemaVersion: map['schema_version'] as int?,
      metadata: _decodeJson(map['metadata']),
      statistics: _decodeJson(map['statistics']),
    );
  }

  static String _encodeJson(Map<String, dynamic> data) {
    if (data.isEmpty) return '{}';
    // Simple JSON encoding - in production use dart:convert
    final entries = data.entries
        .map((e) => '"${e.key}":"${e.value}"')
        .join(',');
    return '{$entries}';
  }

  static Map<String, dynamic> _decodeJson(dynamic data) {
    if (data == null || data == '{}') return {};
    // Simple JSON decoding - in production use dart:convert
    return {};
  }

  CatalogEntry copyWith({
    String? name,
    String? type,
    int? itemCount,
    int? sizeInBytes,
    DateTime? createdAt,
    DateTime? lastModifiedAt,
    DateTime? lastStatsUpdate,
    int? schemaVersion,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? statistics,
  }) {
    return CatalogEntry(
      name: name ?? this.name,
      type: type ?? this.type,
      itemCount: itemCount ?? this.itemCount,
      sizeInBytes: sizeInBytes ?? this.sizeInBytes,
      createdAt: createdAt ?? this.createdAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      lastStatsUpdate: lastStatsUpdate ?? this.lastStatsUpdate,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      metadata: metadata ?? this.metadata,
      statistics: statistics ?? this.statistics,
    );
  }

  @override
  String toString() =>
      'CatalogEntry($name, $type, $itemCount items, ${sizeInBytes ?? '?'} bytes)';
}

/// Mixin providing storage catalog capabilities.
///
/// Maintains a special table `_storage_catalog` that tracks all tables,
/// key-value stores, and their metadata/statistics.
///
/// **Auto-Registration**: When enabled, automatically registers any storage
/// that is initialized through this mixin.
mixin StorageCatalogMixin implements Storage {
  static const String catalogTableName = '_storage_catalog';

  /// Enable auto-registration of storages on initialization.
  bool _autoRegisterEnabled = false;

  /// Pending storages to register after catalog is initialized.
  final List<Map<String, dynamic>> _pendingRegistrations = [];

  /// Get the underlying database instance.
  /// Must be implemented by the storage class.
  Database? get database;

  /// Enable automatic registration of storages when they are created/initialized.
  void enableAutoRegister() {
    _autoRegisterEnabled = true;
  }

  /// Disable automatic registration.
  void disableAutoRegister() {
    _autoRegisterEnabled = false;
  }

  /// Initialize the catalog table.
  Future<void> initializeCatalog({bool autoRegister = true}) async {
    try {
      if (database == null) {
        throw StorageStateException(message: 'Database not initialized');
      }

      _autoRegisterEnabled = autoRegister;

      await database!.execute('''
        CREATE TABLE IF NOT EXISTS $catalogTableName (
          name TEXT PRIMARY KEY,
          type TEXT NOT NULL,
          item_count INTEGER NOT NULL DEFAULT 0,
          size_in_bytes INTEGER,
          created_at TEXT NOT NULL,
          last_modified_at TEXT NOT NULL,
          last_stats_update TEXT NOT NULL,
          schema_version INTEGER,
          metadata TEXT,
          statistics TEXT
        )
      ''');

      await database!.execute('''
        CREATE INDEX IF NOT EXISTS idx_catalog_type ON $catalogTableName(type)
      ''');

      await database!.execute('''
        CREATE INDEX IF NOT EXISTS idx_catalog_modified ON $catalogTableName(last_modified_at)
      ''');

      // Register any pending storages
      for (final registration in _pendingRegistrations) {
        await registerStorage(
          registration['name'] as String,
          registration['type'] as String,
          schemaVersion: registration['schemaVersion'] as int?,
          metadata: registration['metadata'] as Map<String, dynamic>?,
          force: true,
        );
      }
      _pendingRegistrations.clear();

      // Auto-discover and register existing tables
      if (_autoRegisterEnabled) {
        await _autoDiscoverAndRegisterTables();
      }
    } catch (e) {
      throw StorageOperationException(
        operation: 'initializeCatalog',
        message: 'Failed to initialize catalog: $e',
      );
    }
  }

  /// Auto-discover existing tables and register them.
  Future<void> _autoDiscoverAndRegisterTables() async {
    try {
      if (database == null) return;

      // Query SQLite master table for existing tables
      final result = await database!.query(
        'sqlite_master',
        columns: ['name', 'type'],
        where: 'type = ? AND name NOT LIKE ?',
        whereArgs: ['table', 'sqlite_%'],
      );

      for (final table in result) {
        final tableName = table['name'] as String;

        // Skip catalog table itself
        if (tableName == catalogTableName) continue;

        // Check if already registered
        if (await isStorageRegistered(tableName)) continue;

        // Auto-register with basic info
        await registerStorage(
          tableName,
          'table',
          metadata: {'auto_discovered': true},
          force: true,
        );
      }
    } catch (e) {
      // Silently fail auto-discovery
    }
  }

  /// Register a new table/storage in the catalog.
  ///
  /// If [force] is true, registers immediately even if catalog isn't initialized.
  /// Otherwise, queues the registration until catalog is initialized.
  Future<void> registerStorage(
    String name,
    String type, {
    int? schemaVersion,
    Map<String, dynamic>? metadata,
    bool force = false,
  }) async {
    try {
      // If catalog not initialized and not forcing, queue for later
      if (database == null || (!force && !await _isCatalogInitialized())) {
        _pendingRegistrations.add({
          'name': name,
          'type': type,
          'schemaVersion': schemaVersion,
          'metadata': metadata,
        });
        return;
      }

      if (database == null) {
        throw StorageStateException(message: 'Database not initialized');
      }

      final now = DateTime.now();
      final entry = CatalogEntry(
        name: name,
        type: type,
        itemCount: 0,
        createdAt: now,
        lastModifiedAt: now,
        lastStatsUpdate: now,
        schemaVersion: schemaVersion,
        metadata: metadata ?? {},
      );

      await database!.insert(
        catalogTableName,
        entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Auto-refresh stats if enabled
      if (_autoRegisterEnabled) {
        try {
          await refreshStorageStats(name);
        } catch (e) {
          // Ignore stats refresh errors
        }
      }
    } catch (e) {
      throw StorageOperationException(
        operation: 'registerStorage',
        message: 'Failed to register storage: $e',
      );
    }
  }

  /// Check if catalog table is initialized.
  Future<bool> _isCatalogInitialized() async {
    try {
      if (database == null) return false;

      final result = await database!.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', catalogTableName],
      );

      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Unregister a table/storage from the catalog.
  Future<void> unregisterStorage(String name) async {
    try {
      if (database == null) {
        throw StorageStateException(message: 'Database not initialized');
      }

      await database!.delete(
        catalogTableName,
        where: 'name = ?',
        whereArgs: [name],
      );
    } catch (e) {
      throw StorageOperationException(
        operation: 'unregisterStorage',
        message: 'Failed to unregister storage: $e',
      );
    }
  }

  /// Update statistics for a storage entry.
  Future<void> updateStorageStats(
    String name, {
    int? itemCount,
    int? sizeInBytes,
    Map<String, dynamic>? statistics,
  }) async {
    try {
      if (database == null) {
        throw StorageStateException(message: 'Database not initialized');
      }

      final updates = <String, dynamic>{
        'last_modified_at': DateTime.now().toIso8601String(),
        'last_stats_update': DateTime.now().toIso8601String(),
      };

      if (itemCount != null) updates['item_count'] = itemCount;
      if (sizeInBytes != null) updates['size_in_bytes'] = sizeInBytes;
      if (statistics != null) {
        updates['statistics'] = CatalogEntry._encodeJson(statistics);
      }

      await database!.update(
        catalogTableName,
        updates,
        where: 'name = ?',
        whereArgs: [name],
      );
    } catch (e) {
      throw StorageOperationException(
        operation: 'updateStorageStats',
        message: 'Failed to update storage stats: $e',
      );
    }
  }

  /// Get catalog entry for a specific storage.
  Future<CatalogEntry?> getCatalogEntry(String name) async {
    try {
      if (database == null) {
        throw StorageStateException(message: 'Database not initialized');
      }

      final results = await database!.query(
        catalogTableName,
        where: 'name = ?',
        whereArgs: [name],
      );

      if (results.isEmpty) return null;
      return CatalogEntry.fromMap(results.first);
    } catch (e) {
      return null;
    }
  }

  /// Get all catalog entries.
  Future<List<CatalogEntry>> getAllCatalogEntries() async {
    try {
      if (database == null) {
        throw StorageStateException(message: 'Database not initialized');
      }

      final results = await database!.query(
        catalogTableName,
        orderBy: 'name ASC',
      );

      return results.map((map) => CatalogEntry.fromMap(map)).toList();
    } catch (e) {
      throw StorageOperationException(
        operation: 'getAllCatalogEntries',
        message: 'Failed to get catalog entries: $e',
      );
    }
  }

  /// Get catalog entries by type.
  Future<List<CatalogEntry>> getCatalogEntriesByType(String type) async {
    try {
      if (database == null) {
        throw StorageStateException(message: 'Database not initialized');
      }

      final results = await database!.query(
        catalogTableName,
        where: 'type = ?',
        whereArgs: [type],
        orderBy: 'name ASC',
      );

      return results.map((map) => CatalogEntry.fromMap(map)).toList();
    } catch (e) {
      throw StorageOperationException(
        operation: 'getCatalogEntriesByType',
        message: 'Failed to get catalog entries by type: $e',
      );
    }
  }

  /// Refresh statistics for a specific storage by recalculating.
  Future<void> refreshStorageStats(String name) async {
    try {
      if (database == null) {
        throw StorageStateException(message: 'Database not initialized');
      }

      // Get actual count
      final countResult = await database!.rawQuery(
        'SELECT COUNT(*) as count FROM $name',
      );
      final count = countResult.first['count'] as int;

      // Calculate size (approximate for SQLite)
      final sizeResult = await database!.rawQuery(
        "SELECT SUM(LENGTH(quote(name)) + LENGTH(quote(type))) as size FROM pragma_table_info('$name')",
      );
      final size = sizeResult.first['size'] as int?;

      await updateStorageStats(name, itemCount: count, sizeInBytes: size);
    } catch (e) {
      // Ignore errors for non-existent tables
    }
  }

  /// Refresh all catalog statistics.
  Future<void> refreshAllStats() async {
    try {
      final entries = await getAllCatalogEntries();

      for (final entry in entries) {
        // Skip the catalog table itself
        if (entry.name == catalogTableName) continue;

        await refreshStorageStats(entry.name);
      }
    } catch (e) {
      throw StorageOperationException(
        operation: 'refreshAllStats',
        message: 'Failed to refresh all stats: $e',
      );
    }
  }

  /// Get total storage statistics across all tables.
  Future<Map<String, dynamic>> getTotalStats() async {
    try {
      if (database == null) {
        throw StorageStateException(message: 'Database not initialized');
      }

      final results = await database!.rawQuery('''
        SELECT 
          COUNT(*) as total_storages,
          SUM(item_count) as total_items,
          SUM(size_in_bytes) as total_size,
          type
        FROM $catalogTableName
        GROUP BY type
      ''');

      final byType = <String, Map<String, int>>{};
      int totalStorages = 0;
      int totalItems = 0;
      int totalSize = 0;

      for (final row in results) {
        final type = row['type'] as String;
        final storages = row['total_storages'] as int;
        final items = row['total_items'] as int? ?? 0;
        final size = row['total_size'] as int? ?? 0;

        byType[type] = {'storages': storages, 'items': items, 'size': size};

        totalStorages += storages;
        totalItems += items;
        totalSize += size;
      }

      return {
        'total_storages': totalStorages,
        'total_items': totalItems,
        'total_size_bytes': totalSize,
        'by_type': byType,
      };
    } catch (e) {
      throw StorageOperationException(
        operation: 'getTotalStats',
        message: 'Failed to get total stats: $e',
      );
    }
  }

  /// Search catalog entries by name pattern.
  Future<List<CatalogEntry>> searchCatalog(String namePattern) async {
    try {
      if (database == null) {
        throw StorageStateException(message: 'Database not initialized');
      }

      final results = await database!.query(
        catalogTableName,
        where: 'name LIKE ?',
        whereArgs: ['%$namePattern%'],
        orderBy: 'name ASC',
      );

      return results.map((map) => CatalogEntry.fromMap(map)).toList();
    } catch (e) {
      throw StorageOperationException(
        operation: 'searchCatalog',
        message: 'Failed to search catalog: $e',
      );
    }
  }

  /// Get storage entries modified since a specific date.
  Future<List<CatalogEntry>> getRecentlyModified(DateTime since) async {
    try {
      if (database == null) {
        throw StorageStateException(message: 'Database not initialized');
      }

      final results = await database!.query(
        catalogTableName,
        where: 'last_modified_at > ?',
        whereArgs: [since.toIso8601String()],
        orderBy: 'last_modified_at DESC',
      );

      return results.map((map) => CatalogEntry.fromMap(map)).toList();
    } catch (e) {
      throw StorageOperationException(
        operation: 'getRecentlyModified',
        message: 'Failed to get recently modified: $e',
      );
    }
  }

  /// Update metadata for a storage entry.
  Future<void> updateStorageMetadata(
    String name,
    Map<String, dynamic> metadata,
  ) async {
    try {
      if (database == null) {
        throw StorageStateException(message: 'Database not initialized');
      }

      await database!.update(
        catalogTableName,
        {
          'metadata': CatalogEntry._encodeJson(metadata),
          'last_modified_at': DateTime.now().toIso8601String(),
        },
        where: 'name = ?',
        whereArgs: [name],
      );
    } catch (e) {
      throw StorageOperationException(
        operation: 'updateStorageMetadata',
        message: 'Failed to update metadata: $e',
      );
    }
  }

  /// Check if a storage is registered in the catalog.
  Future<bool> isStorageRegistered(String name) async {
    try {
      if (database == null) {
        throw StorageStateException(message: 'Database not initialized');
      }

      final results = await database!.query(
        catalogTableName,
        columns: ['name'],
        where: 'name = ?',
        whereArgs: [name],
        limit: 1,
      );

      return results.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get catalog summary with quick stats.
  Future<String> getCatalogSummary() async {
    try {
      final stats = await getTotalStats();
      final entries = await getAllCatalogEntries();

      final buffer = StringBuffer();
      buffer.writeln('=== Storage Catalog Summary ===');
      buffer.writeln('Total Storages: ${stats['total_storages']}');
      buffer.writeln('Total Items: ${stats['total_items']}');
      buffer.writeln(
        'Total Size: ${_formatBytes(stats['total_size_bytes'] as int)}',
      );
      buffer.writeln('\nBy Type:');

      final byType = stats['by_type'] as Map<String, dynamic>;
      for (final entry in byType.entries) {
        final data = entry.value as Map<String, int>;
        buffer.writeln(
          '  ${entry.key}: ${data['storages']} storages, ${data['items']} items',
        );
      }

      buffer.writeln('\nAll Entries:');
      for (final entry in entries) {
        buffer.writeln(
          '  - ${entry.name} (${entry.type}): ${entry.itemCount} items, ${_formatBytes(entry.sizeInBytes ?? 0)}',
        );
      }

      return buffer.toString();
    } catch (e) {
      return 'Error generating summary: $e';
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
