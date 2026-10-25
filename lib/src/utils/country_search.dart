import 'dart:ui' show Locale;

import '../formatters/arabic_to_english_digits_formatter.dart';
import '../models/country.dart';

/// Returns the countries of [countries] that match [query], best matches
/// first.
///
/// A query of digits, with or without `+`, matches dial codes. Any other
/// query matches the name in [locale], the English name and the ISO codes.
/// Case, accents and Arabic letter variants are ignored, so `cote` finds
/// Côte d'Ivoire and `السعوديه` finds السعودية.
List<Country> searchCountries(
  List<Country> countries,
  String query, {
  Locale? locale,
}) {
  final normalizedQuery = normalizeForSearch(query);
  if (normalizedQuery.isEmpty) {
    return countries;
  }

  final matches = <({int rank, int index, Country country})>[];
  for (int index = 0; index < countries.length; index++) {
    final country = countries[index];
    final rank = _rank(country, normalizedQuery, locale);
    if (rank != null) {
      matches.add((rank: rank, index: index, country: country));
    }
  }
  matches.sort(
    (a, b) => a.rank != b.rank ? a.rank - b.rank : a.index - b.index,
  );
  return [for (final match in matches) match.country];
}

/// Returns how well [country] matches [query], 0 being the best, or null
/// when it does not match.
int? _rank(Country country, String query, Locale? locale) {
  final dialQuery = query.startsWith('+') ? query.substring(1) : query;
  if (_digitsOnly.hasMatch(dialQuery)) {
    final dialCode = country.dialCode.substring(1);
    if (dialCode == dialQuery) return 0;
    if (dialCode.startsWith(dialQuery)) return 1;
    return null;
  }

  final names = {
    normalizeForSearch(country.localizedName(locale)),
    normalizeForSearch(country.name),
  };
  if (names.contains(query) ||
      country.alpha2Code.toLowerCase() == query ||
      country.alpha3Code.toLowerCase() == query) {
    return 0;
  }
  if (names.any((name) => name.startsWith(query))) return 1;
  if (names.any((name) => _words(name).any((w) => w.startsWith(query)))) {
    return 2;
  }
  if (names.any((name) => name.contains(query))) return 3;
  return null;
}

final RegExp _digitsOnly = RegExp(r'^\d+$');
final RegExp _arabicMarks = RegExp('[ؐ-ًؚ-ٰٟـ]');
final RegExp _spaces = RegExp(r'\s+');

/// The words of [name], also without the Arabic article ال, so `سعود`
/// matches the word السعودية.
Iterable<String> _words(String name) sync* {
  for (final word in name.split(' ')) {
    yield word;
    if (word.length > 2 && word.startsWith('ال')) {
      yield word.substring(2);
    }
  }
}

/// Returns [text] lowercased, with ASCII digits, without accents and Arabic
/// diacritics, and with Arabic letter variants unified, for comparing names.
String normalizeForSearch(String text) {
  final converted = ArabicToEnglishDigitsFormatter.convert(text)
      .toLowerCase()
      .replaceAll(_arabicMarks, '');
  final buffer = StringBuffer();
  for (final rune in converted.runes) {
    final char = String.fromCharCode(rune);
    buffer.write(_letterVariants[char] ?? char);
  }
  return buffer.toString().replaceAll(_spaces, ' ').trim();
}

const Map<String, String> _letterVariants = {
  // Arabic
  'أ': 'ا', 'إ': 'ا', 'آ': 'ا', 'ٱ': 'ا',
  'ة': 'ه', 'ى': 'ي', 'ئ': 'ي', 'ؤ': 'و',
  // Latin
  'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a',
  'ç': 'c',
  'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
  'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
  'ñ': 'n',
  'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o', 'ø': 'o',
  'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
  'ý': 'y', 'ÿ': 'y',
  '’': "'",
};
