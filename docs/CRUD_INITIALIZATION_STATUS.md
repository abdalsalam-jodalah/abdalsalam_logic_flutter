# Storage Operations - Implementation Status

**Question:** Are insert/update/create operations implemented? What about table creation and storage initialization?

---

## 📊 Quick Answer

| Operation | Defined in Interface | Implemented in Package | User Must Implement |
|-----------|:--------------------:|:----------------------:|:-------------------:|
| **CRUD Operations** | ✅ YES | ❌ NO | ✅ YES (in backend) |
| `create(entity)` | ✅ EntityStorage | ❌ Abstract only | ✅ User (backend-specific) |
| `update(entity)` | ✅ EntityStorage | ❌ Abstract only | ✅ User (backend-specific) |
| `upsert(entity)` | ✅ EntityStorage | ❌ Abstract only | ✅ User (backend-specific) |
| `delete(id)` | ✅ EntityStorage | ❌ Abstract only | ✅ User (backend-specific) |
| `set(key, value)` | ✅ KeyValueStorage | ❌ Abstract only | ✅ User (backend-specific) |
| **Table Operations** | ✅ YES | ❌ NO | ✅ YES (in backend) |
| `createTable(name)` | ✅ TableManagement | ❌ Abstract only | ✅ User (backend-specific) |
| `dropTable(name)` | ✅ TableManagement | ❌ Abstract only | ✅ User (backend-specific) |
| `alterTable(name)` | ✅ TableManagement | ❌ Abstract only | ✅ User (backend-specific) |
| **Initialization** | ✅ YES | ❌ NO | ✅ YES (in backend) |
| `initialize()` | ✅ Storage base | ❌ Abstract only | ✅ User (backend-specific) |
| `clear()` | ✅ Storage base | ❌ Abstract only | ✅ User (backend-specific) |

---

## Detailed Breakdown

### 1. CRUD Operations (Create, Read, Update, Delete)

#### ✅ DEFINED in Interfaces
```dart
// EntityStorage<ID, T> interface defines these:
abstract class EntityStorage<ID, T> extends Storage {
  Future<T?> get(ID id);           // READ - defined
  Future<void> create(T entity);   // CREATE - defined
  Future<void> update(T entity);   // UPDATE - defined
  Future<void> upsert(T entity);   // UPSERT - defined
  Future<bool> delete(ID id);      // DELETE - defined
}

// KeyValueStorage<T> interface defines these:
abstract class KeyValueStorage<T> extends Storage {
  Future<T?> get(String key);            // READ - defined
  Future<void> set(String key, T value); // CREATE/UPDATE - defined
  Future<bool> delete(String key);       // DELETE - defined
}
```

#### ❌ NOT Implemented in Package
The package only provides **interfaces**. The actual logic is **abstract**.

```dart
// This is what's in the package:
abstract class EntityStorage<ID, T> {
  Future<void> create(T entity); // No implementation!
}

// NOT like this:
class EntityStorage<ID, T> {
  Future<void> create(T entity) async {
    // Logic here - NOT PROVIDED
  }
}
```

#### ✅ USER Must Implement (Backend-Specific)
Users implement these for their chosen backend.

```dart
// SQLite Implementation (User Code)
class SqliteUserStorage implements EntityStorage<int, User> {
  final Database _db;
  
  @override
  Future<void> create(User user) async {
    await _db.insert('users', {
      'id': user.id,
      'name': user.name,
      'email': user.email,
    });
  }
  
  @override
  Future<void> update(User user) async {
    await _db.update(
      'users',
      {'name': user.name, 'email': user.email},
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }
  
  @override
  Future<void> upsert(User user) async {
    try {
      await create(user);
    } catch (e) {
      await update(user);
    }
  }
  
  @override
  Future<bool> delete(int id) async {
    final count = await _db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }
}

// Hive Implementation (User Code)
class HiveUserStorage implements EntityStorage<int, User> {
  final Box _box;
  
  @override
  Future<void> create(User user) async {
    await _box.put(user.id, user.toMap());
  }
  
  @override
  Future<void> update(User user) async {
    await _box.put(user.id, user.toMap());
  }
  
  // ... etc
}
```

---

### 2. Table Creation & Initialization

