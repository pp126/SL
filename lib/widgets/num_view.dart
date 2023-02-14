import 'package:app/tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class NumView extends StatelessWidget {
  final num;
  final double height;
  final String prefix;
  final MainAxisAlignment mainAxisAlignment;

  NumView({@required this.num, this.prefix, this.height = 9, this.mainAxisAlignment = MainAxisAlignment.start});

  static final _format = NumberFormat('00');

  @override
  Widget build(BuildContext context) {
    String _num;

    if (num is int) {
      _num = _format.format(num);
    } else {
      _num = '$num';
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      children: _num.characters //
          .map((it) {
        if (it.isNum) {
          return SvgPicture.asset(SVG.$('$prefix$it'), height: height);
        } else {
          return  SizedBox.shrink();
//          return debugView(child: SizedBox(width: height, height: height));
        }
      }).toList(growable: false),
    );
  }
}
