// example/lib/storage_designer.dart - Storage schema & data manager

import 'package:flutter/material.dart';
import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';

class StorageDesignerPage extends StatefulWidget {
  const StorageDesignerPage({super.key});

  @override
  State<StorageDesignerPage> createState() => _StorageDesignerPageState();
}

class _StorageDesignerPageState extends State<StorageDesignerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage Designer'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Part 1: Create Tables'),
            Tab(text: 'Part 2: Manage Data'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _SchemaPart(),
          _DataPart(),
        ],
      ),
    );
  }
}

// PART 1: Schema & Table Creation
class _SchemaPart extends StatefulWidget {
  const _SchemaPart();

  @override
  State<_SchemaPart> createState() => _SchemaPartState();
}

class _SchemaPartState extends State<_SchemaPart> {
  int selectedBackend = 0;
  bool creating = false;
  String? message;

  // SQLite
  final sqliteDbCtrl = TextEditingController(text: 'mydb.db');
  final sqliteTableCtrl = TextEditingController(text: 'items');
  final List<_Column> sqliteColumns = [
    _Column('id', 'TEXT', true, true),
    _Column('name', 'TEXT', true, false),
    _Column('age', 'INTEGER', false, false),
  ];

  // Hive
  final hiveBoxCtrl = TextEditingController(text: 'mybox');

  // SharedPreferences - simple key-value

