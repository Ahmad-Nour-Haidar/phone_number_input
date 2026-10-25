import 'package:flutter/material.dart';
import 'package:phone_number_input/phone_number_input.dart';

void main() => runApp(const ExampleApp());

final class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

final class _ExampleAppState extends State<ExampleApp> {
  bool _arabic = false;

  @override
  Widget build(BuildContext context) {
    final locale = _arabic ? const Locale('ar') : const Locale('en');
    return MaterialApp(
      title: 'phone_number_input',
      theme: ThemeData(colorSchemeSeed: Colors.teal),
      builder: (context, child) => Directionality(
        textDirection: _arabic ? TextDirection.rtl : TextDirection.ltr,
        child: child!,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Phone number input'),
          actions: [
            TextButton(
              onPressed: () => setState(() => _arabic = !_arabic),
              child: Text(_arabic ? 'English' : 'العربية'),
            ),
          ],
        ),
        body: PhoneForm(locale: locale),
      ),
    );
  }
}

final class PhoneForm extends StatefulWidget {
  const PhoneForm({super.key, required this.locale});

  /// The language of the country names and the input's texts.
  final Locale locale;

  @override
  State<PhoneForm> createState() => _PhoneFormState();
}

final class _PhoneFormState extends State<PhoneForm> {
  final _formKey = GlobalKey<FormState>();

  PhoneNumber _number = PhoneNumber(isoCode: 'SY');
  PhoneNumber? _saved;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          InternationalPhoneNumberInput(
            // Feeding the reported number back is safe: the field keeps the
            // text and cursor the user typed.
            initialValue: _number,
            onChanged: (number) => setState(() => _number = number),
            onSaved: (number) => setState(() => _saved = number),
            locale: widget.locale,
            favoriteCountries: const ['SY', 'LB', 'JO', 'SA'],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              helperText: 'Try ٠٩٤٤١٢٣٤٥٦, or paste +966 50 123 4567',
            ),
            selectorConfig: const SelectorConfig(
              type: PhoneInputSelectorType.bottomSheet,
              useSafeArea: true,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(onPressed: _submit, child: const Text('Save')),
              OutlinedButton(
                onPressed: () => setState(
                  () => _number = PhoneNumber.tryParse('+966501234567')!,
                ),
                child: const Text('Fill a Saudi number'),
              ),
              OutlinedButton(
                onPressed: () =>
                    setState(() => _number = PhoneNumber(isoCode: 'SY')),
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _Row('Country', '${_number.isoCode} (${_number.dialCode})'),
          _Row('Digits', _number.digits),
          _Row('E.164', _number.e164 ?? '—'),
          _Row('International', _number.format()),
          _Row('Type', _number.type.name),
          _Row('Saved', _saved?.e164 ?? '—'),
        ],
      ),
    );
  }
}

final class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(child: Text(value, textDirection: TextDirection.ltr)),
        ],
      ),
    );
  }
}
