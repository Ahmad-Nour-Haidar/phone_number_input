import 'package:flutter/foundation.dart' show ValueGetter;
import 'package:flutter/services.dart';

import '../models/country.dart';
import '../utils/phone_number_util.dart';

/// Formats the digits after the dial code as they are typed, e.g.
/// `0944 123 456` in Syria or `(202) 555-0123` in the United States.
final class AsYouTypeFormatter extends TextInputFormatter {
  /// Creates a formatter for the country that [country] returns, which is
  /// read on every edit so a country change applies immediately.
  AsYouTypeFormatter(this.country);

  /// Returns the country the number is formatted for.
  final ValueGetter<Country> country;

  static final RegExp _nonDigits = RegExp(r'\D');
  static final RegExp _digit = RegExp(r'\d');

  /// Returns [digits] formatted for [country], or [digits] themselves when
  /// they cannot be formatted.
  static String formatDigits(String digits, Country country) {
    if (digits.isEmpty) {
      return digits;
    }
    // National formatting handles numbers typed with the national prefix,
    // e.g. 0944 123 456, and the US style (202) 555-0123.
    final national = PhoneNumberUtil.formatAsYouType(
      digits,
      country.alpha2Code,
    );
    if (national != digits && _digitsOf(national) == digits) {
      return national;
    }
    // Other numbers only format after their dial code. The output then
    // starts with the dial code, e.g. "+1 264-235-1234", which is removed.
    final international = _withoutDialCode(
      PhoneNumberUtil.formatAsYouType(
        country.dialCode + digits,
        country.alpha2Code,
      ),
      country.dialCode,
    );
    return _digitsOf(international) == digits ? international : digits;
  }

  /// Removes the digits of [dialCode] and the separators after them from
  /// the start of [formatted].
  static String _withoutDialCode(String formatted, String dialCode) {
    int remaining = dialCode.length - 1;
    int i = 0;
    while (i < formatted.length && remaining > 0) {
      if (_digit.hasMatch(formatted[i])) remaining--;
      i++;
    }
    while (i < formatted.length && !_digit.hasMatch(formatted[i])) {
      i++;
    }
    return formatted.substring(i);
  }

  static String _digitsOf(String text) => text.replaceAll(_nonDigits, '');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Only the selection moved.
    if (newValue.text == oldValue.text) {
      return newValue;
    }

    String digits = _digitsOf(newValue.text);
    // An international number being typed is kept as is until its country
    // is known, see InternationalNumberFormatter.
    if (newValue.text.startsWith('+')) {
      return _collapsed('+$digits');
    }

    final cursor = newValue.selection.isValid
        ? newValue.selection.end.clamp(0, newValue.text.length)
        : newValue.text.length;
    int digitsBeforeCursor = _digitsOf(newValue.text.substring(0, cursor))
        .length;

    // Backspace over a separator removes nothing that formatting would not
    // add straight back, so remove the digit before it instead.
    final isSeparatorDeletion =
        newValue.text.length < oldValue.text.length &&
        newValue.selection.isCollapsed &&
        digits == _digitsOf(oldValue.text);
    if (isSeparatorDeletion && digitsBeforeCursor > 0) {
      digits =
          digits.substring(0, digitsBeforeCursor - 1) +
          digits.substring(digitsBeforeCursor);
      digitsBeforeCursor--;
    }

    final formatted = formatDigits(digits, country());
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: _offsetAfterDigits(formatted, digitsBeforeCursor),
      ),
    );
  }

  static TextEditingValue _collapsed(String text) => TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: text.length),
  );

  /// Returns the offset in [text] just after its first [count] digits.
  static int _offsetAfterDigits(String text, int count) {
    if (count <= 0) return 0;
    int seen = 0;
    for (int i = 0; i < text.length; i++) {
      if (_digit.hasMatch(text[i]) && ++seen == count) {
        return i + 1;
      }
    }
    return text.length;
  }
}
