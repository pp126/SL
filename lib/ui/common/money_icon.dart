import 'package:app/tools.dart';
import 'package:flutter/material.dart';

class MoneyIcon extends StatelessWidget {
  final double size;
  final String type;

  MoneyIcon({this.type = '海星', this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Image.asset(IMG.$(type), width: size, height: size, scale: 3);
  }
}
