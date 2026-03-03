import 'package:flutter_test/flutter_test.dart';

import 'package:helpi_admin/app/app.dart';

void main() {
  testWidgets('Admin app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HelpiAdminApp());
    await tester.pumpAndSettle();

    // Login screen should appear
    expect(find.text('Helpi Admin'), findsOneWidget);
  });
}
