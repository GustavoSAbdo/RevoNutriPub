import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class CustomPhoneInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(PhoneNumber) onInputChanged;
  final String initialCountryIsoCode;
  final String hintText;

  const CustomPhoneInput({
    required this.controller,
    required this.onInputChanged,
    this.hintText = 'Digite seu número de telefone',
    this.initialCountryIsoCode = 'BR',
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return InternationalPhoneNumberInput(
      onInputChanged: onInputChanged,
      selectorConfig: const SelectorConfig(
        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
      ),
      ignoreBlank: false,
      autoValidateMode: AutovalidateMode.disabled,
      selectorTextStyle: const TextStyle(color: Colors.black),
      initialValue: PhoneNumber(isoCode: initialCountryIsoCode),
      textFieldController: controller,
      inputDecoration: InputDecoration(hintText: hintText, ),
      formatInput: true,
      keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
      inputBorder: const OutlineInputBorder(),
    );
  }
}
