
import 'package:app/common/theme.dart';
import 'package:app/widgets/customer/during_tap.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class RadiusButton extends StatelessWidget {
  final String title;
  final double width;
  final double height;
  final VoidCallback onTap;
  final Color backgroundColor;
  final TextStyle textStyle;
  final int maxLines;
  final bool disable;
  final DuringTap duringTap = DuringTap();

  RadiusButton({
    this.title,
    this.width,
    this.height = 36.0,
    this.onTap,
    this.backgroundColor = Colors.red,
    this.textStyle,
    this.maxLines = 1,
    this.disable = false,
  });

  @override
  Widget build(BuildContext context) {
    getBackgroundColor() {
      return disable ? Color(0xFFDBDBDB) : backgroundColor;
    }

    return InkWell(
      onTap: () {
        duringTap.call(onTap: onTap);
      },
      child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
              color: getBackgroundColor(),
              borderRadius: BorderRadius.all(Radius.circular(height / 2))),
          child: Center(
            child: AutoSizeText(title,
                style: textStyle ?? TextStyle(fontSize: 13),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis),
          )),
    );
  }
}

class RadiusGradientButton extends RadiusButton {
  final colorA;
  final colorB;
  final bgColor;
  final shadowColor;
  final leftIcon;
  final rightIcon;
  final borderRadius;
  final BoxBorder border;
  final Gradient gradient;
  final Offset shadowOffset;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final MainAxisAlignment mainAxisAlignment;

  RadiusGradientButton({
    this.colorA,
    this.colorB,
    this.bgColor,
    this.leftIcon,
    this.rightIcon,
    this.shadowColor,
    this.borderRadius,
    this.border,
    this.gradient,
    Offset shadowOffset,
    String title,
    double width,
    double height,
    VoidCallback onTap,
    Color backgroundColor,
    TextStyle textStyle,
    int maxLines,
    bool disable,
    EdgeInsetsGeometry padding,
    MainAxisAlignment mainAxisAlignment,
    this.margin,
  })  : shadowOffset = Offset(1.0, 5.0),
        padding = padding ?? const EdgeInsets.symmetric(horizontal: 16),
  mainAxisAlignment = mainAxisAlignment ?? MainAxisAlignment.spaceAround,
        super(
        title: title,
        width: width,
        height: height ?? 48.0,
        onTap: onTap,
        backgroundColor: backgroundColor,
        textStyle: textStyle??TextStyle(fontSize:14,color: AppPalette.dark),
        maxLines: maxLines,
        disable: disable,
      );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(height)),
        onTap: () {
          DuringTap().call(onTap: onTap);
        },
        child: Container(
          width: width,
          height: height,
          margin: margin,
          padding: padding,
          decoration: BoxDecoration(
            gradient: bgColor!=null?null:(gradient??LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[colorA??Colors.transparent, colorB??Colors.transparent],
            )),
            color: bgColor,
            borderRadius: borderRadius??BorderRadius.all(Radius.circular(height)),
            border: border,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: mainAxisAlignment,
            children: <Widget>[
              leftIcon != null
                  ? Padding(
                padding: EdgeInsets.only(right: 4.0),
                child: leftIcon,
              )
                  : SizedBox(),
              Text(title,
                  style: textStyle,
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis),
              rightIcon != null
                  ? Padding(
                padding: EdgeInsets.only(left: 4.0),
                child: rightIcon,
              )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
