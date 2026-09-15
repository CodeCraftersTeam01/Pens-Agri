import 'package:flutter_test/flutter_test.dart';
import 'package:pertanian_presisi/main.dart';

void main() {
  testWidgets('Petani app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AgriPrecisionPetaniApp());
    expect(find.text('AgriSensor Petani'), findsOneWidget);
  });
}
