import 'package:flutter_test/flutter_test.dart';
import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';
import 'package:abdalsalam_logic_flutter/examples/app_state_detection_example.dart';

import 'package:abdalsalam_logic_flutter_example/main.dart';

void main() {
  testWidgets('App state detection example loads', (WidgetTester tester) async {
    // Build our app with required appStateManager
    final logger = LoggerServiceImpl();
    final appStateManager = AppStateManagerImpl.create(logger);
    await appStateManager.initialize();
    
    await tester.pumpWidget(MyApp(appStateManager: appStateManager));

    // Verify app loaded with example
    expect(find.byType(AppStateDetectionExample), findsOneWidget);
  });
}