  @override
  void dispose() {
    sqliteDbCtrl.dispose();
    sqliteTableCtrl.dispose();
    hiveBoxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildBackendTabs(),
        const SizedBox(height: 24),
        if (selectedBackend == 0) _buildSqliteSchema(),
        if (selectedBackend == 1) _buildHiveSchema(),
        if (selectedBackend == 2) _buildPrefsSchema(),
        const SizedBox(height: 16),
        if (message != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue),
            ),
            child: Text(message!),
          ),
      ],
    );
  }

  Widget _buildBackendTabs() {
    return Row(
      children: [
        Expanded(
          child: _backendButton('SQLite', 0),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _backendButton('Hive', 1),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _backendButton('SharedPrefs', 2),
        ),
      ],
    );
  }

  Widget _backendButton(String label, int index) {
    final active = selectedBackend == index;
    return FilledButton.icon(
      onPressed: () => setState(() => selectedBackend = index),
      icon: Icon(active ? Icons.check_circle : Icons.circle_outlined),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: active ? Colors.blue : Colors.grey.shade400,
      ),
    );
  }

  Widget _buildSqliteSchema() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SQLite Database Setup',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(
          controller: sqliteDbCtrl,
          decoration: InputDecoration(
            labelText: 'Database File Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.storage),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: sqliteTableCtrl,
          decoration: InputDecoration(
            labelText: 'Table Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.table_chart),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text('Columns',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const Spacer(),
            FilledButton.icon(
              onPressed: () {
                setState(() {
                  sqliteColumns.add(_Column('col_${sqliteColumns.length}', 'TEXT', false, false));
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...sqliteColumns.asMap().entries.map((e) => _buildColumnRow(e.key, e.value)),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton.icon(
            onPressed: creating ? null : _createSqliteTable,
            icon: const Icon(Icons.create),
            label: const Text('Create Table'),
          ),
        ),
      ],
    );
  }

  Widget _buildColumnRow(int idx, _Column col) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    onChanged: (v) => col.name = v,
                    decoration: InputDecoration(
                      labelText: 'Column Name',
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 110,
                  child: DropdownButtonFormField<String>(
                    value: col.type,
                    isExpanded: false,
                    items: ['TEXT', 'INTEGER', 'REAL', 'BLOB']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => col.type = v ?? 'TEXT'),
                    decoration: InputDecoration(
                      labelText: 'Type',
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    setState(() => sqliteColumns.removeAt(idx));
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Not Null', style: TextStyle(fontSize: 12)),
                    value: col.notNull,
                    onChanged: (v) => setState(() => col.notNull = v ?? false),
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Primary Key', style: TextStyle(fontSize: 12)),
                    value: col.primaryKey,
                    onChanged: (v) => setState(() => col.primaryKey = v ?? false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createSqliteTable() async {
    if (sqliteColumns.isEmpty) {
      setState(() => message = 'Add at least one column');
      return;
    }
    setState(() {
      creating = true;
      message = 'Creating table...';
    });
    try {
      final dbName = sqliteDbCtrl.text.trim();
      final tableName = sqliteTableCtrl.text.trim();
      final sql = _generateSql(tableName);

      final storage = SqliteStorageImpl<Map<String, dynamic>>(dbName, tableName, (m) => m, (m) => m);
      await storage.initializeWithTableSql(sql);
      await storage.dispose();

      setState(() => message = '✓ Table "$tableName" created in "$dbName"');
    } catch (e) {
      setState(() => message = '✗ Error: $e');
    } finally {
      setState(() => creating = false);
    }
  }

  String _generateSql(String table) {
    final parts = sqliteColumns.map((c) {
      var def = '${c.name} ${c.type}';
      if (c.notNull) def += ' NOT NULL';
      if (c.primaryKey) def += ' PRIMARY KEY';
      return def;
    }).toList();
    return 'CREATE TABLE IF NOT EXISTS $table (${parts.join(", ")})';
  }

  Widget _buildHiveSchema() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Hive Box Setup',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(
          controller: hiveBoxCtrl,
          decoration: InputDecoration(
            labelText: 'Box Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.data_usage),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber),
          ),
          child: const Text(
              'Hive stores any object. Just enter a box name and it will be created when you use it in Part 2.'),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton.icon(
            onPressed: _initHiveBox,
            icon: const Icon(Icons.create),
            label: const Text('Initialize Box'),
          ),
        ),
      ],
    );
  }

  Future<void> _initHiveBox() async {
    setState(() {
      creating = true;
      message = 'Initializing Hive box...';
    });
    try {
      final boxName = hiveBoxCtrl.text.trim();
      final storage = HiveStorageImpl<Map<String, dynamic>>(boxName);
      await storage.initialize();
      await storage.dispose();
      setState(() => message = '✓ Box "$boxName" initialized');
    } catch (e) {
      setState(() => message = '✗ Error: $e');
    } finally {
      setState(() => creating = false);
    }
  }

  Widget _buildPrefsSchema() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SharedPreferences Setup',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green),
          ),
          child: const Text(
              'SharedPreferences is key-value storage. No setup needed - just click Initialize and start using it in Part 2.'),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton.icon(
            onPressed: _initPrefs,
            icon: const Icon(Icons.create),
            label: const Text('Initialize SharedPreferences'),
          ),
        ),
      ],
    );
  }

  Future<void> _initPrefs() async {
    setState(() {
      creating = true;
      message = 'Initializing SharedPreferences...';
    });
    try {
      final storage = SharedPreferencesStorage();
      await storage.initialize();
      await storage.dispose();
      setState(() => message = '✓ SharedPreferences initialized');
    } catch (e) {
      setState(() => message = '✗ Error: $e');
    } finally {
      setState(() => creating = false);
    }
  }
}

// PART 2: Data Management & CRUD
class _DataPart extends StatefulWidget {
  const _DataPart();

  @override
  State<_DataPart> createState() => _DataPartState();
}

class _DataPartState extends State<_DataPart> {
  int selectedBackend = 0;
  bool loading = false;
  String? message;

  // SQLite
  final sqliteDbCtrl = TextEditingController(text: 'mydb.db');
  final sqliteTableCtrl = TextEditingController(text: 'items');
  SqliteStorageImpl<Map<String, dynamic>>? sqliteStorage;

  // Hive
  final hiveBoxCtrl = TextEditingController(text: 'mybox');
  HiveStorageImpl<Map<String, dynamic>>? hiveStorage;

