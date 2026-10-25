# Changelog

## 1.0.0

First release of `smart_phone_input`.

It started as a fork of [intl_phone_number_input](https://pub.dev/packages/intl_phone_number_input)
0.7.5 and was rewritten with a new API, so it is not a drop-in replacement.
See [Migrating from intl_phone_number_input](README.md#migrating-from-intl_phone_number_input).

### Features

- `InternationalPhoneNumberInput`, a form field with a country selector as a
  dropdown, bottom sheet or dialog, using the parameter names of
  `TextFormField`.
- `PhoneNumber`, an immutable value with the country, the digits as typed, the
  E.164 form, validity, type and formatting, plus `PhoneNumber.tryParse`.
- Formatting as you type in the national style of each country, with or
  without the national prefix, e.g. `0599 123 456`.
- Typed or pasted international numbers, such as `+966 50 123 4567` or
  `00966…`, switch to their country.
- Arabic-Indic and Persian digits are converted as they are typed.
- The country search ignores case, accents, Arabic letter variants,
  diacritics and the article ال, and ranks the best matches first.
- Country names and texts follow the locale. Texts are built in for 22
  languages, and apps can override them or register more.
- The first country comes from the device's locale when there is no initial
  value. Favorite countries can be listed first.
- `Countries` lookups by ISO code and dial code, and `PhoneInputKeys` for
  widget tests.
- 249 countries and territories, including Sint Maarten and Western Sahara.
- Depends only on Flutter and `dlibphonenumber`.

### Fixes compared to intl_phone_number_input 0.7.5

- Autovalidation no longer rebuilds the field on every frame.
- The selected country is no longer reset when the parent rebuilds.
- `onSaved` reports the same number as `onChanged`.
- Formatting no longer flickers or loses digits while typing fast, and
  backspace over a separator works.
- `maxDigits` counts digits, not spaces and dashes.
- Malformed initial values and unknown country codes no longer throw.
- The selector stays level with the text when an error appears.
- Dial codes shared by several countries, such as `+1`, return the main
  country.
