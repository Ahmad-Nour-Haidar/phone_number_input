import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone_number_input/phone_number_input.dart';
import 'package:phone_number_input/src/formatters/as_you_type_formatter.dart';

void main() {
  Country country(String isoCode) => Countries.byIsoCode(isoCode)!;
  final formatter = AsYouTypeFormatter(() => country('US'));

  TextEditingValue value(String text, [int? offset]) => TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: offset ?? text.length),
  );

  TextEditingValue type(String text) {
    var current = value('');
    for (final char in text.split('')) {
      final offset = current.selection.end;
      current = formatter.formatEditUpdate(
        current,
        value(current.text.replaceRange(offset, offset, char), offset + 1),
      );
    }
    return current;
  }

  String digitsOf(String text) => text.replaceAll(RegExp(r'\D'), '');

  group('formatDigits', () {
    String format(String digits, String isoCode) =>
        AsYouTypeFormatter.formatDigits(digits, country(isoCode));

    test('formats national numbers with or without the national prefix', () {
      expect(format('944123456', 'SY'), '944 123 456');
      expect(format('0944123456', 'SY'), '0944 123 456');
      expect(format('0501234567', 'SA'), '050 123 4567');
    });

    test('formats numbers that only format after the dial code', () {
      expect(format('501234567', 'SA'), '50 123 4567');
      expect(format('7400123456', 'GB'), '7400 123456');
    });

    test('uses the national style of the country', () {
      expect(format('2025550123', 'US'), '(202) 555-0123');
    });

    test('removes an area code that is part of the dial code', () {
      expect(format('2351234', 'AI'), '235-1234');
    });

    test('keeps digits that cannot be formatted', () {
      expect(format('12', 'SY'), '12');
      expect(format('', 'SY'), '');
    });
  });

  test('formats while typing, with the cursor at the end', () {
    final result = type('2025550123');

    expect(result.text, '(202) 555-0123');
    expect(result.selection, const TextSelection.collapsed(offset: 14));
  });

  test('follows the country the getter returns', () {
    var selected = country('US');
    final followingFormatter = AsYouTypeFormatter(() => selected);
    TextEditingValue paste(String text) =>
        followingFormatter.formatEditUpdate(value(''), value(text));

    expect(paste('2025550123').text, '(202) 555-0123');
    selected = country('SY');
    expect(paste('0944123456').text, '0944 123 456');
  });

  test('keeps the cursor after a digit inserted in the middle', () {
    final result = formatter.formatEditUpdate(
      value('(202) 555-0123', 4),
      value('(2029) 555-0123', 5),
    );

    expect(digitsOf(result.text), '20295550123');
    expect(digitsOf(result.text.substring(0, result.selection.end)), '2029');
  });

  test('backspace over a separator removes the digit before it', () {
    final result = formatter.formatEditUpdate(
      value('(202) 555-0123', 10),
      value('(202) 5550123', 9),
    );

    expect(digitsOf(result.text), '202550123');
    expect(digitsOf(result.text.substring(0, result.selection.end)), '20255');
  });

  test('reformats after deleting a digit', () {
    final result = formatter.formatEditUpdate(
      value('(202) 555-0123'),
      value('(202) 555-012'),
    );

    expect(digitsOf(result.text), '202555012');
    expect(result.selection.end, result.text.length);
  });

  test('keeps an international number until its country is known', () {
    expect(formatter.formatEditUpdate(value(''), value('+96')).text, '+96');
  });

  test('returns the value unchanged when only the selection moves', () {
    final moved = value('(202) 555-0123', 2);

    expect(
      identical(
        formatter.formatEditUpdate(value('(202) 555-0123'), moved),
        moved,
      ),
      isTrue,
    );
  });

  test('clears the field when no digits are left', () {
    final result = formatter.formatEditUpdate(value('2'), value('', 0));

    expect(result.text, isEmpty);
  });
}
