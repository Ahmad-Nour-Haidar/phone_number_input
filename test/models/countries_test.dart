import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:phone_number_input/phone_number_input.dart';

void main() {
  group('Countries.all', () {
    test('every country is complete', () {
      const expectedTranslations = [
        'sk', 'se', 'pl', 'no', 'ja', 'it', 'zh', 'nl', 'de', 'fr', 'en', //
        'es', 'pt_BR', 'sr-Cyrl', 'sr-Latn', 'zh_TW', 'tr', 'ro', 'ar', 'fa',
      ];

      for (final country in Countries.all) {
        expect(country.name, isNotEmpty);
        expect(country.alpha2Code, matches(RegExp(r'^[A-Z]{2}$')));
        expect(country.alpha3Code, matches(RegExp(r'^[A-Z]{3}$')));
        expect(country.dialCode, matches(RegExp(r'^\+\d+$')));
        expect(
          country.nameTranslations.keys,
          containsAll(expectedTranslations),
        );
        expect(
          File(country.flagAsset).existsSync(),
          isTrue,
          reason: '$country',
        );
      }
    });

    test('ISO codes are unique', () {
      final codes = Countries.all.map((country) => country.alpha2Code);
      expect(codes.toSet(), hasLength(codes.length));
    });
  });

  group('byIsoCode', () {
    test('matches case-insensitively', () {
      expect(Countries.byIsoCode('ps')?.dialCode, '+970');
    });

    test('returns null for unknown codes', () {
      expect(Countries.byIsoCode('XX'), isNull);
      expect(Countries.byIsoCode(''), isNull);
    });
  });

  group('byDialCode', () {
    String? isoCodeOf(String dialCode) =>
        Countries.byDialCode(dialCode)?.alpha2Code;

    test('returns the main country of a shared calling code', () {
      expect(isoCodeOf('+1'), 'US');
      expect(isoCodeOf('+7'), 'RU');
      expect(isoCodeOf('+44'), 'GB');
    });

    test('accepts dial codes with or without +', () {
      expect(isoCodeOf('970'), 'PS');
      expect(isoCodeOf('+970'), 'PS');
    });

    test('finds dial codes that include an area code', () {
      expect(isoCodeOf('+1264'), 'AI');
      expect(isoCodeOf('+1721'), 'SX');
    });

    test('returns the main country of a calling code shared with a '
        'territory', () {
      expect(isoCodeOf('+212'), 'MA');
      expect(Countries.byIsoCode('EH')?.dialCode, '+212');
    });

    test('returns null for unknown or non-geographic codes', () {
      expect(isoCodeOf(''), isNull);
      expect(isoCodeOf('+999'), isNull);
      expect(isoCodeOf('+800'), isNull);
    });
  });

  group('filter', () {
    test('returns every country without codes', () {
      expect(Countries.filter(null), Countries.all);
      expect(Countries.filter(const []), Countries.all);
    });

    test('keeps the order of all, matches case-insensitively and ignores '
        'unknown codes', () {
      final countries = Countries.filter(const ['ps', 'XX', 'LB']);
      expect(countries.map((country) => country.alpha2Code), ['LB', 'PS']);
    });
  });
}
