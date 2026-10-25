/// @docImport 'international_phone_number_input.dart';
library;

import 'package:flutter/widgets.dart';

/// Keys of the widgets inside [InternationalPhoneNumberInput], for finding
/// them in widget tests.
///
/// ```dart
/// await tester.enterText(find.byKey(PhoneInputKeys.textField), '0599123456');
/// await tester.tap(find.byKey(PhoneInputKeys.selectorButton));
/// ```
abstract final class PhoneInputKeys {
  /// The phone number text field.
  static const Key textField = Key('smart_phone_input_text_field');

  /// The button that shows the selected country and opens the selector.
  static const Key selectorButton = Key('smart_phone_input_selector_button');

  /// The search field of the bottom sheet and dialog selectors.
  static const Key searchField = Key('smart_phone_input_search_field');

  /// The item of the country [isoCode] in the selector, e.g. `PS`.
  static Key countryItem(String isoCode) =>
      Key('smart_phone_input_country_${isoCode.toUpperCase()}');
}
