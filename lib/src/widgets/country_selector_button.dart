import 'package:flutter/material.dart';

import '../models/country.dart';
import '../models/selector_config.dart';
import 'country_label.dart';
import 'country_list_view.dart';
import 'phone_input_keys.dart';

/// Shows the selected [country] and lets the user pick another one of
/// [countries], as [config] describes.
final class CountrySelectorButton extends StatelessWidget {
  /// The selected country.
  final Country country;

  /// The countries to choose from, in the order they are listed.
  final List<Country> countries;

  /// How the selector looks and lists the countries.
  final SelectorConfig config;

  /// The language of the country names.
  final Locale? locale;

  /// The label of the search field of the bottom sheet and the dialog.
  final String searchLabel;

  /// Whether the user can pick another country.
  final bool enabled;

  /// Called with the country the user picks.
  final ValueChanged<Country> onChanged;

  /// Creates a button that shows [country] and opens the selector.
  const CountrySelectorButton({
    super.key,
    required this.country,
    required this.countries,
    required this.config,
    required this.locale,
    required this.searchLabel,
    required this.enabled,
    required this.onChanged,
  });

  CountryLabel _label(Country country, {Key? key}) => CountryLabel(
    key: key,
    country: country,
    showFlag: config.showFlags,
    useEmoji: config.useEmoji,
    leadingPadding: config.leadingPadding,
    trailingSpace: config.trailingSpace,
    textStyle: config.textStyle,
  );

  @override
  Widget build(BuildContext context) {
    final canSelect = enabled && countries.length > 1;

    if (config.type == PhoneInputSelectorType.dropdown) {
      if (countries.length < 2) {
        return _label(country);
      }
      final heightFactor = config.dropdownMaxHeightFactor;
      return DropdownButtonHideUnderline(
        child: DropdownButton<Country>(
          key: PhoneInputKeys.selectorButton,
          value: country,
          menuMaxHeight: heightFactor == null
              ? null
              : MediaQuery.sizeOf(context).height * heightFactor,
          items: [
            for (final country in countries)
              DropdownMenuItem(
                value: country,
                child: _label(
                  country,
                  key: PhoneInputKeys.countryItem(country.alpha2Code),
                ),
              ),
          ],
          onChanged: canSelect
              ? (country) {
                  if (country != null) onChanged(country);
                }
              : null,
        ),
      );
    }

    return MaterialButton(
      key: PhoneInputKeys.selectorButton,
      padding: EdgeInsets.zero,
      minWidth: 0,
      onPressed: canSelect ? () => _pick(context) : null,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(end: 8),
        child: _label(country),
      ),
    );
  }

  Future<void> _pick(BuildContext context) async {
    final selected = config.type == PhoneInputSelectorType.bottomSheet
        ? await _showBottomSheet(context)
        : await _showDialog(context);
    if (selected != null) {
      onChanged(selected);
    }
  }

  CountryListView _listView({ScrollController? scrollController}) =>
      CountryListView(
        countries: countries,
        locale: locale,
        searchLabel: searchLabel,
        searchDecoration: config.searchDecoration,
        scrollController: scrollController,
        showFlags: config.showFlags,
        useEmoji: config.useEmoji,
        autofocus: config.autofocusSearch,
      );

  Future<Country?> _showDialog(BuildContext context) {
    final textDirection = Directionality.of(context);
    return showDialog<Country>(
      context: context,
      builder: (context) => AlertDialog(
        content: Directionality(
          textDirection: textDirection,
          child: SizedBox(width: double.maxFinite, child: _listView()),
        ),
      ),
    );
  }

  Future<Country?> _showBottomSheet(BuildContext context) {
    const radius = BorderRadius.vertical(top: Radius.circular(12));
    final textDirection = Directionality.of(context);
    return showModalBottomSheet<Country>(
      context: context,
      clipBehavior: Clip.hardEdge,
      isScrollControlled: config.isScrollControlled,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: radius),
      useSafeArea: config.useSafeArea,
      builder: (context) => Stack(
        children: [
          // Without a child, this fills the Stack, so tapping the empty
          // area above the sheet closes it.
          GestureDetector(onTap: () => Navigator.pop(context)),
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: DraggableScrollableSheet(
              builder: (context, scrollController) => Directionality(
                textDirection: textDirection,
                child: Material(
                  color: Theme.of(context).canvasColor,
                  clipBehavior: Clip.antiAlias,
                  shape: const RoundedRectangleBorder(borderRadius: radius),
                  child: _listView(scrollController: scrollController),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