#### ✅ DEFINED in Interfaces
```dart
// Storage base class
abstract class Storage {
  Future<void> initialize();  // Defined as abstract
  Future<void> clear();       // Defined as abstract
  Future<void> dispose();     // Defined as abstract
}

// TableManagementStorage
abstract class TableManagementStorage {
  Future<void> createTable(String name, {TableSchema? schema});
  Future<void> dropTable(String name, {bool ifExists});
  Future<void> alterTable(String name, TableSchemaChange change);
}
```

#### ❌ NOT Implemented in Package
Only interfaces provided, no actual implementation.

#### ✅ USER Must Implement (Backend-Specific)

**Example 1: SQLite with Automatic Table Creation**
```dart
class SqliteDatabase extends EntityStorage<int, User>
    implements TableManagementStorage {
  
  final Database _db;
  bool _initialized = false;
  
  @override
  Future<void> initialize() async {
    // SQLite-specific initialization
    await _db.execute('PRAGMA foreign_keys = ON');
    
    // Create tables
    await createTable('users', schema: TableSchema(
      name: 'users',
      fields: [
        FieldSchema(name: 'id', type: FieldType.integer, required: true),
        FieldSchema(name: 'name', type: FieldType.string, required: true),
        FieldSchema(name: 'email', type: FieldType.string, required: true),
        FieldSchema(name: 'settings', type: FieldType.json),
      ],
      primaryKeys: ['id'],
      indexes: [IndexSchema(name: 'idx_email', fields: ['email'])],
    ));
    
    _initialized = true;
  }
  
  @override
  Future<void> createTable(String name, {TableSchema? schema}) async {
    final columns = <String>[];
    
    // Build column definitions from schema
    if (schema != null) {
      for (final field in schema.fields) {
        columns.add('${field.name} ${_mapFieldType(field.type)} ${field.required ? 'NOT NULL' : ''}');
      }
    }
    
    // Build SQL
    final sql = 'CREATE TABLE IF NOT EXISTS $name (${columns.join(", ")})';
    await _db.execute(sql);
  }
  
  @override
  Future<void> clear() async {
    await _db.delete('users');
    await _db.delete('products');
    // ... etc
  }
  
  @override
  Future<void> dispose() async {
    await _db.close();
  }
  
  String _mapFieldType(FieldType type) {
    switch (type) {
      case FieldType.integer:
        return 'INTEGER';
      case FieldType.string:
        return 'TEXT';
      case FieldType.json:
        return 'TEXT'; // Stored as JSON string
      case FieldType.blob:
        return 'BLOB';
      case FieldType.dateTime:
        return 'INTEGER'; // Unix timestamp
      default:
        return 'TEXT';
    }
  }
}

// Usage
void main() async {
  final db = await openDatabase('app.db');
  final storage = SqliteDatabase(db);
  
  // Initialize - creates all tables automatically
  await storage.initialize();
  
  // Now can use storage
  await storage.create(User(id: 1, name: 'Ahmed', email: 'ahmed@example.com'));
  
  // Clean up
  await storage.dispose();
}
```

**Example 2: Hive with Dynamic Initialization**
```dart
class HiveStorage<ID, T> extends EntityStorage<ID, T>
    implements SchemaAwareStorage {
  
  final String boxName;
  late Box _box;
  bool _initialized = false;
  
  @override
  Future<void> initialize() async {
    // Initialize Hive box
    _box = await Hive.openBox(boxName);
    _initialized = true;
  }
  
  @override
  Future<void> clear() async {
    await _box.clear();
  }
  
  @override
  Future<void> dispose() async {
    await _box.close();
  }
  
  @override
  Future<SchemaDescriptor> getSchema() async {
    // Hive doesn't have pre-defined schema
    // Return dynamic schema based on actual data
    return SchemaDescriptor(
      tables: await _inferSchema(),
    );
  }
  
  Future<List<TableInfo>> _inferSchema() async {
    // Scan data and infer schema
    final tableInfo = TableInfo(
      name: boxName,
      rowCount: _box.length,
    );
    return [tableInfo];
  }
}

// Usage
void main() async {
  Hive.init('./storage');
  
  final userStorage = HiveStorage<int, User>(boxName: 'users');
  await userStorage.initialize(); // Opens Hive box
  
  final schema = await userStorage.getSchema();
  print('Storage schema: $schema');
  
  await userStorage.dispose(); // Closes Hive box
}
```

