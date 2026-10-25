import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone_number_input/phone_number_input.dart';
import 'package:phone_number_input/src/widgets/country_flag.dart';

void main() {
  final palestine = Countries.byIsoCode('PS')!;

  testWidgets('loads the flag image from this package', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: CountryFlag(country: palestine, useEmoji: false)),
    );

    final image = tester.widget<Image>(find.byType(Image)).image;
    final key = await (image as AssetImage).obtainKey(ImageConfiguration.empty);

    // Fails when the package name in CountryFlag does not match pubspec.yaml,
    // which would otherwise hide every flag without an error.
    expect(key.name, 'packages/phone_number_input/${palestine.flagAsset}');
    expect(await rootBundle.load(key.name), isNotNull);
  });

  testWidgets('shows the emoji flag', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: CountryFlag(country: palestine, useEmoji: true)),
    );

    expect(find.text('🇵🇸'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });
}
