// example/lib/storage_inspector.dart - Storage viewer & inspector

import 'package:flutter/material.dart';
import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';

class StorageInspectorPage extends StatefulWidget {
  const StorageInspectorPage({super.key});

  @override
  State<StorageInspectorPage> createState() => _StorageInspectorPageState();
}

class _StorageInspectorPageState extends State<StorageInspectorPage>
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
        title: const Text('Storage Inspector'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Part 1: SQLite Tables'),
            Tab(text: 'Part 2: Browse Data'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _SqlitePart(),
          _BrowsePart(),
        ],
      ),
    );
  }
}


// PART 1: SQLite Tables & Schema Viewer
class _SqlitePart extends StatefulWidget {
  const _SqlitePart();

  @override
  State<_SqlitePart> createState() => _SqlitePartState();
}

class _SqlitePartState extends State<_SqlitePart> {
  final dbNameCtrl = TextEditingController(text: 'mydb.db');
  bool loading = false;
  String? message;
  List<Map<String, dynamic>>? tables;
  String? selectedTable;
  List<Map<String, dynamic>>? tableSchema;

  @override
  void dispose() {
    dbNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('View SQLite Tables',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: dbNameCtrl,
                decoration: InputDecoration(
                  labelText: 'Database File',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.storage),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: loading ? null : _loadTables,
              child: const Text('Load'),
            ),
          ],
        ),
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
        const SizedBox(height: 16),
        if (tables != null && tables!.isNotEmpty) ...[
          const Text('Tables Found:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          ...tables!.map((t) {
            final name = t['name'] ?? 'unknown';
            final isSelected = selectedTable == name;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(name),
                subtitle: Text('${t['type'] ?? 'table'} • ${t['sql'] ?? ''}'),
                selected: isSelected,
                onTap: () => setState(() {
                  selectedTable = isSelected ? null : name;
                  tableSchema = null;
                }),
                trailing: isSelected
                    ? FilledButton.icon(
                        onPressed: _loadTableSchema,
                        icon: const Icon(Icons.info),
                        label: const Text('Schema'),
                      )
                    : const Icon(Icons.navigate_next),
              ),
            );
          }),
          if (tableSchema != null && selectedTable != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Schema: $selectedTable',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  ...tableSchema!.map((col) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${col['name'] ?? 'col'}: ${col['type'] ?? 'unknown'}',
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                          ),
                          if (col['pk'] == 1)
                            const Chip(
                              label: Text('PK', style: TextStyle(fontSize: 10)),
                              backgroundColor: Colors.orange,
                              labelPadding: EdgeInsets.symmetric(horizontal: 4),
                            ),
                          if (col['notnull'] == 1)
                            const Chip(
                              label: Text('NOT NULL', style: TextStyle(fontSize: 10)),
                              backgroundColor: Colors.red,
                              labelPadding: EdgeInsets.symmetric(horizontal: 4),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ] else if (tables != null && tables!.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber),
            ),
            child: const Text('No tables found in this database'),
          ),
      ],
    );
  }

  Future<void> _loadTables() async {
    setState(() {
      loading = true;
      message = 'Loading tables...';
    });
    try {
      final db = dbNameCtrl.text.trim();
      final storage = SqliteStorageImpl<Map<String, dynamic>>(db, 'temp', (m) => m, (m) => m);
      await storage.initialize();

      final dbInstance = storage.database;
      final result = await dbInstance!.query('sqlite_master', where: "type='table'");
      await storage.dispose();

      setState(() {
        tables = result;
        selectedTable = null;
        tableSchema = null;
        message = '✓ Found ${result.length} tables';
      });
    } catch (e) {
      setState(() => message = '✗ Error: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _loadTableSchema() async {
    if (selectedTable == null) return;
    setState(() => message = 'Loading schema...');
    try {
      final db = dbNameCtrl.text.trim();
      final storage = SqliteStorageImpl<Map<String, dynamic>>(
          db, selectedTable!, (m) => m, (m) => m);
      await storage.initialize();

      final dbInstance = storage.database;
      final result = await dbInstance!.rawQuery('PRAGMA table_info($selectedTable)');
      await storage.dispose();

      setState(() {
        tableSchema = result;
        message = '✓ Schema loaded for "$selectedTable"';
      });
    } catch (e) {
      setState(() => message = '✗ Error: $e');
    }
  }
}

// PART 2: Browse All Storage Data
class _BrowsePart extends StatefulWidget {
  const _BrowsePart();

  @override
  State<_BrowsePart> createState() => _BrowsePartState();
}

class _BrowsePartState extends State<_BrowsePart> {
  int selectedBackend = 0;
  bool loading = false;
  String? message;

  final sqliteDbCtrl = TextEditingController(text: 'mydb.db');
  final sqliteTableCtrl = TextEditingController(text: 'items');
  List<Map<String, dynamic>>? sqliteData;

  final hiveBoxCtrl = TextEditingController(text: 'mybox');
  List<Map<String, dynamic>>? hiveData;

  Map<String, dynamic>? prefsData;

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
        if (selectedBackend == 0) _buildSqliteBrowser(),
        if (selectedBackend == 1) _buildHiveBrowser(),
        if (selectedBackend == 2) _buildPrefsBrowser(),
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

  Widget _buildSqliteBrowser() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Browse SQLite Data',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
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
            onPressed: loading ? null : _browseSqlite,
            child: const Text('Load Data'),
          ),
        ),
        const SizedBox(height: 16),
        if (sqliteData != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Records: ${sqliteData!.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (sqliteData!.isEmpty)
                  const Text('No records found')
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: sqliteData!.first.keys
                          .map((k) => DataColumn(label: Text(k)))
                          .toList(),
                      rows: sqliteData!
                          .map((row) => DataRow(
                                cells: row.values
                                    .map((v) => DataCell(Text('$v')))
                                    .toList(),
                              ))
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildHiveBrowser() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Browse Hive Data',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
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
            onPressed: loading ? null : _browseHive,
            child: const Text('Load Data'),
          ),
        ),
        const SizedBox(height: 16),
        if (hiveData != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Items: ${hiveData!.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (hiveData!.isEmpty)
                  const Text('No items found')
                else
                  ...hiveData!.asMap().entries.map((e) {
                    final item = e.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Index: ${e.key}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace')),
                            const SizedBox(height: 8),
                            Text('Value: $item',
                                style: const TextStyle(fontFamily: 'monospace')),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPrefsBrowser() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Browse SharedPreferences',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: loading ? null : _browsePrefs,
            child: const Text('Load All Keys'),
          ),
        ),
        const SizedBox(height: 16),
        if (prefsData != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Keys: ${prefsData!.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (prefsData!.isEmpty)
                  const Text('No preferences found')
                else
                  ...prefsData!.entries.map((e) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${e.key} (${e.value.runtimeType})',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace')),
                            const SizedBox(height: 8),
                            Text('= ${e.value}',
                                style: const TextStyle(fontFamily: 'monospace')),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _browseSqlite() async {
    setState(() {
      loading = true;
      message = 'Loading...';
    });
    try {
      final db = sqliteDbCtrl.text.trim();
      final table = sqliteTableCtrl.text.trim();
      final storage = SqliteStorageImpl<Map<String, dynamic>>(db, table, (m) => m, (m) => m);
      await storage.initialize();
      final data = await storage.getAll();
      await storage.dispose();

      setState(() {
        sqliteData = data;
        message = '✓ Loaded ${data.length} records from "$table"';
      });
    } catch (e) {
      setState(() => message = '✗ Error: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _browseHive() async {
    setState(() {
      loading = true;
      message = 'Loading...';
    });
    try {
      final box = hiveBoxCtrl.text.trim();
      final storage = HiveStorageImpl<Map<String, dynamic>>(box);
      await storage.initialize();
      final data = await storage.getAll();
      await storage.dispose();

      setState(() {
        hiveData = data;
        message = '✓ Loaded ${data.length} items from "$box"';
      });
    } catch (e) {
      setState(() => message = '✗ Error: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _browsePrefs() async {
    setState(() {
      loading = true;
      message = 'Loading...';
    });
    try {
      final storage = SharedPreferencesStorage();
      await storage.initialize();
      final data = await storage.getAll();
      await storage.dispose();

      setState(() {
        prefsData = data;
        message = '✓ Loaded ${data.length} keys';
      });
    } catch (e) {
      setState(() => message = '✗ Error: $e');
    } finally {
      setState(() => loading = false);
    }
  }
}