  // SharedPreferences
  SharedPreferencesStorage? prefsStorage;

  // Data form
  final idCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final ageCtrl = TextEditingController();

  // Prefs specific
  final prefKeyCtrl = TextEditingController();
  final prefValueCtrl = TextEditingController();
  String prefType = 'String';

  @override
  void dispose() {
    sqliteDbCtrl.dispose();
    sqliteTableCtrl.dispose();
    hiveBoxCtrl.dispose();
    idCtrl.dispose();
    nameCtrl.dispose();
    ageCtrl.dispose();
    prefKeyCtrl.dispose();
    prefValueCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildBackendTabs(),
        const SizedBox(height: 24),
        if (selectedBackend == 0) _buildSqliteData(),
        if (selectedBackend == 1) _buildHiveData(),
        if (selectedBackend == 2) _buildPrefsData(),
        const SizedBox(height: 16),
        if (message != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Text(message!),
          ),
      ],
    );
  }

  Widget _buildBackendTabs() {
    return Row(
      children: [
        Expanded(child: _backendButton('SQLite', 0)),
        const SizedBox(width: 8),
        Expanded(child: _backendButton('Hive', 1)),
        const SizedBox(width: 8),
        Expanded(child: _backendButton('SharedPrefs', 2)),
      ],
    );
  }

  Widget _backendButton(String label, int index) {
    final active = selectedBackend == index;
    return FilledButton.icon(
      onPressed: () => setState(() => selectedBackend = index),
      icon: Icon(active ? Icons.check_circle : Icons.circle_outlined),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: active ? Colors.blue : Colors.grey.shade400,
      ),
    );
  }

  Widget _buildSqliteData() {
    final connected = sqliteStorage?.isInitialized == true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SQLite Data Manager',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (!connected) ...[
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: sqliteDbCtrl,
                  decoration: InputDecoration(
                    labelText: 'Database',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: sqliteTableCtrl,
                  decoration: InputDecoration(
                    labelText: 'Table',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _connectSqlite,
              child: const Text('Connect to Table'),
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Connected: ${sqliteTableCtrl.text}'),
                ),
                FilledButton(
                  onPressed: _disconnectSqlite,
                  child: const Text('Disconnect'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildDataForm(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _crudButton('Add', Colors.green, _sqliteInsert)),
              const SizedBox(width: 8),
              Expanded(child: _crudButton('Update', Colors.blue, _sqliteUpdate)),
              const SizedBox(width: 8),
              Expanded(child: _crudButton('Delete', Colors.red, _sqliteDelete)),
              const SizedBox(width: 8),
              Expanded(child: _crudButton('List All', Colors.purple, _sqliteList)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildHiveData() {
    final connected = hiveStorage?.isInitialized == true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Hive Data Manager',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (!connected) ...[
          TextField(
            controller: hiveBoxCtrl,
            decoration: InputDecoration(
              labelText: 'Box Name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _connectHive,
              child: const Text('Connect to Box'),
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Connected: ${hiveBoxCtrl.text}'),
                ),
                FilledButton(
                  onPressed: _disconnectHive,
                  child: const Text('Disconnect'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildDataForm(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _crudButton('Add', Colors.green, _hiveInsert)),
              const SizedBox(width: 8),
              Expanded(child: _crudButton('Update', Colors.blue, _hiveUpdate)),
              const SizedBox(width: 8),
              Expanded(child: _crudButton('Delete', Colors.red, _hiveDelete)),
              const SizedBox(width: 8),
              Expanded(child: _crudButton('List All', Colors.purple, _hiveList)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPrefsData() {
    final connected = prefsStorage?.isInitialized == true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SharedPreferences Data Manager',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (!connected) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _connectPrefs,
              child: const Text('Initialize'),
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 12),
                const Expanded(child: Text('Connected')),
                FilledButton(
                  onPressed: _disconnectPrefs,
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildPrefsForm(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _crudButton('Set', Colors.green, _prefsSet)),
              const SizedBox(width: 8),
              Expanded(child: _crudButton('Get', Colors.blue, _prefsGet)),
              const SizedBox(width: 8),
              Expanded(child: _crudButton('Delete', Colors.red, _prefsDel)),
              const SizedBox(width: 8),
              Expanded(child: _crudButton('List All', Colors.purple, _prefsList)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDataForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Test Data', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: idCtrl,
                decoration: InputDecoration(
                  labelText: 'ID',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: ageCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrefsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Key-Value Data', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: prefKeyCtrl,
                decoration: InputDecoration(
                  labelText: 'Key',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: prefType,
                items: ['String', 'int', 'double', 'bool']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => prefType = v ?? 'String'),
                decoration: InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: prefValueCtrl,
          decoration: InputDecoration(
            labelText: 'Value',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _crudButton(String label, Color color, VoidCallback? onPressed) {
    return FilledButton(
      onPressed: loading ? null : onPressed,
      style: FilledButton.styleFrom(backgroundColor: color),
      child: Text(label),
    );
  }

  // SQLite operations
  Future<void> _connectSqlite() async {
    setState(() => message = 'Connecting...');
    try {
      final db = sqliteDbCtrl.text.trim();
      final table = sqliteTableCtrl.text.trim();
      final storage = SqliteStorageImpl<Map<String, dynamic>>(db, table, (m) => m, (m) => m);
      await storage.initialize();
      setState(() {
        sqliteStorage = storage;
        message = '✓ Connected to table "$table"';
      });
    } catch (e) {
      setState(() => message = '✗ Error: $e');
    }
  }

  void _disconnectSqlite() {
    sqliteStorage?.dispose();
    setState(() {
      sqliteStorage = null;
      message = 'Disconnected';
    });
  }

  Future<void> _sqliteInsert() async {
    final id = idCtrl.text.trim();
    final name = nameCtrl.text.trim();
    final age = int.tryParse(ageCtrl.text) ?? 0;
    try {
      await sqliteStorage!.create({'id': id, 'name': name, 'age': age});
      setState(() => message = '✓ Added: id=$id');
      idCtrl.clear();
      nameCtrl.clear();
      ageCtrl.clear();
    } catch (e) {
      setState(() => message = '✗ Error: $e');
    }
  }

  Future<void> _sqliteUpdate() async {
    final id = idCtrl.text.trim();
    final name = nameCtrl.text.trim();
    final age = int.tryParse(ageCtrl.text) ?? 0;
    try {
      await sqliteStorage!.update({'id': id, 'name': name, 'age': age});
      setState(() => message = '✓ Updated: id=$id');
    } catch (e) {
      setState(() => message = '✗ Error: $e');
    }
  }

  Future<void> _sqliteDelete() async {
    final id = idCtrl.text.trim();
    try {
      await sqliteStorage!.delete(id);
      setState(() => message = '✓ Deleted: id=$id');
      idCtrl.clear();
    } catch (e) {
      setState(() => message = '✗ Error: $e');
    }
  }

  Future<void> _sqliteList() async {
    try {
      final all = await sqliteStorage!.getAll();
      setState(() => message = '✓ Found ${all.length} records');
    } catch (e) {
      setState(() => message = '✗ Error: $e');
    }
  }

  // Hive operations
  Future<void> _connectHive() async {
    setState(() => message = 'Connecting...');
    try {
      final box = hiveBoxCtrl.text.trim();
      final storage = HiveStorageImpl<Map<String, dynamic>>(box);
      await storage.initialize();
      setState(() {
        hiveStorage = storage;
        message = '✓ Connected to box "$box"';
      });
    } catch (e) {
      setState(() => message = '✗ Error: $e');
    }
  }

  void _disconnectHive() {
    hiveStorage?.dispose();
    setState(() {
      hiveStorage = null;
      message = 'Disconnected';
    });
  }

  Future<void> _hiveInsert() async {
    final id = idCtrl.text.trim();
    final name = nameCtrl.text.trim();
    final age = int.tryParse(ageCtrl.text) ?? 0;
    try {
      await hiveStorage!.create({'id': id, 'name': name, 'age': age});
      setState(() => message = '✓ Added: id=$id');
      idCtrl.clear();
      nameCtrl.clear();
      ageCtrl.clear();
    } catch (e) {
      setState(() => message = '✗ Error: $e');
    }
  }

  Future<void> _hiveUpdate() async {
    final id = idCtrl.text.trim();
    final name = nameCtrl.text.trim();
    final age = int.tryParse(ageCtrl.text) ?? 0;
    try {
      await hiveStorage!.update({'id': id, 'name': name, 'age': age});
      setState(() => message = '✓ Updated: id=$id');
    } catch (e) {
      setState(() => message = '✗ Error: $e');
    }
  }

  Future<void> _hiveDelete() async {
    final id = idCtrl.text.trim();
    try {
      await hiveStorage!.delete(id);
      setState(() => message = '✓ Deleted: id=$id');
      idCtrl.clear();
    } catch (e) {
      setState(() => message = '✗ Error: $e');
    }
  }

  Future<void> _hiveList() async {
    try {
      final all = await hiveStorage!.getAll();
      setState(() => message = '✓ Found ${all.length} items');
    } catch (e) {
      setState(() => message = '✗ Error: $e');
    }
  }

  // SharedPreferences operations
  Future<void> _connectPrefs() async {
    setState(() => message = 'Initializing...');
    try {
      final storage = SharedPreferencesStorage();
      await storage.initialize();
      setState(() {
        prefsStorage = storage;
        message = '✓ Initialized';
      });
    } catch (e) {
      setState(() => message = '✗ Error: $e');
    }
  }

  void _disconnectPrefs() {
    prefsStorage?.dispose();
    setState(() {
      prefsStorage = null;
      message = 'Closed';
    });
  }

  Future<void> _prefsSet() async {
    final key = prefKeyCtrl.text.trim();
    final val = prefValueCtrl.text;
    if (key.isEmpty) {
      setState(() => message = 'Enter a key');
      return;
    }
    try {
      dynamic value = val;
      if (prefType == 'int') value = int.tryParse(val) ?? 0;
      if (prefType == 'double') value = double.tryParse(val) ?? 0.0;
      if (prefType == 'bool') value = val.toLowerCase() == 'true';
      await prefsStorage!.set(key, value);
      setState(() => message = '✓ Set: $key=$value');
      prefKeyCtrl.clear();
      prefValueCtrl.clear();
    } catch (e) {
      setState(() => message = '✗ Error: $e');
    }
  }

  Future<void> _prefsGet() async {
    final key = prefKeyCtrl.text.trim();
    if (key.isEmpty) {
      setState(() => message = 'Enter a key');
      return;
    }
    try {
      final v = await prefsStorage!.get(key);
      setState(() => message = '✓ Get: $key=$v');
    } catch (e) {
      setState(() => message = '✗ Error: $e');
    }
  }

  Future<void> _prefsDel() async {
    final key = prefKeyCtrl.text.trim();
    if (key.isEmpty) {
      setState(() => message = 'Enter a key');
      return;
    }
    try {
      await prefsStorage!.delete(key);
      setState(() => message = '✓ Deleted: $key');
      prefKeyCtrl.clear();
    } catch (e) {
      setState(() => message = '✗ Error: $e');
    }
  }

  Future<void> _prefsList() async {
    try {
      final all = await prefsStorage!.getAll();
      setState(() => message = '✓ Found ${all.length} keys');
    } catch (e) {
      setState(() => message = '✗ Error: $e');
    }
  }
}

class _Column {
  String name;
  String type;
  bool notNull;
  bool primaryKey;

  _Column(this.name, this.type, this.notNull, this.primaryKey);
}
