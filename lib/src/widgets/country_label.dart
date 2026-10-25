import 'package:flutter/material.dart';

import '../models/country.dart';
import 'country_flag.dart';

/// The flag and dial code of [country], as shown in the selector button.
final class CountryLabel extends StatelessWidget {
  /// The country whose flag and dial code are shown.
  final Country country;

  /// Whether the flag is shown before the dial code.
  final bool showFlag;

  /// Whether the flag is an emoji instead of the bundled image.
  final bool useEmoji;

  /// The space before the flag.
  final double leadingPadding;

  /// Whether short dial codes are padded to 5 characters.
  final bool trailingSpace;

  /// The style of the dial code.
  final TextStyle? textStyle;

  /// Creates the label of [country].
  const CountryLabel({
    super.key,
    required this.country,
    this.showFlag = true,
    this.useEmoji = false,
    this.leadingPadding = 0,
    this.trailingSpace = true,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final dialCode = trailingSpace
        ? country.dialCode.padRight(5)
        : country.dialCode;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: leadingPadding),
        if (showFlag) ...[
          CountryFlag(country: country, useEmoji: useEmoji),
          const SizedBox(width: 12),
        ],
        Text(dialCode, textDirection: TextDirection.ltr, style: textStyle),
      ],
    );
  }
}
