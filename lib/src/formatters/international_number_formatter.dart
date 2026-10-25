import 'package:flutter/foundation.dart' show ValueChanged, ValueGetter;
import 'package:flutter/services.dart';

import '../models/country.dart';
import '../models/phone_number.dart';

/// Detects an international number, such as `+966…` or `00966…`, typed or
/// pasted into the field, switches to its country and leaves only the
/// digits after the dial code.
///
/// Until the calling code is complete, the text is left as it is.
final class InternationalNumberFormatter extends TextInputFormatter {
  /// Creates a formatter that detects the country of international numbers.
  InternationalNumberFormatter({
    required this.country,
    required this.isAllowed,
    required this.onCountryDetected,
  });

  /// Returns the selected country, which is kept for an incomplete number
  /// that shares its dial code, such as `+1` for Canada.
  final ValueGetter<Country> country;

  /// Whether the field accepts [country]. Numbers of other countries are
  /// left as they are.
  final bool Function(Country country) isAllowed;

  /// Called with the country of the number when it differs from [country].
  final ValueChanged<Country> onCountryDetected;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.trimLeft();
    if (!text.startsWith('+') && !text.startsWith('00')) {
      return newValue;
    }

    final selected = country();
    final number = PhoneNumber.tryParse(text, isoCode: selected.alpha2Code);
    if (number == null || !isAllowed(number.country)) {
      return newValue;
    }
    if (number.country != selected) {
      onCountryDetected(number.country);
    }
    return TextEditingValue(
      text: number.digits,
      selection: TextSelection.collapsed(offset: number.digits.length),
    );
  }
}
