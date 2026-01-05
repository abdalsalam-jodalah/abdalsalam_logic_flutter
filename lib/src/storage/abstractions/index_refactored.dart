// lib/src/storage/abstractions/index_refactored.dart

// ============================================================================
// STORAGE ABSTRACTION LAYER - REFACTORED
// ============================================================================
// This is the THIN, capability-based abstraction layer.
//
// Design principles:
// - Interface Segregation: Don't force unneeded features
// - Opt-in capabilities: Implementations choose what to support
// - External policy: App decides schema/migrations, storage executes
// - Minimal surface area: Only essential operations in base interfaces
//
// See REFACTORING_GUIDE.md for detailed explanation.
// ============================================================================

// Core lifecycle interface (MINIMAL)
export 'storage_interface.dart';

// Opt-in capability interfaces
export 'storage_capabilities.dart';

// Transaction support (used by TransactionalStorage capability)
export 'storage_transaction.dart';

// Minimal key-value storage
export 'key_value_storage_minimal.dart';

// Minimal entity storage
export 'entity_storage_minimal.dart';

// Simplified query DSL (used by QueryableStorage capability)
export 'query_simplified.dart';

// ============================================================================
// DEPRECATED (OLD FAT INTERFACES)
// ============================================================================
// The following files are kept for backward compatibility but should not
// be used in new code. They violate ISP by forcing too many features.
//
// - key_value_storage.dart (use key_value_storage_minimal.dart instead)
// - entity_storage.dart (use entity_storage_minimal.dart instead)
// - query.dart (use query_simplified.dart instead)
// ============================================================================
