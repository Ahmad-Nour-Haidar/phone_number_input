import 'package:flutter/services.dart';

/// A [TextInputFormatter] that converts Arabic-Indic digits (`٠١٢٣٤٥٦٧٨٩`)
/// and Extended Arabic-Indic / Persian digits (`۰۱۲۳۴۵۶۷۸۹`) to ASCII digits
/// (`0123456789`) as the user types.
///
/// Each converted digit is a single UTF-16 code unit, so the text length never
/// changes and the selection and composing ranges are kept as they are.
final class ArabicToEnglishDigitsFormatter extends TextInputFormatter {
  /// Creates a formatter that converts Arabic and Persian digits.
  const ArabicToEnglishDigitsFormatter();

  static const int _asciiZero = 0x0030;
  static const int _arabicIndicZero = 0x0660;
  static const int _extendedArabicIndicZero = 0x06F0;

  /// Returns [input] with every Arabic-Indic and Extended Arabic-Indic digit
  /// replaced by its ASCII equivalent.
  ///
  /// Returns [input] itself when there is nothing to convert.
  static String convert(String input) {
    List<int>? codeUnits;
    for (var i = 0; i < input.length; i++) {
      final codeUnit = input.codeUnitAt(i);
      final int zero;
      if (codeUnit >= _arabicIndicZero && codeUnit <= _arabicIndicZero + 9) {
        zero = _arabicIndicZero;
      } else if (codeUnit >= _extendedArabicIndicZero &&
          codeUnit <= _extendedArabicIndicZero + 9) {
        zero = _extendedArabicIndicZero;
      } else {
        continue;
      }
      (codeUnits ??= List.of(input.codeUnits))[i] =
          _asciiZero + codeUnit - zero;
    }
    return codeUnits == null ? input : String.fromCharCodes(codeUnits);
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = convert(newValue.text);
    return identical(text, newValue.text)
        ? newValue
        : newValue.copyWith(text: text);
  }
}
