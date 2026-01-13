// lib/src/storage/implementations/migratable_storage_mixin.dart

import '../abstractions/storage_capabilities.dart';
import '../exceptions/storage_exceptions.dart';

/// Mixin providing storage migration capabilities.
///
/// Allows executing versioned schema migrations atomically.
mixin MigratableStorageMixin implements MigratableStorage {
  int _schemaVersion = 0;

  @override
  int get schemaVersion => _schemaVersion;

  /// Set schema version.
  set schemaVersion(int version) {
    _schemaVersion = version;
  }

  @override
  Future<void> migrate(MigrationPlan plan) async {
    try {
      // Validate plan
      if (!plan.validate()) {
        throw StorageOperationException(
          operation: 'storage',
          message: 'Invalid migration plan',
        );
      }

      if (plan.fromVersion != _schemaVersion) {
        throw StorageOperationException(
          operation: 'migrate',
          message:
              'Migration plan fromVersion (${plan.fromVersion}) does not match current version ($_schemaVersion)',
        );
      }

      // Begin transaction for atomic migration
      await beginMigrationTransaction();

      try {
        // Execute all steps
        for (final step in plan.steps) {
          final success = await step.execute();
          if (!success) {
            throw StorageOperationException(
              operation: 'migrate',
              message: 'Migration step failed: ${step.description}',
            );
          }
        }

        // Update version
        _schemaVersion = plan.toVersion;
        await saveSchemaVersion(_schemaVersion);

        // Commit transaction
        await commitMigrationTransaction();
      } catch (e) {
        // Rollback on failure
        await rollbackMigrationTransaction();

        // Attempt to rollback executed steps
        for (final step in plan.steps.reversed) {
          if (step.canRollback) {
            try {
              await step.rollback();
            } catch (rollbackError) {
              // Log rollback failure but continue
            }
          }
        }

        throw StorageOperationException(
          operation: 'storage',
          message: 'Migration failed: $e',
        );
      }
    } catch (e) {
      throw StorageOperationException(
        operation: 'storage',
        message: 'Migration error: $e',
      );
    }
  }

  /// Begin a migration transaction.
  /// Must be implemented by storage class.
  Future<void> beginMigrationTransaction();

  /// Commit the migration transaction.
  /// Must be implemented by storage class.
  Future<void> commitMigrationTransaction();

  /// Rollback the migration transaction.
  /// Must be implemented by storage class.
  Future<void> rollbackMigrationTransaction();

  /// Save schema version to storage.
  /// Must be implemented by storage class.
  Future<void> saveSchemaVersion(int version);
}

/// Simple implementation of MigrationPlan.
class SimpleMigrationPlan implements MigrationPlan {
  @override
  final int fromVersion;

  @override
  final int toVersion;

  @override
  final List<MigrationStep> steps;

  const SimpleMigrationPlan({
    required this.fromVersion,
    required this.toVersion,
    required this.steps,
  });

  @override
  bool validate() {
    if (fromVersion < 0 || toVersion <= fromVersion) return false;
    if (steps.isEmpty) return false;
    return true;
  }
}

/// Simple implementation of MigrationStep.
class SimpleMigrationStep implements MigrationStep {
  @override
  final String description;

  @override
  final bool canRollback;

  final Future<bool> Function() _executeFunc;
  final Future<void> Function()? _rollbackFunc;

  const SimpleMigrationStep({
    required this.description,
    required Future<bool> Function() executeFunc,
    this.canRollback = false,
    Future<void> Function()? rollbackFunc,
  }) : _executeFunc = executeFunc,
       _rollbackFunc = rollbackFunc;

  @override
  Future<bool> execute() => _executeFunc();

  @override
  Future<void> rollback() {
    if (!canRollback || _rollbackFunc == null) {
      throw StorageUnsupportedException(
        operation: 'rollback',
        message: 'Rollback not supported for this step',
      );
    }
    return _rollbackFunc();
  }
}
