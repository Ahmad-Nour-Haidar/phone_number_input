import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:phone_number_input/phone_number_input.dart';

void main() {
  final syria = Countries.byIsoCode('SY')!;

  test('flagEmoji is made of regional indicator symbols', () {
    expect(syria.flagEmoji, '🇸🇾');
  });

  test('flagAsset points to the bundled image', () {
    expect(syria.flagAsset, 'assets/flags/sy.png');
  });

  group('localizedName', () {
    test('returns the translation of the language', () {
      expect(syria.localizedName(const Locale('ar')), 'سوريا');
      expect(syria.localizedName(const Locale('ar', 'SY')), 'سوريا');
    });

    test('prefers a translation for the language and country', () {
      final germany = Countries.byIsoCode('DE')!;
      expect(
        germany.localizedName(const Locale('pt', 'BR')),
        germany.nameTranslations['pt_BR'],
      );
    });

    test('prefers a translation for the language and script', () {
      expect(
        syria.localizedName(
          const Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Cyrl'),
        ),
        syria.nameTranslations['sr-Cyrl'],
      );
    });

    test('uses a regional translation for a language without its own', () {
      expect(
        syria.localizedName(const Locale('pt')),
        syria.nameTranslations['pt_BR'],
      );
    });

    test('uses the Traditional Chinese names where they are written', () {
      final traditional = syria.nameTranslations['zh_TW'];
      expect(syria.localizedName(const Locale('zh', 'HK')), traditional);
      expect(
        syria.localizedName(
          const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
        ),
        traditional,
      );
      expect(
        syria.localizedName(const Locale('zh')),
        syria.nameTranslations['zh'],
      );
    });

    test('uses the Norwegian names for Bokmål and Nynorsk', () {
      expect(
        syria.localizedName(const Locale('nb')),
        syria.nameTranslations['no'],
      );
    });

    test('falls back to the English name', () {
      expect(syria.localizedName(null), syria.name);
      expect(syria.localizedName(const Locale('xx')), syria.name);
    });
  });

  test('countries are equal by ISO code', () {
    expect(
      syria,
      const Country(
        name: 'Syria',
        alpha2Code: 'SY',
        alpha3Code: 'SYR',
        dialCode: '+963',
      ),
    );
    expect(syria, isNot(Countries.byIsoCode('LB')));
  });
}
