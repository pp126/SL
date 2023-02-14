import 'package:flutter/material.dart';

class Spacing extends StatelessWidget {
  final double width;
  final double height;
  final int flex;

  const Spacing({Key key, this.width, this.height, this.flex = 1}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget widget = SizedBox(width: width, height: height);

    if (flex != null) {
      widget = Expanded(flex: flex, child: widget);
    }

    return widget;
  }

  //默认左中边距
  static const double margin_h = 16;

  //默认间距
  static const double _normal = 8;

  //半间距
  static const double _half = 4;

  //双倍间距
  static const double _double = 16;

  static const exp = Spacing();

  static const wn = _WSpacing(_normal);
  static const wh = _WSpacing(_half);
  static const wd = _WSpacing(_double);

  static const w2 = _WSpacing(2);
  static const w4 = _WSpacing(4);
  static const w6 = _WSpacing(6);
  static const w8 = _WSpacing(8);
  static const w10 = _WSpacing(10);
  static const w12 = _WSpacing(12);
  static const w16 = _WSpacing(16);
  static const w32 = _WSpacing(32);
  static const w40 = _WSpacing(40);

  static const hn = _HSpacing(_normal);
  static const hh = _HSpacing(_half);
  static const hd = _HSpacing(_double);

  static const h2 = _HSpacing(2);
  static const h4 = _HSpacing(4);
  static const h6 = _HSpacing(6);
  static const h8 = _HSpacing(8);
  static const h10 = _HSpacing(10);
  static const h12 = _HSpacing(12);
  static const h16 = _HSpacing(16);
  static const h20 = _HSpacing(20);
  static const h32 = _HSpacing(32);
  static const h54 = _HSpacing(54);
}

class _WSpacing extends Spacing {
  const _WSpacing(double width) : super(width: width, flex: null);

  _WSpacing operator *(double operand) => new _WSpacing(width * operand);

  _WSpacing operator /(double operand) => new _WSpacing(width / operand);
}

class _HSpacing extends Spacing {
  const _HSpacing(double height) : super(height: height, flex: null);

  _HSpacing operator *(double operand) => new _HSpacing(height * operand);

  _HSpacing operator /(double operand) => new _HSpacing(height / operand);
}
