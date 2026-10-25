import 'package:dlibphonenumber/dlibphonenumber.dart' as p;

import '../models/phone_number.dart';

/// The calls this package makes to `dlibphonenumber`.
///
/// Everything here is synchronous and never throws.
abstract final class PhoneNumberUtil {
  static final p.PhoneNumberUtil _util = p.PhoneNumberUtil.instance;

  /// Returns the number in E.164 format, e.g. `+970599123456`, when [digits]
  /// typed after [dialCode] form a valid number for [isoCode], otherwise
  /// null.
  ///
  /// [digits] may include the national prefix (`0599…` in Palestine). Digits that
  /// already repeat the area code of [dialCode] (`264…` for `+1264`) are
  /// accepted too.
  static String? toE164({
    required String isoCode,
    required String dialCode,
    required String digits,
  }) {
    if (digits.isEmpty) {
      return null;
    }
    return _validE164('$dialCode$digits', isoCode) ??
        _validE164(digits, isoCode);
  }

  static String? _validE164(String text, String isoCode) {
    final number = _parse(text, isoCode);
    return number != null && _util.isValidNumber(number)
        ? _util.format(number, p.PhoneNumberFormat.e164)
        : null;
  }

  /// Whether the international number [text] is valid in [isoCode].
  ///
  /// Some numbers are valid in several regions, e.g. `+212528812345` in
  /// both Morocco and Western Sahara.
  static bool isValidForRegion(String text, String isoCode) {
    final number = _parse(text, 'ZZ');
    return number != null && _util.isValidNumberForRegion(number, isoCode);
  }

  /// Returns the region of the valid international number [text], e.g.
  /// `SA` for `+966501234567`, or null.
  ///
  /// A number valid in several regions returns the first one libphonenumber
  /// lists, e.g. Morocco rather than Western Sahara.
  static String? regionOfNumber(String text) {
    final number = _parse(text, 'ZZ');
    return number != null && _util.isValidNumber(number)
        ? _util.getRegionCodeForNumber(number)
        : null;
  }

  /// Returns the main region of [callingCode], e.g. `US` for 1, `ZZ` when
  /// it is unknown or `001` when it is not geographic.
  static String regionForCallingCode(int callingCode) =>
      _util.getRegionCodeForCountryCode(callingCode);

  /// Formats the valid number [e164] as [format] describes.
  static String format(String e164, PhoneNumberFormat format) {
    final number = _parse(e164, 'ZZ');
    if (number == null) {
      return e164;
    }
    return _util.format(number, switch (format) {
      PhoneNumberFormat.e164 => p.PhoneNumberFormat.e164,
      PhoneNumberFormat.international => p.PhoneNumberFormat.international,
      PhoneNumberFormat.national => p.PhoneNumberFormat.national,
    });
  }

  /// Returns the type of the valid number [e164].
  static PhoneNumberType typeOf(String e164) {
    final number = _parse(e164, 'ZZ');
    if (number == null) {
      return PhoneNumberType.unknown;
    }
    return switch (_util.getNumberType(number)) {
      p.PhoneNumberType.fixedLine => PhoneNumberType.fixedLine,
      p.PhoneNumberType.mobile => PhoneNumberType.mobile,
      p.PhoneNumberType.fixedLineOrMobile => PhoneNumberType.fixedLineOrMobile,
      p.PhoneNumberType.tollFree => PhoneNumberType.tollFree,
      p.PhoneNumberType.premiumRate => PhoneNumberType.premiumRate,
      p.PhoneNumberType.sharedCost => PhoneNumberType.sharedCost,
      p.PhoneNumberType.voip => PhoneNumberType.voip,
      p.PhoneNumberType.personalNumber => PhoneNumberType.personalNumber,
      p.PhoneNumberType.pager => PhoneNumberType.pager,
      p.PhoneNumberType.uan => PhoneNumberType.uan,
      p.PhoneNumberType.voicemail => PhoneNumberType.voicemail,
      p.PhoneNumberType.unknown => PhoneNumberType.unknown,
    };
  }

  /// Formats [input] as libphonenumber does while it is typed, for
  /// [isoCode].
  ///
  /// [input] is either national digits or `+` followed by the calling code
  /// and digits.
  static String formatAsYouType(String input, String isoCode) {
    final formatter = _util.getAsYouTypeFormatter(isoCode);
    String result = '';
    for (int i = 0; i < input.length; i++) {
      result = formatter.inputDigit(input[i]);
    }
    return result;
  }

  static p.PhoneNumber? _parse(String text, String isoCode) {
    try {
      return _util.parse(text, isoCode);
    } on Exception {
      return null;
    }
  }
}
