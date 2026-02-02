// lib/src/storage/index_comprehensive.dart

/// Comprehensive Storage Abstraction Layer
///
/// Full-featured, type-safe abstraction for storage management across all backends.
///
/// DESIGN PRINCIPLES:
/// - Capability-based: Optional features are separate interfaces
/// - Type-safe: Generics ensure compile-time correctness
/// - Backend-agnostic: No platform or implementation dependencies
/// - Comprehensive: Supports all storage categories and operations
///
/// ARCHITECTURE:
/// - Base Storage: Lifecycle management (initialize, clear, dispose)
/// - KeyValueStorage\<T\>: Key-value operations
/// - EntityStorage\<ID, T\>: Structured entity operations
/// - Optional Capabilities: Transaction, Query, Schema, Migration, etc.
///
/// See COMPREHENSIVE_STORAGE_GUIDE.md for detailed documentation.
library;

// ----------------------------------------------------------------------------
// CORE INTERFACES
// ----------------------------------------------------------------------------

/// Base storage interface - lifecycle only
export 'abstractions/storage_interface.dart';

/// Key-value storage - comprehensive
export 'abstractions/key_value_storage_comprehensive.dart';

/// Entity storage - comprehensive
export 'abstractions/entity_storage_comprehensive.dart';

// ----------------------------------------------------------------------------
// CAPABILITY INTERFACES (Opt-in)
// ----------------------------------------------------------------------------

/// Optional capabilities (transactions, queries, schema, etc.)
export 'abstractions/storage_capabilities.dart';

/// Transaction support
export 'abstractions/storage_transaction.dart';

/// Query support - comprehensive
export 'abstractions/query_comprehensive.dart';

/// Table/collection management
export 'abstractions/table_management.dart';

// ----------------------------------------------------------------------------
// EXCEPTIONS
// ----------------------------------------------------------------------------

/// Unified exception hierarchy
export 'exceptions/storage_exceptions.dart';

// ----------------------------------------------------------------------------
// TYPES & METADATA
// ----------------------------------------------------------------------------

/// Storage metadata and capability detection
export 'types/storage_metadata.dart';

/// Result types
export 'types/storage_result_minimal.dart';
