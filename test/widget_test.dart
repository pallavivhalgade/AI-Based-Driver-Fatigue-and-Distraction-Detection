import 'package:flutter_test/flutter_test.dart';

import 'package:driver_monitor_app/main.dart';

void main() {
  testWidgets('DriverGuard polished app renders', (tester) async {
    await tester.pumpWidget(const DriverGuardApp());

    // Allow the splash navigation timer to complete.
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    expect(find.byType(DriverGuardApp), findsOneWidget);
  });
}
