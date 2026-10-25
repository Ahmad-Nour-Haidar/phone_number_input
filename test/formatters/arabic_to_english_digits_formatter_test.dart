import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_phone_input/smart_phone_input.dart';

void main() {
  const formatter = ArabicToEnglishDigitsFormatter();

  TextEditingValue format(TextEditingValue value) =>
      formatter.formatEditUpdate(TextEditingValue.empty, value);

  group('ArabicToEnglishDigitsFormatter', () {
    test('converts Arabic-Indic digits', () {
      expect(
        ArabicToEnglishDigitsFormatter.convert('٠١٢٣٤٥٦٧٨٩'),
        '0123456789',
      );
    });

    test('converts Persian digits', () {
      expect(
        ArabicToEnglishDigitsFormatter.convert('۰۱۲۳۴۵۶۷۸۹'),
        '0123456789',
      );
    });

    test('keeps other characters', () {
      expect(
        ArabicToEnglishDigitsFormatter.convert('+٩٧٠ 5٩٩-abc'),
        '+970 599-abc',
      );
    });

    test('returns the same value when nothing changes', () {
      const value = TextEditingValue(text: '+970 599');
      expect(identical(format(value), value), isTrue);
    });

    test('preserves selection and composing ranges', () {
      const value = TextEditingValue(
        text: '٠٥٩٩',
        selection: TextSelection(baseOffset: 1, extentOffset: 3),
        composing: TextRange(start: 0, end: 4),
      );
      final result = format(value);
      expect(result.text, '0599');
      expect(result.selection, value.selection);
      expect(result.composing, value.composing);
    });
  });
}
