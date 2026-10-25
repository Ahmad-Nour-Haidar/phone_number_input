import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_phone_input/smart_phone_input.dart';

void main() {
  final palestine = Countries.byIsoCode('PS')!;

  test('flagEmoji is made of regional indicator symbols', () {
    expect(palestine.flagEmoji, '🇵🇸');
  });

  test('flagAsset points to the bundled image', () {
    expect(palestine.flagAsset, 'assets/flags/ps.png');
  });

  group('localizedName', () {
    test('returns the translation of the language', () {
      expect(palestine.localizedName(const Locale('ar')), 'فلسطين');
      expect(palestine.localizedName(const Locale('ar', 'PS')), 'فلسطين');
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
        palestine.localizedName(
          const Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Cyrl'),
        ),
        palestine.nameTranslations['sr-Cyrl'],
      );
    });

    test('uses a regional translation for a language without its own', () {
      expect(
        palestine.localizedName(const Locale('pt')),
        palestine.nameTranslations['pt_BR'],
      );
    });

    test('uses the Traditional Chinese names where they are written', () {
      final traditional = palestine.nameTranslations['zh_TW'];
      expect(palestine.localizedName(const Locale('zh', 'HK')), traditional);
      expect(
        palestine.localizedName(
          const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
        ),
        traditional,
      );
      expect(
        palestine.localizedName(const Locale('zh')),
        palestine.nameTranslations['zh'],
      );
    });

    test('uses the Norwegian names for Bokmål and Nynorsk', () {
      expect(
        palestine.localizedName(const Locale('nb')),
        palestine.nameTranslations['no'],
      );
    });

    test('falls back to the English name', () {
      expect(palestine.localizedName(null), palestine.name);
      expect(palestine.localizedName(const Locale('xx')), palestine.name);
    });
  });

  test('countries are equal by ISO code', () {
    expect(
      palestine,
      const Country(
        name: 'Palestine',
        alpha2Code: 'PS',
        alpha3Code: 'PSE',
        dialCode: '+970',
      ),
    );
    expect(palestine, isNot(Countries.byIsoCode('LB')));
  });
}
