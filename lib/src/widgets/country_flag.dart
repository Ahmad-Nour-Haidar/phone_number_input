import 'package:flutter/material.dart';

import '../models/country.dart';

/// Shows the flag of [country], either as an emoji or as the image bundled
/// with this package.
final class CountryFlag extends StatelessWidget {
  static const String _package = 'smart_phone_input';

  /// The country whose flag is shown.
  final Country country;

  /// Whether the flag is an emoji instead of the bundled image.
  final bool useEmoji;

  /// Whether the image is drawn in a circle, as in the country list.
  final bool circular;

  /// Creates the flag of [country].
  const CountryFlag({
    super.key,
    required this.country,
    required this.useEmoji,
    this.circular = false,
  });

  @override
  Widget build(BuildContext context) {
    if (useEmoji) {
      return Text(
        country.flagEmoji,
        style: Theme.of(context).textTheme.headlineSmall,
      );
    }
    if (circular) {
      return CircleAvatar(
        backgroundImage: AssetImage(country.flagAsset, package: _package),
      );
    }
    return Image.asset(
      country.flagAsset,
      width: 32.0,
      package: _package,
      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
    );
  }
}
