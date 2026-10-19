import 'package:flutter_test/flutter_test.dart';
import 'package:pulsecraft/main.dart';

void main() {
  testWidgets('PulseCraft app boots', (WidgetTester tester) async {
    await tester.pumpWidget(const PulseCraftApp());
    await tester.pumpAndSettle();
    expect(find.textContaining('PulseCraft'), findsWidgets);
  });
}
