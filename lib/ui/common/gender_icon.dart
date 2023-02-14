import 'package:app/tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class GenderIcon extends StatelessWidget {
  final int gender;

  GenderIcon(this.gender);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(SVG.$('mine/性别_$gender'));
  }
}
