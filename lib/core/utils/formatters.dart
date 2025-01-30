import 'package:flutter/services.dart';

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(_, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length > 11) return newValue;

    String formatted = text;
    if (text.length > 2) formatted = '(${text.substring(0, 2)}) ${text.substring(2)}';
    if (text.length > 7) formatted = '${formatted.substring(0, 10)}-${formatted.substring(10)}';

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class CepInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(_, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length > 8) return newValue;

    String formatted = text;
    if (text.length > 5) formatted = '${text.substring(0, 5)}-${text.substring(5)}';

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