**Example 3: SharedPreferences with Auto-Migration**
```dart
class PreferencesStorage extends KeyValueStorage<String> {
  
  final SharedPreferences _prefs;
  int _schemaVersion = 0;
  static const _schemaVersionKey = '__schema_version__';
  
  @override
  Future<void> initialize() async {
    // Read current schema version
    _schemaVersion = _prefs.getInt(_schemaVersionKey) ?? 0;
    
    // Run migrations if needed
    if (_schemaVersion < 1) {
      await _migrateTo1();
      _schemaVersion = 1;
      await _prefs.setInt(_schemaVersionKey, 1);
    }
    
    if (_schemaVersion < 2) {
      await _migrateTo2();
      _schemaVersion = 2;
      await _prefs.setInt(_schemaVersionKey, 2);
    }
  }
  
  Future<void> _migrateTo1() async {
    // Migration v0 -> v1: Rename 'appTheme' to 'theme'
    final oldValue = _prefs.getString('appTheme');
    if (oldValue != null) {
      await _prefs.setString('theme', oldValue);
      await _prefs.remove('appTheme');
    }
  }
  
  Future<void> _migrateTo2() async {
    // Migration v1 -> v2: Add default language if not present
    if (!_prefs.containsKey('language')) {
      await _prefs.setString('language', 'en');
    }
  }
  
  @override
  Future<void> clear() async {
    await _prefs.clear();
  }
  
  @override
  Future<void> dispose() async {
    // Nothing to dispose for SharedPreferences
  }
  
  @override
  Future<String?> get(String key) async => _prefs.getString(key);
  
  @override
  Future<void> set(String key, String value) async {
    await _prefs.setString(key, value);
  }
}

// Usage
void main() async {
  final prefs = await SharedPreferences.getInstance();
  final storage = PreferencesStorage(prefs);
  
  await storage.initialize(); // Runs migrations automatically
  
  // Schema is now at latest version
}
```

---

## 🎯 What You Need To Do

### For Basic CRUD (Create/Read/Update/Delete):

```dart
// 1. Create entity storage class
class MyUserStorage implements EntityStorage<int, User> {
  // 2. Choose backend (SQLite, Hive, etc.)
  final Database _db; // or Box, or SharedPreferences, etc.
  
  // 3. Implement lifecycle
  @override
  Future<void> initialize() async { /* setup backend */ }
  
  @override
  Future<void> clear() async { /* clear all data */ }
  
  @override
  Future<void> dispose() async { /* cleanup */ }
  
  // 4. Implement CRUD
  @override
  Future<User?> get(int id) async { /* fetch from backend */ }
  
  @override
  Future<void> create(User user) async { /* insert to backend */ }
  
  @override
  Future<void> update(User user) async { /* update in backend */ }
  
  @override
  Future<void> upsert(User user) async { /* insert or update */ }
  
  @override
  Future<bool> delete(int id) async { /* delete from backend */ }
  
  // 5. Implement remaining methods (getMultiple, count, etc.)
}
```

### For Table Management:

```dart
// 1. Extend both EntityStorage and TableManagementStorage
class MyDatabase extends EntityStorage<int, User>
    implements TableManagementStorage {
  
  // 2. In initialize(), create tables
  @override
  Future<void> initialize() async {
    await createTable('users');
    await createTable('products');
  }
  
  // 3. Implement createTable() with backend SQL/DDL
  @override
  Future<void> createTable(String name, {TableSchema? schema}) async {
    // Generate SQL from schema
    // Execute with backend
  }
}
```

---

## ✅ Summary

| What | Status | Who Does It |
|------|--------|------------|
| **Interface definitions** | ✅ Done | Package (already in abstractions) |
| **CRUD method signatures** | ✅ Done | Package (EntityStorage, KeyValueStorage) |
| **Table management interfaces** | ✅ Done | Package (TableManagementStorage) |
| **Initialization hooks** | ✅ Done | Package (Storage.initialize()) |
| ||||
| **CRUD implementation** | ❌ Not done | User (for their backend) |
| **Table creation logic** | ❌ Not done | User (SQLite/Hive/etc specific) |
| **Initialization logic** | ❌ Not done | User (backend setup) |
| **Schema mapping** | ❌ Not done | User (FieldType → SQL/Hive/etc) |
| **Migration logic** | ❌ Not done | User (if needed) |

**The abstraction provides the blueprint. You provide the implementation!** 🎯
