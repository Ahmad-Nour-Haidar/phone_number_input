import 'package:flutter_test/flutter_test.dart';
import 'package:smart_phone_input/smart_phone_input.dart';
import 'package:smart_phone_input/src/utils/phone_number_util.dart';

void main() {
  group('toE164', () {
    String? toE164(String isoCode, String dialCode, String digits) =>
        PhoneNumberUtil.toE164(
          isoCode: isoCode,
          dialCode: dialCode,
          digits: digits,
        );

    test('accepts digits with or without the national prefix', () {
      expect(toE164('PS', '+970', '599123456'), '+970599123456');
      expect(toE164('PS', '+970', '0599123456'), '+970599123456');
    });

    test('accepts digits with or without the area code of the dial code', () {
      expect(toE164('AI', '+1264', '2351234'), '+12642351234');
      expect(toE164('AI', '+1264', '2642351234'), '+12642351234');
    });

    test('returns null for invalid, short or empty digits', () {
      expect(toE164('US', '+1', '123'), isNull);
      expect(toE164('US', '+1', '1'), isNull);
      expect(toE164('US', '+1', ''), isNull);
    });
  });

  test('regionOfNumber returns the region of valid numbers only', () {
    expect(PhoneNumberUtil.regionOfNumber('+966501234567'), 'SA');
    expect(PhoneNumberUtil.regionOfNumber('+96650'), isNull);
    expect(PhoneNumberUtil.regionOfNumber('not a number'), isNull);
  });

  test('regionForCallingCode returns the main region', () {
    expect(PhoneNumberUtil.regionForCallingCode(1), 'US');
    expect(PhoneNumberUtil.regionForCallingCode(970), 'PS');
    expect(PhoneNumberUtil.regionForCallingCode(999), 'ZZ');
  });

  test('format writes a number in each format', () {
    expect(
      PhoneNumberUtil.format('+15551234567', PhoneNumberFormat.e164),
      '+15551234567',
    );
    expect(
      PhoneNumberUtil.format('+966501234567', PhoneNumberFormat.national),
      '050 123 4567',
    );
  });

  test('typeOf maps every type of the library', () {
    expect(PhoneNumberUtil.typeOf('+966501234567'), PhoneNumberType.mobile);
    expect(PhoneNumberUtil.typeOf('+18002345678'), PhoneNumberType.tollFree);
    expect(PhoneNumberUtil.typeOf('nonsense'), PhoneNumberType.unknown);
  });

  test('formatAsYouType formats national and international input', () {
    expect(PhoneNumberUtil.formatAsYouType('0599123456', 'PS'), '0599 123 456');
    expect(
      PhoneNumberUtil.formatAsYouType('+970599123456', 'PS'),
      '+970 599 123 456',
    );
  });
}
