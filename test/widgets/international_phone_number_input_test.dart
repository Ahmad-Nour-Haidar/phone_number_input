import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_phone_input/smart_phone_input.dart';

void main() {
  Widget app(Widget child) => MaterialApp(home: Scaffold(body: child));

  final field = find.byKey(PhoneInputKeys.textField);

  String fieldText(WidgetTester tester) =>
      tester.widget<TextFormField>(field).controller!.text;

  group('display', () {
    testWidgets('shows a translated hint', (tester) async {
      await tester.pumpWidget(app(const InternationalPhoneNumberInput()));
      expect(find.text('Phone number'), findsOneWidget);

      await tester.pumpWidget(
        app(const InternationalPhoneNumberInput(locale: Locale('ar'))),
      );
      expect(find.text('رقم الهاتف'), findsOneWidget);
    });

    testWidgets('keeps a hint from the decoration', (tester) async {
      await tester.pumpWidget(
        app(
          const InternationalPhoneNumberInput(
            decoration: InputDecoration(hintText: 'Mobile'),
          ),
        ),
      );

      expect(find.text('Mobile'), findsOneWidget);
      expect(find.text('Phone number'), findsNothing);
    });

    testWidgets('starts with the device country', (tester) async {
      tester.platformDispatcher.localeTestValue = const Locale('ar', 'PS');
      addTearDown(tester.platformDispatcher.clearLocaleTestValue);

      await tester.pumpWidget(app(const InternationalPhoneNumberInput()));

      expect(find.textContaining('+970'), findsOneWidget);
    });

    testWidgets('starts with the first favorite when the device country is '
        'not available', (tester) async {
      await tester.pumpWidget(
        app(
          const InternationalPhoneNumberInput(
            countries: ['PS', 'LB', 'JO'],
            favoriteCountries: ['JO'],
          ),
        ),
      );

      expect(find.textContaining('+962'), findsOneWidget);
    });

    testWidgets('shows the initial value formatted', (tester) async {
      await tester.pumpWidget(
        app(
          InternationalPhoneNumberInput(
            initialValue: PhoneNumber(isoCode: 'PS', digits: '0599123456'),
          ),
        ),
      );

      expect(find.textContaining('+970'), findsOneWidget);
      expect(fieldText(tester), '0599 123 456');
    });

    testWidgets('shows emoji flags or no flags', (tester) async {
      await tester.pumpWidget(
        app(
          InternationalPhoneNumberInput(
            initialValue: PhoneNumber(isoCode: 'PS'),
            selectorConfig: const SelectorConfig(useEmoji: true),
          ),
        ),
      );
      expect(find.text('🇵🇸'), findsOneWidget);

      await tester.pumpWidget(
        app(
          InternationalPhoneNumberInput(
            initialValue: PhoneNumber(isoCode: 'PS'),
            selectorConfig: const SelectorConfig(showFlags: false),
          ),
        ),
      );
      expect(find.byType(Image), findsNothing);
      expect(find.text('🇵🇸'), findsNothing);
    });

    testWidgets('can show the selector inside the text field', (tester) async {
      await tester.pumpWidget(
        app(
          const InternationalPhoneNumberInput(
            selectorConfig: SelectorConfig(asPrefixIcon: true),
          ),
        ),
      );

      final decoration = tester
          .widget<TextField>(find.byType(TextField))
          .decoration!;
      expect(decoration.prefixIcon, isNotNull);
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('keeps the selector level with the text when an error '
        'appears', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        app(
          Form(
            key: formKey,
            child: InternationalPhoneNumberInput(
              initialValue: PhoneNumber(isoCode: 'PS'),
            ),
          ),
        ),
      );
      final dialCode = find.textContaining('+970');
      final before = tester.getCenter(dialCode).dy;

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Enter a phone number'), findsOneWidget);
      expect(tester.getCenter(dialCode).dy, before);
    });
  });

  group('typing', () {
    testWidgets('formats in the same frame and reports the number', (
      tester,
    ) async {
      PhoneNumber? reported;
      await tester.pumpWidget(
        app(
          InternationalPhoneNumberInput(
            initialValue: PhoneNumber(isoCode: 'PS'),
            onChanged: (number) => reported = number,
          ),
        ),
      );

      await tester.enterText(field, '0599123456');
      await tester.pump();

      expect(fieldText(tester), '0599 123 456');
      expect(reported?.e164, '+970599123456');
      expect(reported?.digits, '0599123456');
    });

    testWidgets('converts Arabic digits', (tester) async {
      PhoneNumber? reported;
      await tester.pumpWidget(
        app(
          InternationalPhoneNumberInput(
            initialValue: PhoneNumber(isoCode: 'PS'),
            onChanged: (number) => reported = number,
          ),
        ),
      );

      await tester.enterText(field, '٠٥٩٩١٢٣٤٥٦');
      await tester.pump();

      expect(fieldText(tester), '0599 123 456');
      expect(reported?.isValid, isTrue);
    });

    testWidgets('switches the country of a pasted international number', (
      tester,
    ) async {
      PhoneNumber? reported;
      await tester.pumpWidget(
        app(
          InternationalPhoneNumberInput(
            initialValue: PhoneNumber(isoCode: 'PS'),
            onChanged: (number) => reported = number,
          ),
        ),
      );

      await tester.enterText(field, '+966 50 123 4567');
      await tester.pump();

      expect(find.textContaining('+966'), findsOneWidget);
      expect(fieldText(tester), '50 123 4567');
      expect(reported?.isoCode, 'SA');
      expect(reported?.e164, '+966501234567');
    });

    testWidgets('switches the country once the 00 calling code is typed', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          InternationalPhoneNumberInput(
            initialValue: PhoneNumber(isoCode: 'PS'),
          ),
        ),
      );

      await tester.enterText(field, '00966');
      await tester.pump();

      expect(find.textContaining('+966'), findsOneWidget);
      expect(fieldText(tester), isEmpty);
    });

    testWidgets('limits the number of digits, not characters', (tester) async {
      await tester.pumpWidget(
        app(
          InternationalPhoneNumberInput(
            initialValue: PhoneNumber(isoCode: 'PS'),
            maxDigits: 10,
          ),
        ),
      );

      await tester.enterText(field, '0599123456');
      await tester.pump();
      expect(fieldText(tester), '0599 123 456');

      await tester.enterText(field, '05991234567');
      await tester.pump();
      expect(fieldText(tester), '0599 123 456');
    });

    testWidgets('shows only digits when formatting is off', (tester) async {
      await tester.pumpWidget(
        app(
          InternationalPhoneNumberInput(
            initialValue: PhoneNumber(isoCode: 'PS'),
            formatInput: false,
          ),
        ),
      );

      await tester.enterText(field, '0599-123 456');
      await tester.pump();

      expect(fieldText(tester), '0599123456');
    });

    testWidgets('uses the given controller', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        app(
          InternationalPhoneNumberInput(
            initialValue: PhoneNumber(isoCode: 'PS'),
            controller: controller,
          ),
        ),
      );

      await tester.enterText(field, '0599123456');
      await tester.pump();

      expect(controller.text, '0599 123 456');
    });

    testWidgets('is read-only when disabled', (tester) async {
      await tester.pumpWidget(
        app(const InternationalPhoneNumberInput(enabled: false)),
      );

      expect(tester.widget<TextFormField>(field).enabled, isFalse);
      final dropdown = tester.widget<DropdownButton<Country>>(
        find.byKey(PhoneInputKeys.selectorButton),
      );
      expect(dropdown.onChanged, isNull);
    });
  });

  group('selecting a country', () {
    testWidgets('from the dropdown reformats and reports the number', (
      tester,
    ) async {
      PhoneNumber? reported;
      await tester.pumpWidget(
        app(
          InternationalPhoneNumberInput(
            initialValue: PhoneNumber(isoCode: 'US', digits: '0501234567'),
            countries: const ['US', 'SA'],
            onChanged: (number) => reported = number,
          ),
        ),
      );

      await tester.tap(find.byKey(PhoneInputKeys.selectorButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(PhoneInputKeys.countryItem('SA')).last);
      await tester.pumpAndSettle();

      expect(find.textContaining('+966'), findsOneWidget);
      expect(fieldText(tester), '050 123 4567');
      expect(reported?.e164, '+966501234567');
    });

    testWidgets('from the bottom sheet, searching in Arabic', (tester) async {
      await tester.pumpWidget(
        app(
          const InternationalPhoneNumberInput(
            locale: Locale('ar'),
            selectorConfig: SelectorConfig(
              type: PhoneInputSelectorType.bottomSheet,
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(PhoneInputKeys.selectorButton));
      await tester.pumpAndSettle();
      expect(find.text('ابحث باسم الدولة أو رمز الاتصال'), findsOneWidget);

      await tester.enterText(find.byKey(PhoneInputKeys.searchField), 'فلسط');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(PhoneInputKeys.countryItem('PS')));
      await tester.pumpAndSettle();

      expect(find.byKey(PhoneInputKeys.searchField), findsNothing);
      expect(find.textContaining('+970'), findsOneWidget);
    });

    testWidgets('from the dialog', (tester) async {
      await tester.pumpWidget(
        app(
          const InternationalPhoneNumberInput(
            selectorConfig: SelectorConfig(type: PhoneInputSelectorType.dialog),
          ),
        ),
      );

      await tester.tap(find.byKey(PhoneInputKeys.selectorButton));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.enterText(find.byKey(PhoneInputKeys.searchField), '970');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(PhoneInputKeys.countryItem('PS')));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.textContaining('+970'), findsOneWidget);
    });

    testWidgets('lists favorites first, then countries by translated name', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          const InternationalPhoneNumberInput(
            locale: Locale('ar'),
            countries: ['PS', 'LB', 'JO'],
            favoriteCountries: ['PS'],
            selectorConfig: SelectorConfig(
              type: PhoneInputSelectorType.bottomSheet,
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(PhoneInputKeys.selectorButton));
      await tester.pumpAndSettle();

      final tiles = tester.widgetList<ListTile>(find.byType(ListTile));
      expect(
        [for (final tile in tiles) (tile.title! as Text).data],
        ['فلسطين', 'الأردن', 'لبنان'],
      );
    });

    testWidgets('tapping above the bottom sheet closes it', (tester) async {
      await tester.pumpWidget(
        app(
          const InternationalPhoneNumberInput(
            selectorConfig: SelectorConfig(
              type: PhoneInputSelectorType.bottomSheet,
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(PhoneInputKeys.selectorButton));
      await tester.pumpAndSettle();
      expect(find.byKey(PhoneInputKeys.searchField), findsOneWidget);

      await tester.tapAt(const Offset(400, 20));
      await tester.pumpAndSettle();

      expect(find.byKey(PhoneInputKeys.searchField), findsNothing);
    });

    testWidgets('limits the dropdown menu to a part of the screen height', (
      tester,
    ) async {
      Future<double> openMenuHeight(SelectorConfig config) async {
        await tester.pumpWidget(
          app(InternationalPhoneNumberInput(selectorConfig: config)),
        );
        await tester.tap(find.byKey(PhoneInputKeys.selectorButton));
        await tester.pumpAndSettle();
        final height = tester.getSize(find.byType(Scrollable).last).height;
        // Closes the menu.
        await tester.tapAt(Offset.zero);
        await tester.pumpAndSettle();
        return height;
      }

      final screenHeight =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;

      expect(
        await openMenuHeight(const SelectorConfig()),
        lessThanOrEqualTo(screenHeight * 0.75),
      );
      expect(
        await openMenuHeight(
          const SelectorConfig(dropdownMaxHeightFactor: null),
        ),
        greaterThan(screenHeight * 0.75),
      );
    });
  });

  group('parent updates', () {
    testWidgets('selected country survives a parent rebuild', (tester) async {
      late StateSetter rebuildParent;
      await tester.pumpWidget(
        app(
          StatefulBuilder(
            builder: (context, setState) {
              rebuildParent = setState;
              return InternationalPhoneNumberInput(
                // A new instance on every build, as is common in app code.
                initialValue: PhoneNumber(isoCode: 'PS'),
                countries: const ['PS', 'LB'],
              );
            },
          ),
        ),
      );

      await tester.tap(find.byKey(PhoneInputKeys.selectorButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(PhoneInputKeys.countryItem('LB')).last);
      await tester.pumpAndSettle();
      rebuildParent(() {});
      await tester.pumpAndSettle();

      expect(find.textContaining('+961'), findsOneWidget);
      expect(find.textContaining('+970'), findsNothing);
    });

    testWidgets('feeding onChanged back as initialValue keeps the text', (
      tester,
    ) async {
      PhoneNumber number = PhoneNumber(isoCode: 'PS');
      await tester.pumpWidget(
        app(
          StatefulBuilder(
            builder: (context, setState) => InternationalPhoneNumberInput(
              initialValue: number,
              onChanged: (value) => setState(() => number = value),
            ),
          ),
        ),
      );

      await tester.enterText(field, '0599123456');
      await tester.pumpAndSettle();

      expect(number.e164, '+970599123456');
      expect(fieldText(tester), '0599 123 456');
    });

    testWidgets('a new initial value replaces the number', (tester) async {
      late StateSetter setParent;
      PhoneNumber number = PhoneNumber(isoCode: 'PS');
      await tester.pumpWidget(
        app(
          StatefulBuilder(
            builder: (context, setState) {
              setParent = setState;
              return InternationalPhoneNumberInput(initialValue: number);
            },
          ),
        ),
      );

      setParent(() => number = PhoneNumber.tryParse('+966501234567')!);
      await tester.pump();

      expect(find.textContaining('+966'), findsOneWidget);
      expect(fieldText(tester), '50 123 4567');
    });

    testWidgets('a new initial value inside a form does not rebuild the form '
        'during the build', (tester) async {
      late StateSetter setParent;
      PhoneNumber number = PhoneNumber(isoCode: 'PS', digits: '0599123456');
      await tester.pumpWidget(
        app(
          StatefulBuilder(
            builder: (context, setState) {
              setParent = setState;
              return Form(
                child: InternationalPhoneNumberInput(
                  initialValue: number,
                  onChanged: (value) => setState(() => number = value),
                ),
              );
            },
          ),
        ),
      );

      setParent(() => number = PhoneNumber.tryParse('+966501234567')!);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('+966'), findsOneWidget);
      expect(fieldText(tester), '50 123 4567');

      setParent(() => number = PhoneNumber(isoCode: 'PS'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('+970'), findsOneWidget);
      expect(fieldText(tester), isEmpty);
    });
  });

  group('form', () {
    Future<GlobalKey<FormState>> pumpForm(
      WidgetTester tester,
      InternationalPhoneNumberInput input,
    ) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(app(Form(key: formKey, child: input)));
      return formKey;
    }

    testWidgets('rejects empty and invalid numbers with their own errors', (
      tester,
    ) async {
      final formKey = await pumpForm(
        tester,
        InternationalPhoneNumberInput(initialValue: PhoneNumber(isoCode: 'PS')),
      );

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Enter a phone number'), findsOneWidget);

      await tester.enterText(field, '123');
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Invalid phone number'), findsOneWidget);

      await tester.enterText(field, '0599123456');
      expect(formKey.currentState!.validate(), isTrue);
    });

    testWidgets('accepts an empty field with allowEmpty', (tester) async {
      final formKey = await pumpForm(
        tester,
        InternationalPhoneNumberInput(
          initialValue: PhoneNumber(isoCode: 'PS'),
          allowEmpty: true,
        ),
      );

      expect(formKey.currentState!.validate(), isTrue);
    });

    testWidgets('shows the error in the locale language', (tester) async {
      final formKey = await pumpForm(
        tester,
        InternationalPhoneNumberInput(
          initialValue: PhoneNumber(isoCode: 'PS', digits: '123'),
          locale: const Locale('ar'),
        ),
      );

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('رقم الهاتف غير صالح'), findsOneWidget);
    });

    testWidgets('passes the number to a custom validator', (tester) async {
      PhoneNumber? validated;
      final formKey = await pumpForm(
        tester,
        InternationalPhoneNumberInput(
          initialValue: PhoneNumber(isoCode: 'PS'),
          validator: (number) {
            validated = number;
            return number.type == PhoneNumberType.mobile ? null : 'Mobile only';
          },
        ),
      );

      await tester.enterText(field, '0599123456');
      expect(formKey.currentState!.validate(), isTrue);
      expect(validated?.e164, '+970599123456');
    });

    testWidgets('onSaved reports the same number as onChanged', (tester) async {
      PhoneNumber? changed;
      PhoneNumber? saved;
      final formKey = await pumpForm(
        tester,
        InternationalPhoneNumberInput(
          initialValue: PhoneNumber(isoCode: 'PS'),
          onChanged: (number) => changed = number,
          onSaved: (number) => saved = number,
        ),
      );

      await tester.enterText(field, '0599123456');
      formKey.currentState!.save();

      expect(changed?.e164, '+970599123456');
      expect(saved, changed);
    });

    testWidgets('autovalidation does not rebuild on every frame', (
      tester,
    ) async {
      await pumpForm(
        tester,
        InternationalPhoneNumberInput(
          initialValue: PhoneNumber(isoCode: 'PS'),
          autovalidateMode: AutovalidateMode.always,
        ),
      );

      await tester.enterText(field, '12');
      // Times out if each validation schedules another rebuild.
      await tester.pumpAndSettle();

      expect(find.text('Invalid phone number'), findsOneWidget);
    });
  });

  group('texts', () {
    const bottomSheet = SelectorConfig(
      type: PhoneInputSelectorType.bottomSheet,
    );

    /// Pumps [input] in a form, validates it and opens the country list, so
    /// the hint, the error and the search label are all shown.
    Future<void> showAllTexts(
      WidgetTester tester,
      InternationalPhoneNumberInput input,
    ) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(app(Form(key: formKey, child: input)));
      formKey.currentState!.validate();
      await tester.pump();
      await tester.tap(find.byKey(PhoneInputKeys.selectorButton));
      await tester.pumpAndSettle();
    }

    tearDown(() => PhoneInputStrings.unregister(const Locale('sw')));

    testWidgets('can be replaced for one input', (tester) async {
      await showAllTexts(
        tester,
        const InternationalPhoneNumberInput(
          strings: PhoneInputStrings(
            hint: 'Mobile',
            requiredNumber: 'Mobile is required',
            searchLabel: 'Find a country',
          ),
          selectorConfig: bottomSheet,
        ),
      );

      expect(find.text('Mobile'), findsOneWidget);
      expect(find.text('Mobile is required'), findsOneWidget);
      expect(find.text('Find a country'), findsOneWidget);
    });

    testWidgets('come from a registered language', (tester) async {
      PhoneInputStrings.register(
        const Locale('sw'),
        const PhoneInputStrings(
          hint: 'Nambari ya simu',
          requiredNumber: 'Weka nambari ya simu',
          searchLabel: 'Tafuta nchi',
        ),
      );
      await showAllTexts(
        tester,
        const InternationalPhoneNumberInput(
          locale: Locale('sw'),
          selectorConfig: bottomSheet,
        ),
      );

      expect(find.text('Nambari ya simu'), findsOneWidget);
      expect(find.text('Weka nambari ya simu'), findsOneWidget);
      expect(find.text('Tafuta nchi'), findsOneWidget);
    });

    testWidgets('come from a built-in language', (tester) async {
      await showAllTexts(
        tester,
        const InternationalPhoneNumberInput(
          locale: Locale('fa'),
          selectorConfig: bottomSheet,
        ),
      );

      expect(find.text('شماره تلفن'), findsOneWidget);
      expect(find.text('شماره تلفن را وارد کنید'), findsOneWidget);
      expect(find.text('جستجو با نام کشور یا کد کشور'), findsOneWidget);
    });
  });
}
