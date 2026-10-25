/// @docImport '../widgets/international_phone_number_input.dart';
library;

import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart' show immutable;

import 'built_in_strings.dart';

/// The texts that [InternationalPhoneNumberInput] shows.
///
/// Texts for common languages are built in, see [builtInLanguageTags], and
/// chosen by locale. To change them:
///
/// * pass [InternationalPhoneNumberInput.strings] to one input, e.g. texts
///   from your app's own translations;
/// * [register] texts for a language once, for every input, e.g. in `main`:
///
/// ```dart
/// PhoneInputStrings.register(
///   const Locale('sw'),
///   const PhoneInputStrings(
///     hint: 'Nambari ya simu',
///     invalidNumber: 'Nambari ya simu si sahihi',
///     requiredNumber: 'Weka nambari ya simu',
///     searchLabel: 'Tafuta kwa jina la nchi au msimbo',
///   ),
/// );
/// ```
///
/// Use [copyWith] to change only some texts:
///
/// ```dart
/// strings: PhoneInputStrings.of(const Locale('ar')).copyWith(
///   hint: 'رقم الجوال',
/// ),
/// ```
@immutable
final class PhoneInputStrings {
  /// The hint of the empty text field.
  final String hint;

  /// The error of a number that is not valid.
  final String invalidNumber;

  /// The error of an empty field, unless `allowEmpty` is true.
  final String requiredNumber;

  /// The label of the search field of the country list.
  final String searchLabel;

  /// Creates texts. Those not given are in English.
  const PhoneInputStrings({
    this.hint = 'Phone number',
    this.invalidNumber = 'Invalid phone number',
    this.requiredNumber = 'Enter a phone number',
    this.searchLabel = 'Search by country name or dial code',
  });

  /// The built-in English texts.
  static const PhoneInputStrings english = PhoneInputStrings();

  /// The language tags with built-in texts, e.g. `ar`, `fa`, `tr` and
  /// `zh-TW`.
  static Iterable<String> get builtInLanguageTags => builtInStrings.keys;

  static final Map<String, PhoneInputStrings> _registered = {};

  /// Uses [strings] for [locale] in every input that does not get its own
  /// [InternationalPhoneNumberInput.strings].
  ///
  /// [locale] can be a language, such as `Locale('sw')`, or be more
  /// specific, such as `Locale('pt', 'BR')`, which is then preferred over
  /// the language alone. Registering a built-in language replaces its
  /// texts.
  static void register(Locale locale, PhoneInputStrings strings) {
    _registered[locale.toLanguageTag()] = strings;
  }

  /// Removes the texts registered for [locale].
  static void unregister(Locale locale) {
    _registered.remove(locale.toLanguageTag());
  }

  /// Returns the texts for [locale].
  ///
  /// The most specific match wins: registered texts before built-in ones,
  /// and `zh-TW` before `zh`. English is used when nothing matches.
  static PhoneInputStrings of(Locale? locale) {
    final tags = [
      if (locale != null) ...[
        locale.toLanguageTag(),
        if (locale.scriptCode case final script?)
          '${locale.languageCode}-$script',
        if (locale.countryCode case final country?)
          '${locale.languageCode}-$country',
        locale.languageCode,
      ],
      'en',
    ];
    for (final tag in tags) {
      if (_registered[tag] ?? builtInStrings[tag] case final strings?) {
        return strings;
      }
    }
    return english;
  }

  /// Returns a copy with the given texts replaced.
  PhoneInputStrings copyWith({
    String? hint,
    String? invalidNumber,
    String? requiredNumber,
    String? searchLabel,
  }) => PhoneInputStrings(
    hint: hint ?? this.hint,
    invalidNumber: invalidNumber ?? this.invalidNumber,
    requiredNumber: requiredNumber ?? this.requiredNumber,
    searchLabel: searchLabel ?? this.searchLabel,
  );

  @override
  bool operator ==(Object other) =>
      other is PhoneInputStrings &&
      other.hint == hint &&
      other.invalidNumber == invalidNumber &&
      other.requiredNumber == requiredNumber &&
      other.searchLabel == searchLabel;

  @override
  int get hashCode =>
      Object.hash(hint, invalidNumber, requiredNumber, searchLabel);
}
