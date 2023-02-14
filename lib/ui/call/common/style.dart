import 'package:app/common/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Style {
  Style._();

  static Widget btn({String title, VoidCallback onTap, BtnStyle style}) {
    return Material(
      color: style.bgColor,
      borderRadius: style.borderRadius,
      textStyle: TextStyle(fontSize: 14, fontWeight: fw$SemiBold),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 136,
          height: BtnStyle.height,
          alignment: Alignment.center,
          child: Text(title, style: TextStyle(color: style.txtColor)),
        ),
      ),
    );
  }
}

class BtnStyle {
  final Color bgColor;
  final Color txtColor;
  final BorderRadiusGeometry borderRadius;

  static const double height = 40;

  BtnStyle({this.bgColor, this.txtColor, this.borderRadius});

  BtnStyle.left({this.bgColor = AppPalette.primary, this.txtColor = Colors.white})
      : this.borderRadius = BorderRadius.horizontal(
          left: Radius.circular(height / 2),
          right: Radius.circular(4),
        );

  BtnStyle.right({this.bgColor = AppPalette.primary, this.txtColor = Colors.white})
      : this.borderRadius = BorderRadius.horizontal(
          right: Radius.circular(height / 2),
          left: Radius.circular(4),
        );
}
