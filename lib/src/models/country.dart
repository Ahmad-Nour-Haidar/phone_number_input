/// @docImport 'countries.dart';
library;

import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart' show immutable;

/// A country that phone numbers can belong to.
///
/// All countries are listed in [Countries.all].
@immutable
final class Country {
  /// The English name, e.g. `Syrian Arab Republic`.
  final String name;

  /// The ISO 3166-1 alpha-2 code, e.g. `SY`.
  final String alpha2Code;

  /// The ISO 3166-1 alpha-3 code, e.g. `SYR`.
  final String alpha3Code;

  /// The dial code, e.g. `+963`.
  ///
  /// Countries that share the calling code `+1` include their area code,
  /// e.g. `+1264` for Anguilla.
  final String dialCode;

  /// The names in other languages, keyed by language code (`ar`), language
  /// and country code (`pt_BR`) or language and script code (`sr-Cyrl`).
  final Map<String, String> nameTranslations;

  /// Creates a country. All supported countries are in [Countries.all].
  const Country({
    required this.name,
    required this.alpha2Code,
    required this.alpha3Code,
    required this.dialCode,
    this.nameTranslations = const {},
  });

  /// The path of the flag image in this package's assets.
  String get flagAsset => 'assets/flags/${alpha2Code.toLowerCase()}.png';

  /// The flag as an emoji, e.g. 🇸🇾.
  String get flagEmoji => String.fromCharCodes(
    alpha2Code.codeUnits.map((codeUnit) => codeUnit + _regionalIndicatorA),
  );

  /// The offset from `A` to the regional indicator symbol letter A.
  static const int _regionalIndicatorA = 0x1F1E6 - 0x41;

  /// Returns the name of the country in [locale], or [name] when there is no
  /// translation.
  ///
  /// Tries the most specific translation first, so `pt_BR` is preferred
  /// over `pt`, and `sr-Cyrl` over `sr`. A language without its own
  /// translation uses a regional one, so `pt` uses `pt_BR`.
  String localizedName(Locale? locale) {
    if (locale == null) {
      return name;
    }
    final language = locale.languageCode;
    final countryCode = locale.countryCode;
    final keys = [
      if (countryCode != null) '${language}_$countryCode',
      if (locale.scriptCode case final scriptCode?) '$language-$scriptCode',
      // Traditional Chinese is written in Taiwan, Hong Kong and Macau.
      if (language == 'zh' &&
          (locale.scriptCode == 'Hant' ||
              countryCode == 'HK' ||
              countryCode == 'MO'))
        'zh_TW',
      // Norwegian Bokmål and Nynorsk share the Norwegian names.
      if (language == 'nb' || language == 'nn') 'no' else language,
    ];
    for (final key in keys) {
      final translation = nameTranslations[key];
      if (translation != null && translation.isNotEmpty) {
        return translation;
      }
    }
    for (final MapEntry(:key, value: translation) in nameTranslations.entries) {
      if ((key.startsWith('${language}_') || key.startsWith('$language-')) &&
          translation.isNotEmpty) {
        return translation;
      }
    }
    return name;
  }

  @override
  bool operator ==(Object other) =>
      other is Country && other.alpha2Code == alpha2Code;

  @override
  int get hashCode => alpha2Code.hashCode;

  @override
  String toString() => 'Country($alpha2Code, $dialCode, $name)';
}
