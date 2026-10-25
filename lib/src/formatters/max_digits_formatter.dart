import 'package:flutter/services.dart';

/// A [TextInputFormatter] that limits the number of ASCII digits in the text.
///
/// Unlike [LengthLimitingTextInputFormatter], separators such as spaces and
/// dashes do not count, so formatting a number never pushes it over the limit.
final class MaxDigitsFormatter extends TextInputFormatter {
  /// Creates a formatter that allows at most [maxDigits] digits.
  ///
  /// A [maxDigits] of zero or less means no limit.
  const MaxDigitsFormatter(this.maxDigits);

  /// The maximum number of digits allowed.
  final int maxDigits;

  static final RegExp _digit = RegExp(r'\d');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (maxDigits <= 0 || _countDigits(newValue.text) <= maxDigits) {
      return newValue;
    }
    // Typing past the limit: ignore the keystroke.
    if (_countDigits(oldValue.text) <= maxDigits) {
      return oldValue;
    }
    // Text that was already too long, e.g. set before the limit applied.
    final text = newValue.text.substring(0, _endOfDigit(newValue.text));
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  static int _countDigits(String text) => _digit.allMatches(text).length;

  /// Returns the offset just after the [maxDigits]-th digit of [text].
  int _endOfDigit(String text) {
    int seen = 0;
    for (int i = 0; i < text.length; i++) {
      if (_digit.hasMatch(text[i]) && ++seen == maxDigits) {
        return i + 1;
      }
    }
    return text.length;
  }
}
