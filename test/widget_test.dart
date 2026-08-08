import 'package:flutter_test/flutter_test.dart';

import 'package:driver_monitor_app/main.dart';

void main() {
  testWidgets('DriverGuard polished app renders', (tester) async {
    await tester.pumpWidget(const DriverGuardPolishedApp());

    // Let the splash navigation complete so no timer remains pending.
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump();

    expect(find.byType(DriverGuardPolishedApp), findsOneWidget);
  });
}
