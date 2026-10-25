import 'package:flutter/foundation.dart' show immutable;

import '../formatters/arabic_to_english_digits_formatter.dart';
import '../utils/phone_number_util.dart';
import 'countries.dart';
import 'country.dart';

/// Types of phone numbers as defined by libphonenumber.
enum PhoneNumberType {
  /// Fixed line phones (landlines).
  fixedLine,

  /// Mobile phones.
  mobile,

  /// Numbers that could be either fixed line or mobile, e.g. in the USA.
  fixedLineOrMobile,

  /// Toll-free numbers.
  tollFree,

  /// Premium rate numbers.
  premiumRate,

  /// Shared cost numbers, where the caller and the receiver share the cost.
  sharedCost,

  /// Voice over IP numbers.
  voip,

  /// Personal numbers, which redirect to another number.
  personalNumber,

  /// Pager numbers.
  pager,

  /// Universal Access Numbers, which route to a company's local offices.
  uan,

  /// Voicemail access numbers.
  voicemail,

  /// Invalid numbers, or numbers of an unknown type.
  unknown,
}

/// How [PhoneNumber.format] writes a number.
enum PhoneNumberFormat {
  /// `+970599123456`, the format to store and send.
  e164,

  /// `+970 599 123 456`.
  international,

  /// `0599 123 456`, as dialled inside the country.
  national,
}

/// A phone number: a country and the digits typed after its dial code.
///
/// ```dart
/// final number = PhoneNumber(isoCode: 'PS', digits: '0599123456');
/// number.isValid; // true
/// number.e164; // +970599123456
/// number.format(PhoneNumberFormat.national); // 0599 123 456
///
/// PhoneNumber.tryParse('+966 50 123 4567')?.isoCode; // SA
/// ```
@immutable
final class PhoneNumber {
  /// The ISO 3166-1 alpha-2 code of the country, e.g. `PS`.
  final String isoCode;

  /// The dial code of the country, e.g. `+970`.
  final String dialCode;

  /// The digits after the dial code, without formatting, e.g. `0599123456`.
  ///
  /// These are the digits as typed, so they may include the national prefix.
  final String digits;

  /// The number in E.164 format, e.g. `+970599123456`, or null when it is
  /// not valid.
  final String? e164;

  /// Creates the number [digits] of the country [isoCode].
  ///
  /// [digits] are the digits after the dial code, with or without the
  /// national prefix, e.g. `599123456` or `0599123456` for Palestine. Arabic and
  /// Persian digits are converted, and other characters are ignored.
  ///
  /// Throws an [ArgumentError] when [isoCode] is not a known country.
  factory PhoneNumber({required String isoCode, String digits = ''}) {
    final country = Countries.byIsoCode(isoCode);
    if (country == null) {
      throw ArgumentError.value(isoCode, 'isoCode', 'Unknown country');
    }
    return PhoneNumber._ofCountry(country, digits);
  }

  factory PhoneNumber._ofCountry(Country country, String text) {
    final digits = _digitsOf(text);
    return PhoneNumber._(
      isoCode: country.alpha2Code,
      dialCode: country.dialCode,
      digits: digits,
      e164: PhoneNumberUtil.toE164(
        isoCode: country.alpha2Code,
        dialCode: country.dialCode,
        digits: digits,
      ),
    );
  }

  const PhoneNumber._({
    required this.isoCode,
    required this.dialCode,
    required this.digits,
    required this.e164,
  });

