/// @docImport '../widgets/international_phone_number_input.dart';
library;

import 'package:flutter/material.dart';

import 'country.dart';

/// Compares two countries to sort the selector's list.
///
/// ```dart
/// CountryComparator byDialCode = (a, b) => a.dialCode.compareTo(b.dialCode);
/// ```
typedef CountryComparator = int Function(Country a, Country b);

/// How the country selector shows the list of countries.
enum PhoneInputSelectorType {
  /// A dropdown menu next to the text field.
  dropdown,

  /// A searchable list in a modal bottom sheet.
  bottomSheet,

  /// A searchable list in a dialog.
  dialog,
}

/// The appearance and behavior of the country selector of
/// [InternationalPhoneNumberInput].
///
/// ```dart
/// const SelectorConfig(
///   type: PhoneInputSelectorType.bottomSheet,
///   useEmoji: true,
///   asPrefixIcon: true,
/// )
/// ```
@immutable
final class SelectorConfig {
  /// How the list of countries is shown. Defaults to
  /// [PhoneInputSelectorType.dropdown].
  final PhoneInputSelectorType type;

  /// Whether flags are shown next to dial codes and country names. Defaults
  /// to true.
  final bool showFlags;

  /// Whether flags are emoji instead of the bundled images. Defaults to
  /// false.
  ///
  /// Emoji flags need no assets, but some platforms, such as Windows, do not
  /// draw them.
  final bool useEmoji;

  /// Sorts the list of countries. By default they are sorted by their name
  /// in the current locale.
  final CountryComparator? countryComparator;

  /// Whether the selector is shown inside the text field, as its prefix
  /// icon, instead of next to it. Defaults to false.
  final bool asPrefixIcon;

  /// The space between the selector and the text field when [asPrefixIcon]
  /// is false. Defaults to 12.
  final double spacing;

  /// The space before the flag in the selector button. Defaults to 0.
  final double leadingPadding;

  /// Whether short dial codes such as `+1` are padded with spaces, so the
  /// selector keeps a similar width when the country changes. Defaults to
  /// true.
  final bool trailingSpace;

  /// The style of the dial code in the selector button.
  final TextStyle? textStyle;

  /// The decoration of the search field of the bottom sheet and the dialog.
  /// By default it shows a translated label.
  final InputDecoration? searchDecoration;

  /// Whether the search field gets focus when the bottom sheet or the dialog
  /// opens. Defaults to false.
  final bool autofocusSearch;

  /// Whether the bottom sheet can take the full screen height, see
  /// [showModalBottomSheet]. Defaults to true.
  final bool isScrollControlled;

  /// Whether the bottom sheet avoids system UI such as the status bar, see
  /// [showModalBottomSheet]. Defaults to false.
  final bool useSafeArea;

  /// Creates a selector configuration. Every option has a default.
  const SelectorConfig({
    this.type = PhoneInputSelectorType.dropdown,
    this.showFlags = true,
    this.useEmoji = false,
    this.countryComparator,
    this.asPrefixIcon = false,
    this.spacing = 12,
    this.leadingPadding = 0,
    this.trailingSpace = true,
    this.textStyle,
    this.searchDecoration,
    this.autofocusSearch = false,
    this.isScrollControlled = true,
    this.useSafeArea = false,
  });
}
