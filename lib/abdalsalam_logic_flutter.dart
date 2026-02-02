// lib/abdalsalam_logic_flutter.dart
export 'src/core/errors/app_exception.dart';
export 'src/core/errors/error_handler.dart';
export 'src/core/errors/error_handler_impl.dart';
export 'src/core/interfaces/repository_interface.dart';
export 'src/core/interfaces/service_interface.dart';

// Error Logging
export 'src/error_logging/runtime_error_overlay.dart';

export 'src/logging/logger.dart';
export 'src/logging/logger_impl.dart';
export 'src/logging/log_config.dart';
export 'src/logging/log_level.dart';
export 'src/logging/log_module.dart';
export 'src/logging/log_formatter.dart';
export 'src/logging/log_output.dart';
export 'src/logging/log_filter.dart';
export 'src/logging/log_environment.dart';
export 'src/logging/log_target.dart';
export 'src/logging/logger_core_config.dart';
export 'src/logging/logger_module_registry_config.dart';

export 'src/app_state/app_state_manager.dart';
export 'src/app_state/app_state_manager_impl.dart';
export 'src/app_state/app_state_config.dart';
export 'src/app_state/models/app_lifecycle_state.dart';
export 'src/app_state/models/device_info.dart';
export 'src/app_state/models/device_orientation_info.dart';
export 'src/app_state/models/app_version_info.dart';
export 'src/app_state/models/storage_info.dart';
export 'src/app_state/models/system_settings_info.dart';
export 'src/app_state/models/screen_metrics_info.dart';
export 'src/app_state/models/vpn_info.dart';
export 'src/app_state/models/wifi_info.dart';
export 'src/app_state/models/mobile_data_info.dart';
export 'src/app_state/models/audio_state_info.dart';
export 'src/app_state/models/app_runtime_info.dart';
export 'src/app_state/models/navigation_state.dart';
export 'src/app_state/models/locale_info.dart';
export 'src/app_state/models/auth_info.dart';
export 'src/app_state/models/keyboard_info.dart';
export 'src/app_state/models/battery_info.dart';
export 'src/app_state/models/network_info.dart';
export 'src/app_state/models/accessibility_info.dart';
export 'src/app_state/models/memory_info.dart';
export 'src/app_state/models/permissions_info.dart';

export 'src/app_initialization/app_initializer.dart';
export 'src/app_initialization/app_initializer_impl.dart';

export 'src/networking/api_client.dart';
export 'src/networking/api_client_impl.dart';

export 'src/storage/storage_service.dart';
export 'src/storage/shared_preferences_storage.dart';
export 'src/storage/sqlite_storage.dart';
export 'src/storage/hive_storage.dart';

export 'src/auth/auth_service.dart';
export 'src/auth/auth_service_impl.dart';

export 'src/role_management/role_manager.dart';
export 'src/role_management/role_manager_impl.dart';

export 'src/prefetch/prefetch_manager.dart';
export 'src/prefetch/prefetch_manager_impl.dart';
export 'src/prefetch/prefetch_service.dart';
export 'src/prefetch/prefetch_service_impl.dart';
export 'src/prefetch/prefetch_orchestrator.dart';
export 'src/prefetch/prefetch_request.dart';
export 'src/prefetch/prefetch_result.dart';
export 'src/prefetch/prefetch_status.dart';
export 'src/prefetch/prefetch_priority.dart';
export 'src/prefetch/prefetch_timing.dart';
export 'src/prefetch/prefetch_paging_config.dart';
export 'src/prefetch/prefetch_exception.dart';
export 'src/prefetch/prefetch_executor.dart';
export 'src/prefetch/prefetch_http_executor.dart';

export 'src/fcm/fcm_service.dart';
export 'src/fcm/fcm_service_impl.dart';

export 'src/file_operations/file_service.dart';
export 'src/file_operations/file_service_impl.dart';

export 'src/share/share_service.dart';
export 'src/share/share_service_impl.dart';

// export 'src/calendar/calendar_service.dart';
// export 'src/calendar/calendar_service_impl.dart';

// export 'src/contacts/contacts_service.dart';
// export 'src/contacts/contacts_service_impl.dart';

export 'src/update_manager/update_manager.dart';
export 'src/update_manager/update_manager_impl.dart';

export 'src/runtime_control/app_control.dart';
export 'src/runtime_control/app_control_runtime.dart';
export 'src/runtime_control/lifecycle_phase.dart';
export 'src/runtime_control/reset_level.dart';
export 'src/runtime_control/runtime_domain.dart';
export 'src/runtime_control/runtime_config.dart';
export 'src/runtime_control/runtime_exception.dart';
export 'src/runtime_control/domain_registry.dart';
export 'src/runtime_control/state_controller.dart';
export 'src/runtime_control/ui_tree_controller.dart';
export 'src/runtime_control/runtime_controlled_app.dart';
export 'src/runtime_control/platform/app_restart.dart';

// Examples
export 'examples/plugin_test_widget.dart';
