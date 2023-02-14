import 'package:flutter/services.dart';

///只能输入数字和字母
class OnlyInputNumberAndWorkFormatter extends TextInputFormatter {
  static const _regExp = r"^[ZA-ZZa-z0-9_]+$";

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length > 0) {
      if (RegExp(_regExp).firstMatch(newValue.text) != null) {
        return newValue;
      }
      return oldValue;
    }
    return newValue;
  }
}

///只能输入数字
class OnlyInputNumberFormatter extends TextInputFormatter {
  static const _regExp = r"^[0-9]+$";

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length > 0) {
      if (RegExp(_regExp).firstMatch(newValue.text) != null) {
        return newValue;
      }
      return oldValue;
    }
    return newValue;
  }
}
