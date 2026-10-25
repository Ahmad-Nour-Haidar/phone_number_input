import 'package:flutter_test/flutter_test.dart';
import 'package:phone_number_input/phone_number_input.dart';
import 'package:phone_number_input_example/main.dart';

void main() {
  testWidgets('typing Arabic digits gives a formatted, valid number', (
    tester,
  ) async {
    await tester.pumpWidget(const ExampleApp());

    await tester.enterText(find.byKey(PhoneInputKeys.textField), '٠٩٤٤١٢٣٤٥٦');
    await tester.pumpAndSettle();

    expect(find.text('0944 123 456'), findsOneWidget);
    expect(find.text('+963944123456'), findsOneWidget);
    expect(find.text('mobile'), findsOneWidget);
  });

  testWidgets('pasting an international number switches the country', (
    tester,
  ) async {
    await tester.pumpWidget(const ExampleApp());

    await tester.enterText(
      find.byKey(PhoneInputKeys.textField),
      '+966 50 123 4567',
    );
    await tester.pumpAndSettle();

    expect(find.text('SA (+966)'), findsOneWidget);
    expect(find.text('+966501234567'), findsOneWidget);
  });
}
