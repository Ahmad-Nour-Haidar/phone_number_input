import 'package:flutter_test/flutter_test.dart';
import 'package:smart_phone_input/smart_phone_input.dart';
import 'package:smart_phone_input_example/main.dart';

void main() {
  testWidgets('typing Arabic digits gives a formatted, valid number', (
    tester,
  ) async {
    await tester.pumpWidget(const ExampleApp());

    // The example starts with Palestine.
    await tester.enterText(find.byKey(PhoneInputKeys.textField), '٠٥٩٩١٢٣٤٥٦');
    await tester.pumpAndSettle();

    expect(find.text('0599 123 456'), findsOneWidget);
    expect(find.text('+970599123456'), findsOneWidget);
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
