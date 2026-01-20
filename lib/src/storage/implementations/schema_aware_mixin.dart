// lib/src/storage/implementations/schema_aware_mixin.dart

import '../abstractions/storage_capabilities.dart';
import '../exceptions/storage_exceptions.dart';

/// Mixin providing schema awareness capabilities.
///
/// Allows storage to manage and validate schemas.
mixin SchemaAwareMixin implements SchemaAwareStorage {
  SchemaDescriptor? _currentSchema;

  @override
  Future<SchemaDescriptor> getSchema() async {
    try {
      _currentSchema ??= await loadSchemaFromStorage();
      return _currentSchema!;
    } catch (e) {
      throw StorageOperationException(
        operation: 'storage',
        message: 'Failed to get schema: $e',
      );
    }
  }

  @override
  Future<void> applySchema(SchemaDescriptor schema) async {
    try {
      // Validate schema first
      if (!schema.validate()) {
        throw StorageOperationException(
          operation: 'storage',
          message: 'Invalid schema',
        );
      }

      // Apply schema changes
      await saveSchemaToStorage(schema);

      _currentSchema = schema;
    } catch (e) {
      throw StorageOperationException(
        operation: 'storage',
        message: 'Failed to apply schema: $e',
      );
    }
  }

  @override
  Future<bool> validateSchema(SchemaDescriptor expected) async {
    try {
      final current = await getSchema();

      // Basic validation: check version and structure
      if (current.version != expected.version) {
        return false;
      }

      if (current.tables.length != expected.tables.length) {
        return false;
      }

      // Validate each table
      for (final expectedTable in expected.tables) {
        final currentTable = current.tables.firstWhere(
          (t) => t.name == expectedTable.name,
          orElse: () => throw StorageOperationException(
            operation: 'storage',
            message: 'Table not found',
          ),
        );

        if (!_validateTable(currentTable, expectedTable)) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  bool _validateTable(TableDescriptor current, TableDescriptor expected) {
    // Check field count
    if (current.fields.length != expected.fields.length) {
      return false;
    }

    // Validate each field
    for (final expectedField in expected.fields) {
      final currentField = current.fields.where(
        (f) => f.name == expectedField.name,
      );
      if (currentField.isEmpty) {
        return false;
      }

      final field = currentField.first;
      if (field.type != expectedField.type ||
          field.required != expectedField.required) {
        return false;
      }
    }

    return true;
  }

  /// Load schema from storage.
  /// Must be implemented by storage class.
  Future<SchemaDescriptor> loadSchemaFromStorage();

  /// Save schema to storage.
  /// Must be implemented by storage class.
  Future<void> saveSchemaToStorage(SchemaDescriptor schema);
}

/// Simple implementation of SchemaDescriptor.
class SimpleSchemaDescriptor implements SchemaDescriptor {
  @override
  final int version;

  @override
  final String name;

  @override
  final List<TableDescriptor> tables;

  const SimpleSchemaDescriptor({
    required this.version,
    required this.name,
    required this.tables,
  });

  @override
  bool validate() {
    if (version < 0) return false;
    if (name.isEmpty) return false;
    if (tables.isEmpty) return false;

    // Validate all tables
    for (final table in tables) {
      if (table.name.isEmpty) return false;
      if (table.fields.isEmpty) return false;
    }

    return true;
  }
}
