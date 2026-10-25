import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../formatters/arabic_to_english_digits_formatter.dart';
import '../formatters/as_you_type_formatter.dart';
import '../formatters/international_number_formatter.dart';
import '../formatters/max_digits_formatter.dart';
import '../l10n/phone_input_strings.dart';
import '../models/countries.dart';
import '../models/country.dart';
import '../models/phone_number.dart';
import '../models/selector_config.dart';
import '../utils/country_search.dart';
import 'country_selector_button.dart';
import 'phone_input_keys.dart';

/// A phone number form field with a country selector.
///
/// It formats the number as it is typed, validates it with libphonenumber
/// and reports a [PhoneNumber] on every change:
///
/// ```dart
/// InternationalPhoneNumberInput(
///   initialValue: PhoneNumber(isoCode: 'SY'),
///   onChanged: (number) => print(number.e164), // +963944123456, or null
///   selectorConfig: const SelectorConfig(
///     type: PhoneInputSelectorType.bottomSheet,
///   ),
/// )
/// ```
///
/// It also:
/// * converts Arabic and Persian digits to ASCII digits,
/// * switches the country when an international number such as `+966…` or
///   `00966…` is typed or pasted,
/// * shows country names and its own texts in the language of [locale],
/// * starts with the device's country when [initialValue] is null.
final class InternationalPhoneNumberInput extends StatefulWidget {
  /// The number shown first. Its country is selected when it is one of
  /// [countries].
  ///
  /// A new value replaces what the user typed, except the value last passed
  /// to [onChanged], so feeding [onChanged] back into this is safe.
  final PhoneNumber? initialValue;

  /// Called when the user changes the number or the country.
  final ValueChanged<PhoneNumber>? onChanged;

  /// Called by [FormState.save].
  final ValueChanged<PhoneNumber>? onSaved;

  /// Returns an error for the number, or null when it is acceptable.
  ///
  /// By default, a number that is not valid gets the error
  /// [PhoneInputStrings.invalidNumber], and an empty one gets
  /// [PhoneInputStrings.requiredNumber] unless [allowEmpty] is true.
  final String? Function(PhoneNumber number)? validator;

  /// Whether the default [validator] accepts an empty field. Defaults to
  /// false.
  final bool allowEmpty;

  /// Called when the user submits the field, see [TextField.onSubmitted].
  final ValueChanged<String>? onFieldSubmitted;

  /// See [TextField.onEditingComplete].
  final VoidCallback? onEditingComplete;

  /// The controller of the text field, which holds the digits after the
  /// dial code. One is created when this is null.
  final TextEditingController? controller;

  /// See [TextField.focusNode].
  final FocusNode? focusNode;

  /// The decoration of the text field. By default it shows a translated
  /// hint.
  final InputDecoration? decoration;

  /// See [TextField.style].
  final TextStyle? style;

  /// See [TextField.textAlign].
  final TextAlign textAlign;

  /// See [TextField.textAlignVertical].
  final TextAlignVertical? textAlignVertical;

  /// See [TextField.cursorColor].
  final Color? cursorColor;

  /// See [TextField.keyboardType]. Defaults to [TextInputType.phone].
  final TextInputType keyboardType;

  /// See [TextField.textInputAction].
  final TextInputAction? textInputAction;

  /// Whether the text field and the selector accept input. Defaults to true.
  final bool enabled;

  /// See [TextField.autofocus].
  final bool autofocus;

  /// See [FormField.autovalidateMode].
  final AutovalidateMode? autovalidateMode;

  /// See [TextField.autofillHints]. Defaults to
  /// [AutofillHints.telephoneNumber], whose international numbers switch
  /// the country.
  final Iterable<String>? autofillHints;

  /// See [TextField.scrollPadding].
  final EdgeInsets scrollPadding;

  /// Whether the number is formatted as it is typed, e.g. `0944 123 456`.
  /// When false, only digits are shown. Defaults to true.
  final bool formatInput;

  /// The maximum number of digits. Formatting characters do not count.
  /// Defaults to 15, the longest international number. 0 means no limit.
  final int maxDigits;

  /// Whether Arabic-Indic (`٠-٩`) and Persian (`۰-۹`) digits are converted
  /// to ASCII digits. Without this, they are dropped. Defaults to true.
  final bool convertArabicDigits;

  /// More formatters for the text field.
  ///
  /// They run after the Arabic digit conversion and before the [maxDigits]
  /// limit and the formatting, so they receive the text as typed.
  final List<TextInputFormatter>? inputFormatters;

