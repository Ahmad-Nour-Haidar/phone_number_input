import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone_number_input/src/formatters/max_digits_formatter.dart';

void main() {
  const formatter = MaxDigitsFormatter(4);

  TextEditingValue value(String text) => TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: text.length),
  );

  test('does not count separators', () {
    final next = value('12 - 34');
    expect(formatter.formatEditUpdate(value('12 - 3'), next), next);
  });

  test('ignores a keystroke past the limit', () {
    final old = value('12 34');
    expect(formatter.formatEditUpdate(old, value('12 345')), old);
  });

  test('truncates text that was already too long', () {
    expect(
      formatter.formatEditUpdate(value('123456'), value('1234567')).text,
      '1234',
    );
  });

  test('zero means no limit', () {
    final next = value('1234567890');
    expect(const MaxDigitsFormatter(0).formatEditUpdate(value(''), next), next);
  });
}
