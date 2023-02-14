import 'package:intl/intl.dart';

class NumUtils {
  static num str2Num(String numStr) {
    if (numStr == null || numStr.isEmpty) {
      return 0;
    }
    int length = numStr.length;
    int index = numStr.indexOf('.');
    if (length < 2 || index == -1 || index == 0) {
      return num.parse(numStr);
    }
    if (length - index >= 3) {
      return num.parse(numStr.substring(0, index + 3));
    }
    return num.parse(numStr);
  }

  static getDouble(double number, int length) {
    if (length == 0) {
      return number.toInt();
    }
    String sn = number.toStringAsFixed(length);
    return double.parse(sn);
  }


  static num strCeil(String numStr){
    return num.parse(numStr).ceil();
  }
}


extension xNum on num {
  String format({String pattern = '0.##'}) => NumberFormat(pattern).format(this);
}

extension xStringNum on String {
  String format({String pattern = '0.##'}) => num.parse(this).format(pattern: pattern);
}
