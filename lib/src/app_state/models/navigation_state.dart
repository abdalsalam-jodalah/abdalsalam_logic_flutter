// lib/src/app_state/models/navigation_state.dart

/// Navigation state tracking for routes and tabs.
///
/// Maintains the current route, route parameters, navigation history,
/// and tab navigation state. Provides methods for pushing/popping routes
/// and managing tab navigation.
///
/// Example:
/// ```dart
/// final navState = NavigationState(
///   currentRoute: '/home',
///   routeParams: {},
///   routeHistory: ['/'],
///   currentTabIndex: 0,
///   tabRoutes: {0: '/home'},
///   timestamp: DateTime.now(),
/// );
///
/// // Push a new route
/// final updated = navState.pushRoute('/products', params: {'id': '123'});
///
/// // Pop the last route
/// final popped = navState.popRoute();
/// ```
class NavigationState {
  final String currentRoute;
  final Map<String, dynamic> routeParams;
  final List<String> routeHistory;
  final int currentTabIndex;
  final Map<int, String> tabRoutes;
  final DateTime timestamp;

  const NavigationState({
    required this.currentRoute,
    required this.routeParams,
    required this.routeHistory,
    required this.currentTabIndex,
    required this.tabRoutes,
    required this.timestamp,
  });

  NavigationState copyWith({
    String? currentRoute,
    Map<String, dynamic>? routeParams,
    List<String>? routeHistory,
    int? currentTabIndex,
    Map<int, String>? tabRoutes,
    DateTime? timestamp,
  }) {
    return NavigationState(
      currentRoute: currentRoute ?? this.currentRoute,
      routeParams: routeParams ?? this.routeParams,
      routeHistory: routeHistory ?? this.routeHistory,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      tabRoutes: tabRoutes ?? this.tabRoutes,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  NavigationState pushRoute(String route, {Map<String, dynamic>? params}) {
    final newHistory = List<String>.from(routeHistory);
    if (newHistory.isEmpty || newHistory.last != route) {
      newHistory.add(route);
    }

    return copyWith(
      currentRoute: route,
      routeParams: params ?? {},
      routeHistory: newHistory,
      timestamp: DateTime.now(),
    );
  }

  NavigationState updateTab(int tabIndex, String route) {
    final newTabRoutes = Map<int, String>.from(tabRoutes);
    newTabRoutes[tabIndex] = route;

    return copyWith(
      currentTabIndex: tabIndex,
      currentRoute: route,
      tabRoutes: newTabRoutes,
      timestamp: DateTime.now(),
    );
  }

  NavigationState popRoute() {
    if (routeHistory.length <= 1) return this;

    final newHistory = List<String>.from(routeHistory);
    newHistory.removeLast();
    final previousRoute = newHistory.last;

    return copyWith(
      currentRoute: previousRoute,
      routeHistory: newHistory,
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currentRoute': currentRoute,
      'routeParams': routeParams,
      'routeHistory': routeHistory,
      'currentTabIndex': currentTabIndex,
      'tabRoutes': tabRoutes,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
