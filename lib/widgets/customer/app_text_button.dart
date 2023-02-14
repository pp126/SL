import 'package:app/common/theme.dart';
import 'package:app/tools.dart';
import 'package:flutter/material.dart';

class AppTextButton extends StatelessWidget {
  final title;
  final double width;
  final double height;
  final VoidCallback onPress;
  final AlignmentGeometry alignment;
  final Color bgColor;
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry margin;

  AppTextButton({
    this.title,
    this.width = 60,
    this.height = 40,
    this.onPress,
    this.alignment,
    this.bgColor = Colors.transparent,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    Widget _title;

    if (title is String) {
      _title = Text(title, style: TextStyle(fontSize: 14,color: AppPalette.dark));
    } else if (title is Widget) {
      _title = title;
    }
    return xFlatButton(
      height,
      bgColor??Colors.transparent,
      width: width,
      margin: margin,
      padding: EdgeInsets.zero,
      alignment: alignment,
      onTap: onPress,
      borderRadius: borderRadius,
      child: _title,
    );
  }
}