  /// Parses [text] as an international number, such as `+966501234567` or
  /// `00966501234567`, or as a national number of [isoCode].
  ///
  /// An international number keeps the country [isoCode] when it is valid
  /// there, as `+212528812345` is in both Morocco and Western Sahara, or
  /// when its country is unclear, such as an incomplete `+1…`, and they
  /// share the dial code. Otherwise it gets the country libphonenumber
  /// detects, or the main country of its calling code.
  ///
  /// Returns null when the country cannot be determined. An international
  /// number whose calling code is known but whose digits are not valid is
  /// returned with [isValid] false.
  static PhoneNumber? tryParse(String text, {String? isoCode}) {
    final input = ArabicToEnglishDigitsFormatter.convert(text).trim();
    final international = input.startsWith('+')
        ? input
        : input.startsWith('00')
        ? '+${input.substring(2)}'
        : null;
    final preferred = isoCode == null ? null : Countries.byIsoCode(isoCode);

    if (international == null) {
      return preferred == null
          ? null
          : PhoneNumber._ofCountry(preferred, input);
    }

    final digits = _digitsOf(international);
    // The preferred country, when the number starts with its dial code.
    final sameDialCode =
        preferred != null && digits.startsWith(preferred.dialCode.substring(1))
        ? preferred
        : null;
    final country =
        (sameDialCode != null &&
                PhoneNumberUtil.isValidForRegion(
                  '+$digits',
                  sameDialCode.alpha2Code,
                )
            ? sameDialCode
            : null) ??
        Countries.byIsoCode(PhoneNumberUtil.regionOfNumber('+$digits') ?? '') ??
        sameDialCode ??
        _countryOfCallingCode(digits);
    if (country == null) {
      return null;
    }
    final dialCodeDigits = country.dialCode.substring(1);
    final callingCodeLength = digits.startsWith(dialCodeDigits)
        ? dialCodeDigits.length
        : _callingCodeLength(digits)!;
    return PhoneNumber._ofCountry(country, digits.substring(callingCodeLength));
  }

  /// Returns the main country of the calling code that [digits] start with.
  static Country? _countryOfCallingCode(String digits) {
    final length = _callingCodeLength(digits);
    return length == null
        ? null
        : Countries.byDialCode(digits.substring(0, length));
  }

  /// Returns the length of the calling code that [digits] start with.
  ///
  /// Calling codes are 1 to 3 digits long and none is the start of another.
  static int? _callingCodeLength(String digits) {
    for (int length = 1; length <= 3 && length <= digits.length; length++) {
      final region = PhoneNumberUtil.regionForCallingCode(
        int.parse(digits.substring(0, length)),
      );
      if (Countries.byIsoCode(region) != null) {
        return length;
      }
    }
    return null;
  }

  static final RegExp _nonDigits = RegExp(r'\D');

  static String _digitsOf(String text) =>
      ArabicToEnglishDigitsFormatter.convert(text).replaceAll(_nonDigits, '');

  /// The country of this number.
  Country get country => Countries.byIsoCode(isoCode)!;

  /// Whether this is a valid number for its country.
  bool get isValid => e164 != null;

  /// Whether no digits were typed.
  bool get isEmpty => digits.isEmpty;

  /// The type of this number, or [PhoneNumberType.unknown] when it is not
  /// valid.
  PhoneNumberType get type => switch (e164) {
    final e164? => PhoneNumberUtil.typeOf(e164),
    null => PhoneNumberType.unknown,
  };

  /// Returns this number written in [format].
  ///
  /// A number that is not valid cannot be formatted, so it is returned as
  /// typed: [digits] for [PhoneNumberFormat.national], or [dialCode]
  /// followed by [digits] otherwise.
  String format([PhoneNumberFormat format = PhoneNumberFormat.international]) {
    final e164 = this.e164;
    if (e164 != null) {
      return PhoneNumberUtil.format(e164, format);
    }
    return format == PhoneNumberFormat.national ? digits : '$dialCode$digits';
  }

  /// Returns a copy of this number with the given fields replaced.
  PhoneNumber copyWith({String? isoCode, String? digits}) => PhoneNumber(
    isoCode: isoCode ?? this.isoCode,
    digits: digits ?? this.digits,
  );

  /// Two numbers are equal when they have the same country and [digits].
  @override
  bool operator ==(Object other) =>
      other is PhoneNumber &&
      other.isoCode == isoCode &&
      other.digits == digits;

  @override
  int get hashCode => Object.hash(isoCode, digits);

  @override
  String toString() =>
      'PhoneNumber($isoCode, $dialCode $digits'
      '${isValid ? ', valid: $e164' : ''})';
}
