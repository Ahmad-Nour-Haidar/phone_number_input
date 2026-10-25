import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone_number_input/phone_number_input.dart';
import 'package:phone_number_input/src/formatters/international_number_formatter.dart';

void main() {
  late Country selected;
  late List<Country> detected;
  late Set<String> allowed;

  setUp(() {
    selected = Countries.byIsoCode('PS')!;
    detected = [];
    allowed = {'PS', 'SA', 'CA', 'US'};
  });

  TextEditingValue format(String text) {
    final formatter = InternationalNumberFormatter(
      country: () => selected,
      isAllowed: (country) => allowed.contains(country.alpha2Code),
      onCountryDetected: detected.add,
    );
    return formatter.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      ),
    );
  }

  test('switches to the country of a pasted number', () {
    final result = format('+966 50 123 4567');

    expect(result.text, '501234567');
    expect(result.selection, const TextSelection.collapsed(offset: 9));
    expect(detected.single.alpha2Code, 'SA');
  });

  test('accepts the 00 international prefix', () {
    expect(format('00966501234567').text, '501234567');
    expect(detected.single.alpha2Code, 'SA');
  });

  test('switches as soon as the calling code is complete', () {
    expect(format('+966').text, isEmpty);
    expect(detected.single.alpha2Code, 'SA');
  });

  test('keeps an incomplete calling code as typed', () {
    expect(format('+9').text, '+9');
    expect(format('00').text, '00');
    expect(detected, isEmpty);
  });

  test('keeps the selected country when it shares the dial code', () {
    selected = Countries.byIsoCode('CA')!;

    expect(format('+1').text, isEmpty);
    expect(detected, isEmpty);
  });

  test('leaves numbers of countries that are not allowed', () {
    expect(format('+44 7400 123456').text, '+44 7400 123456');
    expect(detected, isEmpty);
  });

  test('leaves national numbers', () {
    expect(format('0599123456').text, '0599123456');
    expect(detected, isEmpty);
  });
}
