import 'package:flutter/material.dart';

import '../formatters/arabic_to_english_digits_formatter.dart';
import '../models/country.dart';
import '../utils/country_search.dart';
import 'country_flag.dart';
import 'phone_input_keys.dart';

/// A searchable list of [countries], shown in the bottom sheet and dialog
/// selectors. Tapping a country pops the route with it.
final class CountryListView extends StatefulWidget {
  /// The countries to list, in this order until the user searches.
  final List<Country> countries;

  /// The language of the country names.
  final Locale? locale;

  /// The label of the search field, unless [searchDecoration] is given.
  final String searchLabel;

  /// The decoration of the search field. By default it shows [searchLabel].
  final InputDecoration? searchDecoration;

  /// The controller of the list, e.g. from a [DraggableScrollableSheet].
  final ScrollController? scrollController;

  /// Whether flags are shown next to the country names.
  final bool showFlags;

  /// Whether flags are emoji instead of the bundled images.
  final bool useEmoji;

  /// Whether the search field gets focus when the list is shown.
  final bool autofocus;

  /// Creates a searchable list of [countries].
  const CountryListView({
    super.key,
    required this.countries,
    required this.searchLabel,
    this.locale,
    this.searchDecoration,
    this.scrollController,
    this.showFlags = true,
    this.useEmoji = false,
    this.autofocus = false,
  });

  @override
  State<CountryListView> createState() => _CountryListViewState();
}

final class _CountryListViewState extends State<CountryListView> {
  late List<Country> _results = widget.countries;

  void _search(String query) {
    setState(() {
      _results = searchCountries(
        widget.countries,
        query,
        locale: widget.locale,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextField(
            key: PhoneInputKeys.searchField,
            decoration:
                widget.searchDecoration ??
                InputDecoration(labelText: widget.searchLabel),
            autofocus: widget.autofocus,
            inputFormatters: const [ArabicToEnglishDigitsFormatter()],
            onChanged: _search,
          ),
        ),
        Flexible(
          child: ListView.builder(
            controller: widget.scrollController,
            // Lets the dialog shrink when few countries match.
            shrinkWrap: true,
            itemCount: _results.length,
            itemBuilder: (context, index) => _CountryListTile(
              country: _results[index],
              locale: widget.locale,
              showFlag: widget.showFlags,
              useEmoji: widget.useEmoji,
            ),
          ),
        ),
      ],
    );
  }
}

final class _CountryListTile extends StatelessWidget {
  final Country country;
  final Locale? locale;
  final bool showFlag;
  final bool useEmoji;

  const _CountryListTile({
    required this.country,
    required this.locale,
    required this.showFlag,
    required this.useEmoji,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: PhoneInputKeys.countryItem(country.alpha2Code),
      leading: showFlag
          ? CountryFlag(country: country, useEmoji: useEmoji, circular: true)
          : null,
      title: Text(country.localizedName(locale)),
      // Dial codes are always left-to-right, but stay at the start of the
      // tile in right-to-left layouts.
      subtitle: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(country.dialCode, textDirection: TextDirection.ltr),
      ),
      onTap: () => Navigator.of(context).pop(country),
    );
  }
}
