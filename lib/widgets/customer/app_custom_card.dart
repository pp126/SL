import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final double minHeight;
  final double maxHeight;
  final Widget child;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final Color color;
  final Color borderColor;
  final double borderWith;
  final Color shadowColor;
  final double blurRadius;
  final double spreadRadius;
  final double height;
  final double width;
  final ImageProvider imageProvider;
  final bool showShadow;
  final VoidCallback onPress;

  CustomCard({Key key,this.child,
    this.margin,
    this.padding,
    this.minHeight,
    this.maxHeight,
    this.borderColor = Colors.transparent,
    this.borderRadius = const BorderRadius.all(Radius.circular(10.0)),
    this.color,
    this.borderWith: 1,
    this.shadowColor,
    this.blurRadius,
    this.spreadRadius,
    this.height,
    this.width,
    this.imageProvider,
    this.showShadow = false,
    this.onPress,
  }):super(key: key);

  @override
  Widget build(BuildContext context) {
    var bgColor = color??Colors.white;
    return GestureDetector(
      onTap: onPress,
      behavior: HitTestBehavior.translucent,
      child: Container(
        constraints: BoxConstraints(
            minHeight: minHeight ?? 0, maxHeight: maxHeight ?? double.infinity),
        padding: EdgeInsets.zero,
        margin: margin,
        decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(width: borderWith, color: borderColor),
            color: bgColor,
            image:null != imageProvider?DecorationImage(image: imageProvider,fit: BoxFit.fill):null,
            boxShadow: showShadow?<BoxShadow>[
              BoxShadow(
                  color: shadowColor??Color(0x0f1E1203), blurRadius: 5.0, spreadRadius: 1.5),
            ]:null
        ),
        child: Material(///防止遮挡水波纹
          color: Colors.transparent,
          child: Container(
            height:height,
            width: width,
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}


Widget xGradientCard({
  Widget child,
  ShapeBorder shape,
  TextStyle textStyle,
  VoidCallback onClick,
  Gradient gradient,
  BorderRadiusGeometry borderRadius = const BorderRadius.all(Radius.circular(10.0)),
}) {
  if (onClick != null) {
    child = InkWell(child: child, onTap: onClick);
  }

  return Container(
    decoration: BoxDecoration(
      borderRadius: shape != null ? null : borderRadius,
      gradient: gradient??LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: <Color>[Color(0xff5464CD),Color(0xff8898F7)],
      ),
    ),
    child: Material(
      color: Colors.transparent,
      child: child,
      shape: shape,
      textStyle: textStyle,
      borderRadius: shape != null ? null : borderRadius,
      clipBehavior: Clip.antiAlias,

    ),
  );
}