  /// The ISO codes of the countries to choose from, e.g. `['SY', 'LB']`.
  /// All countries are available when this is null.
  final List<String>? countries;

  /// The ISO codes of the countries listed first in the selector, in this
  /// order.
  final List<String> favoriteCountries;

  /// The language of the country names and the default texts. Defaults to
  /// the app's locale.
  final Locale? locale;

  /// The texts to show instead of those for [locale], see
  /// [PhoneInputStrings].
  ///
  /// ```dart
  /// strings: PhoneInputStrings(
  ///   hint: l10n.phoneHint,
  ///   invalidNumber: l10n.phoneInvalid,
  ///   requiredNumber: l10n.phoneRequired,
  ///   searchLabel: l10n.countrySearch,
  /// ),
  /// ```
  final PhoneInputStrings? strings;

  /// The appearance and behavior of the country selector.
  final SelectorConfig selectorConfig;

  /// Creates a phone number input.
  const InternationalPhoneNumberInput({
    super.key,
    this.initialValue,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.allowEmpty = false,
    this.onFieldSubmitted,
    this.onEditingComplete,
    this.controller,
    this.focusNode,
    this.decoration,
    this.style,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.cursorColor,
    this.keyboardType = TextInputType.phone,
    this.textInputAction,
    this.enabled = true,
    this.autofocus = false,
    this.autovalidateMode,
    this.autofillHints = const [AutofillHints.telephoneNumber],
    this.scrollPadding = const EdgeInsets.all(20),
    this.formatInput = true,
    this.maxDigits = 15,
    this.convertArabicDigits = true,
    this.inputFormatters,
    this.countries,
    this.favoriteCountries = const [],
    this.locale,
    this.strings,
    this.selectorConfig = const SelectorConfig(),
  });

  @override
  State<InternationalPhoneNumberInput> createState() =>
      _InternationalPhoneNumberInputState();
}

