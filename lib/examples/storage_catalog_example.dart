// lib/examples/storage_catalog_example.dart

import 'package:sqflite/sqflite.dart';
import '../src/storage/implementations/storage_catalog_mixin.dart';
import '../src/storage/implementations/table_management_mixin.dart';
import '../src/storage/abstractions/storage_interface.dart';
import '../src/storage/types/storage_metadata.dart';

/// Example storage class with catalog tracking
class CatalogedStorage extends Storage
    with StorageCatalogMixin, TableManagementMixin {
  Database? _database;

  @override
  Database? get database => _database;

  @override
  Future<void> initialize() async {
    _database = await openDatabase('cataloged_storage.db', version: 1);

    // Initialize the catalog table first
    await initializeCatalog();

    // Register the catalog itself
    await registerStorage(
      StorageCatalogMixin.catalogTableName,
      'system',
      metadata: {'description': 'Storage catalog system table'},
    );
  }

  @override
  Future<void> dispose() async {
    await _database?.close();
    _database = null;
  }

  @override
  Future<void> clear() async {
    // Clear all tables but keep catalog
    final entries = await getAllCatalogEntries();
    for (final entry in entries) {
      if (entry.name != StorageCatalogMixin.catalogTableName) {
        await _database?.delete(entry.name);
        await updateStorageStats(entry.name, itemCount: 0);
      }
    }
  }

  @override
  bool get isInitialized => _database != null && _database!.isOpen;

  @override
  bool get isDisposed => _database == null || !_database!.isOpen;

  @override
  StorageMetadata? getMetadata() {
    return StorageMetadata(
      type: 'cataloged_sqlite',
      version: '1.0.0',
      description: 'SQLite storage with catalog tracking',
      supportsTransactions: true,
      supportsBatchOperations: true,
    );
  }

  Future<bool> isHealthy() async {
    return isInitialized && !isDisposed;
  }
}

/// Example usage
Future<void> exampleUsage() async {
  final storage = CatalogedStorage();
  await storage.initialize();

  // Create some tables and register them
  print('=== Creating Tables ===');
  await storage.database!.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY,
      name TEXT,
      email TEXT
    )
  ''');
  await storage.registerStorage(
    'users',
    'table',
    metadata: {'description': 'User accounts', 'primary_key': 'id'},
  );

  await storage.database!.execute('''
    CREATE TABLE products (
      id INTEGER PRIMARY KEY,
      title TEXT,
      price REAL
    )
  ''');
  await storage.registerStorage(
    'products',
    'table',
    metadata: {'description': 'Product catalog', 'primary_key': 'id'},
  );

  await storage.database!.execute('''
    CREATE TABLE settings (
      key TEXT PRIMARY KEY,
      value TEXT
    )
  ''');
  await storage.registerStorage(
    'settings',
    'key_value',
    metadata: {'description': 'Application settings'},
  );

  // Insert some data
  print('\n=== Inserting Data ===');
  await storage.database!.insert('users', {
    'id': 1,
    'name': 'John Doe',
    'email': 'john@example.com',
  });
  await storage.database!.insert('users', {
    'id': 2,
    'name': 'Jane Smith',
    'email': 'jane@example.com',
  });

  await storage.database!.insert('products', {
    'id': 1,
    'title': 'Laptop',
    'price': 999.99,
  });
  await storage.database!.insert('products', {
    'id': 2,
    'title': 'Mouse',
    'price': 29.99,
  });
  await storage.database!.insert('products', {
    'id': 3,
    'title': 'Keyboard',
    'price': 79.99,
  });

  await storage.database!.insert('settings', {'key': 'theme', 'value': 'dark'});
  await storage.database!.insert('settings', {
    'key': 'language',
    'value': 'en',
  });

  // Update statistics
  print('\n=== Updating Statistics ===');
  await storage.refreshAllStats();

  // Get catalog summary
  print('\n=== Catalog Summary ===');
  final summary = await storage.getCatalogSummary();
  print(summary);

  // Get specific entry
  print('\n=== Users Table Info ===');
  final usersEntry = await storage.getCatalogEntry('users');
  if (usersEntry != null) {
    print('Name: ${usersEntry.name}');
    print('Type: ${usersEntry.type}');
    print('Items: ${usersEntry.itemCount}');
    print('Created: ${usersEntry.createdAt}');
    print('Last Modified: ${usersEntry.lastModifiedAt}');
    print('Metadata: ${usersEntry.metadata}');
  }

  // Get all tables
  print('\n=== All Tables ===');
  final tables = await storage.getCatalogEntriesByType('table');
  for (final table in tables) {
    print('- ${table.name}: ${table.itemCount} rows');
  }

  // Get all key-value stores
  print('\n=== All Key-Value Stores ===');
  final kvStores = await storage.getCatalogEntriesByType('key_value');
  for (final store in kvStores) {
    print('- ${store.name}: ${store.itemCount} items');
  }

  // Get total statistics
  print('\n=== Total Statistics ===');
  final stats = await storage.getTotalStats();
  print('Total Storages: ${stats['total_storages']}');
  print('Total Items: ${stats['total_items']}');
  print('Total Size: ${stats['total_size_bytes']} bytes');
  print('By Type: ${stats['by_type']}');

  // Search catalog
  print('\n=== Search for "user" ===');
  final searchResults = await storage.searchCatalog('user');
  for (final result in searchResults) {
    print('- ${result.name} (${result.type})');
  }

  // Update metadata
  print('\n=== Updating Metadata ===');
  await storage.updateStorageMetadata('users', {
    'description': 'User accounts and profiles',
    'primary_key': 'id',
    'has_indexes': true,
  });

  // Check if storage is registered
  print('\n=== Checking Registration ===');
  print('Is "users" registered? ${await storage.isStorageRegistered('users')}');
  print(
    'Is "orders" registered? ${await storage.isStorageRegistered('orders')}',
  );

  // Get recently modified (last hour)
  print('\n=== Recently Modified (last hour) ===');
  final recentlyModified = await storage.getRecentlyModified(
    DateTime.now().subtract(Duration(hours: 1)),
  );
  for (final entry in recentlyModified) {
    print('- ${entry.name} modified at ${entry.lastModifiedAt}');
  }

  // Clean up
  await storage.dispose();
  print('\n=== Done ===');
}

void main() async {
  await exampleUsage();
}
