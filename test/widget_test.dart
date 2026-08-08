import 'package:flutter_test/flutter_test.dart';

import 'package:driver_monitor_app/main.dart';

void main() {
  testWidgets('DriverGuard polished app renders', (WidgetTester tester) async {
    await tester.pumpWidget(const DriverGuardPolishedApp());

    expect(find.text('DriverGuard'), findsOneWidget);
    expect(find.text('AI DRIVER SAFETY'), findsOneWidget);
  });
}