final class _InternationalPhoneNumberInputState
    extends State<InternationalPhoneNumberInput> {
  TextEditingController? _ownController;
  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());

  /// The countries of [InternationalPhoneNumberInput.countries].
  late List<Country> _available;

  /// [_available] in the selector's order, for [_orderedLocale].
  List<Country>? _ordered;
  Locale? _orderedLocale;

  late Country _country;

  /// The value last passed to [InternationalPhoneNumberInput.onChanged].
  PhoneNumber? _lastReported;

  PhoneNumber get _value =>
      PhoneNumber(isoCode: _country.alpha2Code, digits: _controller.text);

  @override
  void initState() {
    super.initState();
    _available = _availableCountries();
    _country = _initialCountry();
    _show(widget.initialValue);
  }

  @override
  void didUpdateWidget(InternationalPhoneNumberInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      if (widget.controller == null) {
        _ownController = TextEditingController(
          text: oldWidget.controller?.text,
        );
      } else {
        _ownController?.dispose();
        _ownController = null;
      }
    }

    final countriesChanged = !listEquals(oldWidget.countries, widget.countries);
    if (countriesChanged) {
      _available = _availableCountries();
      if (!_available.contains(_country)) {
        _country = _initialCountry();
      }
    }
    if (countriesChanged ||
        !listEquals(oldWidget.favoriteCountries, widget.favoriteCountries) ||
        oldWidget.selectorConfig.countryComparator !=
            widget.selectorConfig.countryComparator) {
      _ordered = null;
    }

    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _lastReported) {
      _show(widget.initialValue);
    }
  }

  @override
  void dispose() {
    _ownController?.dispose();
    super.dispose();
  }

  List<Country> _availableCountries() {
    final countries = Countries.filter(widget.countries);
    assert(
      countries.isNotEmpty,
      'None of the countries ${widget.countries} is a known ISO 3166-1 '
      'alpha-2 code.',
    );
    return countries.isEmpty ? Countries.all : countries;
  }

  /// The country of the initial value, the device's country, the first
  /// favorite or the first country, whichever is available first.
  Country _initialCountry() {
    final candidates = [
      widget.initialValue?.isoCode,
      WidgetsBinding.instance.platformDispatcher.locale.countryCode,
      ...widget.favoriteCountries,
    ];
    for (final isoCode in candidates) {
      final country = isoCode == null ? null : Countries.byIsoCode(isoCode);
      if (country != null && _available.contains(country)) {
        return country;
      }
    }
    return _available.first;
  }

  /// Shows [number] in the field, without reporting it.
  void _show(PhoneNumber? number) {
    if (number == null) {
      return;
    }
    final country = number.country;
    if (_available.contains(country)) {
      _country = country;
    }
    _setDigits(number.digits);
  }

  void _setDigits(String digits) {
    final text = widget.formatInput
        ? AsYouTypeFormatter.formatDigits(digits, _country)
        : digits;
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _report() {
    final value = _value;
    _lastReported = value;
    widget.onChanged?.call(value);
  }

  void _onCountrySelected(Country country) {
    if (country == _country) {
      return;
    }
    setState(() => _country = country);
    _setDigits(_value.digits);
    _report();
  }

  /// Called while formatting, before [TextFormField.onChanged] reports the
  /// new text.
  void _onCountryDetected(Country country) {
    setState(() => _country = country);
  }

  List<Country> _orderedCountries(Locale? locale) {
    if (_ordered != null && _orderedLocale == locale) {
      return _ordered!;
    }
    final comparator = widget.selectorConfig.countryComparator;
    final List<Country> sorted;
    if (comparator != null) {
      sorted = [..._available]..sort(comparator);
    } else {
      final names = {
        for (final country in _available)
          country: normalizeForSearch(country.localizedName(locale)),
      };
      sorted = [..._available]..sort((a, b) => names[a]!.compareTo(names[b]!));
    }

    final favorites = <Country>{
      for (final isoCode in widget.favoriteCountries)
        if (Countries.byIsoCode(isoCode) case final country?
            when _available.contains(country))
          country,
    };
    _orderedLocale = locale;
    return _ordered = [
      ...favorites,
      ...sorted.where((country) => !favorites.contains(country)),
    ];
  }

  String? _validate(PhoneNumber number, PhoneInputStrings strings) {
    final validator = widget.validator;
    if (validator != null) {
      return validator(number);
    }
    if (number.isEmpty) {
      return widget.allowEmpty ? null : strings.requiredNumber;
    }
    return number.isValid ? null : strings.invalidNumber;
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale ?? Localizations.maybeLocaleOf(context);
    final strings = widget.strings ?? PhoneInputStrings.of(locale);
    final config = widget.selectorConfig;

    final selector = CountrySelectorButton(
      country: _country,
      countries: _orderedCountries(locale),
      config: config,
      locale: locale,
      searchLabel: strings.searchLabel,
      enabled: widget.enabled,
      onChanged: _onCountrySelected,
    );

    var decoration = widget.decoration ?? const InputDecoration();
    if (decoration.hintText == null && decoration.hint == null) {
      decoration = decoration.copyWith(hintText: strings.hint);
    }
    if (config.asPrefixIcon) {
      decoration = decoration.copyWith(prefixIcon: selector);
    }

    final field = TextFormField(
      key: PhoneInputKeys.textField,
      controller: _controller,
      focusNode: widget.focusNode,
      decoration: decoration,
      // Phone numbers are written left to right in every language.
      textDirection: TextDirection.ltr,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      style: widget.style,
      textAlign: widget.textAlign,
      textAlignVertical: widget.textAlignVertical,
      cursorColor: widget.cursorColor,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      autovalidateMode: widget.autovalidateMode,
      autofillHints: widget.autofillHints,
      scrollPadding: widget.scrollPadding,
      inputFormatters: [
        if (widget.convertArabicDigits) const ArabicToEnglishDigitsFormatter(),
        InternationalNumberFormatter(
          country: () => _country,
          isAllowed: _available.contains,
          onCountryDetected: _onCountryDetected,
        ),
        ...?widget.inputFormatters,
        MaxDigitsFormatter(widget.maxDigits),
        if (widget.formatInput)
          AsYouTypeFormatter(() => _country)
        else
          // Keeps a leading + until InternationalNumberFormatter knows the
          // country.
          FilteringTextInputFormatter.allow(RegExp(r'^\+|\d')),
      ],
      onChanged: (_) => _report(),
      onFieldSubmitted: widget.onFieldSubmitted,
      onEditingComplete: widget.onEditingComplete,
      validator: (_) => _validate(_value, strings),
      onSaved: (_) => widget.onSaved?.call(_value),
    );

    if (config.asPrefixIcon) {
      return field;
    }
    // Aligning baselines keeps the selector level with the text when an
    // error appears below the field.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        selector,
        SizedBox(width: config.spacing),
        Expanded(child: field),
      ],
    );
  }
}
