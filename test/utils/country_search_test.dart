import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:phone_number_input/phone_number_input.dart';
import 'package:phone_number_input/src/utils/country_search.dart';

void main() {
  List<String> search(String query, {Locale? locale}) => [
    for (final country in searchCountries(Countries.all, query, locale: locale))
      country.alpha2Code,
  ];

  test('returns every country for an empty query', () {
    expect(searchCountries(Countries.all, '  '), Countries.all);
  });

  test('ranks exact ISO codes first', () {
    expect(search('sy').first, 'SY');
    expect(search('SYR').first, 'SY');
  });

  test('ranks names that start with the query before other matches', () {
    final results = search('ind');

    expect(results.take(2), containsAll(['IN', 'ID']));
    expect(results.indexOf('IN'), lessThan(results.indexOf('IO')));
  });

  test('matches dial codes with or without + and in Arabic digits', () {
    expect(search('963').first, 'SY');
    expect(search('+963').first, 'SY');
    expect(search('٩٦٣').first, 'SY');
    expect(search('+96'), containsAll(['SY', 'SA', 'JO', 'LB']));
    expect(search('+96'), isNot(contains('AE')));
  });

  test('ignores accents', () {
    expect(search('cote'), contains('CI'));
  });

  group('in Arabic', () {
    const arabic = Locale('ar');

    test('matches the translated names', () {
      expect(search('سوريا', locale: arabic).first, 'SY');
    });

    test('ignores letter variants and diacritics', () {
      expect(search('السعوديه', locale: arabic), contains('SA'));
      expect(search('سُورِيَا', locale: arabic).first, 'SY');
    });

    test('matches words without the article ال', () {
      expect(search('سعود', locale: arabic), contains('SA'));
    });
  });

  test('normalizeForSearch unifies Arabic letters and removes marks', () {
    expect(normalizeForSearch('أَحْمَد'), 'احمد');
    expect(normalizeForSearch('مدرسة  إلى'), 'مدرسه الي');
    expect(normalizeForSearch('Åland'), 'aland');
  });
}
