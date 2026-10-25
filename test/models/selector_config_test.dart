import 'package:flutter_test/flutter_test.dart';
import 'package:phone_number_input/phone_number_input.dart';

void main() {
  test('has documented defaults', () {
    const config = SelectorConfig();

    expect(config.type, PhoneInputSelectorType.dropdown);
    expect(config.showFlags, isTrue);
    expect(config.useEmoji, isFalse);
    expect(config.countryComparator, isNull);
    expect(config.asPrefixIcon, isFalse);
    expect(config.spacing, 12);
    expect(config.leadingPadding, 0);
    expect(config.trailingSpace, isTrue);
    expect(config.textStyle, isNull);
    expect(config.searchDecoration, isNull);
    expect(config.autofocusSearch, isFalse);
    expect(config.isScrollControlled, isTrue);
    expect(config.useSafeArea, isFalse);
  });
}
