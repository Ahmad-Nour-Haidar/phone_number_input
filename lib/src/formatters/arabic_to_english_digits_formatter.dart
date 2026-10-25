import 'package:flutter/services.dart';

final class ArabicToEnglishDigitsFormatter extends TextInputFormatter {
  const ArabicToEnglishDigitsFormatter();

  static const Map<String, String> _ar2en = {
    '٠': '0', // Arabic-Indic
    '١': '1',
    '٢': '2',
    '٣': '3',
    '٤': '4',
    '٥': '5',
    '٦': '6',
    '٧': '7',
    '٨': '8',
    '٩': '9',
    '۰': '0', // Eastern Arabic (Persian)
    '۱': '1',
    '۲': '2',
    '۳': '3',
    '۴': '4',
    '۵': '5',
    '۶': '6',
    '۷': '7',
    '۸': '8',
    '۹': '9',
  };

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Replace Arabic digits with English equivalents

    final original = newValue.text;
    final length = original.length;
    final buffer = StringBuffer();
    for (int i = 0; i < length; i++) {
      final c = original[i];
      buffer.write(_ar2en[c] ?? c);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: newValue.selection.baseOffset),
    );
  }
}
