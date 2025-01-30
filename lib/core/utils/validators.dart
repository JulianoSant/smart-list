import 'package:flutter/services.dart';

bool validateCPF(String cpf) {
  cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
  if (cpf.length != 11) return false;
  return true;
}

class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(_, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length > 11) return newValue;

    String formatted = text;
    if (text.length > 3) formatted = '${text.substring(0, 3)}.${text.substring(3)}';
    if (text.length > 6) formatted = '${formatted.substring(0, 7)}.${formatted.substring(7)}';
    if (text.length > 9) formatted = '${formatted.substring(0, 11)}-${formatted.substring(11)}';

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
