import 'package:flutter/services.dart';

class PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {

    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digits.length > 10) {
      digits = digits.substring(0, 10);
    }

    String formatted = '';

    if (digits.isNotEmpty) {
      formatted = '(';
    }
    if (digits.length >= 1) {
      formatted += digits.substring(0, digits.length >= 3 ? 3 : digits.length);
    }
    if (digits.length >= 3) {
      formatted += ') ';
      formatted += digits.substring(3, digits.length >= 6 ? 6 : digits.length);
    }
    if (digits.length >= 6) {
      formatted += '-';
      formatted += digits.substring(6, digits.length);
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}