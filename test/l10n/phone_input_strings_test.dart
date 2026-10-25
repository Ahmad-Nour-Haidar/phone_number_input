import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_phone_input/smart_phone_input.dart';

void main() {
  PhoneInputStrings of(Locale? locale) => PhoneInputStrings.of(locale);

  group('built-in texts', () {
    test('every language has all texts, translated', () {
      for (final tag in PhoneInputStrings.builtInLanguageTags) {
        final strings = of(
          Locale.fromSubtags(languageCode: tag.split('-').first),
        );
        expect(strings.hint, isNotEmpty, reason: tag);
        expect(strings.invalidNumber, isNotEmpty, reason: tag);
        expect(strings.requiredNumber, isNotEmpty, reason: tag);
        expect(strings.searchLabel, isNotEmpty, reason: tag);
        if (tag != 'en') {
          expect(strings, isNot(PhoneInputStrings.english), reason: tag);
        }
      }
    });

    test('include common languages', () {
      expect(
        PhoneInputStrings.builtInLanguageTags,
        containsAll(['en', 'ar', 'fa', 'ur', 'tr', 'fr', 'de', 'es', 'ru']),
      );
    });

    test('are chosen by language, ignoring the country', () {
      expect(of(const Locale('ar')).hint, 'رقم الهاتف');
      expect(of(const Locale('ar', 'PS')).hint, 'رقم الهاتف');
      expect(of(const Locale('tr')).hint, 'Telefon numarası');
    });

    test('distinguish Simplified and Traditional Chinese', () {
      expect(of(const Locale('zh')).hint, '电话号码');
      expect(of(const Locale('zh', 'CN')).hint, '电话号码');
      expect(of(const Locale('zh', 'TW')).hint, '電話號碼');
      expect(
        of(const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'))
            .hint,
        '電話號碼',
      );
    });

    test('cover Norwegian Bokmål and Nynorsk', () {
      expect(of(const Locale('nb')).hint, 'Telefonnummer');
      expect(of(const Locale('nn')).hint, 'Telefonnummer');
    });

    test('fall back to English', () {
      expect(of(null), PhoneInputStrings.english);
      expect(of(const Locale('xx')), PhoneInputStrings.english);
    });
  });

  group('register', () {
    const swahili = PhoneInputStrings(
      hint: 'Nambari ya simu',
      invalidNumber: 'Nambari ya simu si sahihi',
      requiredNumber: 'Weka nambari ya simu',
      searchLabel: 'Tafuta kwa jina la nchi au msimbo',
    );

    tearDown(() {
      for (final locale in const [
        Locale('sw'),
        Locale('ar'),
        Locale('pt', 'BR'),
        Locale('en'),
      ]) {
        PhoneInputStrings.unregister(locale);
      }
    });

    test('adds a language', () {
      PhoneInputStrings.register(const Locale('sw'), swahili);

      expect(of(const Locale('sw')), swahili);
      expect(of(const Locale('sw', 'KE')), swahili);
    });

    test('replaces a built-in language', () {
      PhoneInputStrings.register(
        const Locale('ar'),
        of(const Locale('ar')).copyWith(hint: 'رقم الجوال'),
      );

      expect(of(const Locale('ar', 'SA')).hint, 'رقم الجوال');
      expect(of(const Locale('ar')).invalidNumber, 'رقم الهاتف غير صالح');
    });

    test('prefers a more specific locale', () {
      const brazilian = PhoneInputStrings(hint: 'Número de celular');
      PhoneInputStrings.register(const Locale('pt', 'BR'), brazilian);

      expect(of(const Locale('pt', 'BR')), brazilian);
      expect(of(const Locale('pt', 'PT')).hint, 'Número de telefone');
    });

    test('replacing English changes the fallback', () {
      PhoneInputStrings.register(
        const Locale('en'),
        const PhoneInputStrings(hint: 'Mobile number'),
      );

      expect(of(null).hint, 'Mobile number');
      expect(of(const Locale('xx')).hint, 'Mobile number');
    });

    test('unregister restores the built-in texts', () {
      PhoneInputStrings.register(const Locale('ar'), swahili);
      PhoneInputStrings.unregister(const Locale('ar'));

      expect(of(const Locale('ar')).hint, 'رقم الهاتف');
    });
  });

  test('texts not given are in English', () {
    const strings = PhoneInputStrings(hint: 'Mobile');

    expect(strings.hint, 'Mobile');
    expect(strings.invalidNumber, PhoneInputStrings.english.invalidNumber);
  });

  test('copyWith replaces only the given texts', () {
    final strings = of(const Locale('ar')).copyWith(requiredNumber: 'مطلوب');

    expect(strings.requiredNumber, 'مطلوب');
    expect(strings.hint, 'رقم الهاتف');
    expect(strings, isNot(of(const Locale('ar'))));
  });
}
