import 'package:app/common/theme.dart';
import 'package:flutter/material.dart';
import 'package:app/tools.dart';

// text aligns vertically, from top to bottom and right to left.
//
// 垂直布局的文字. 从右上开始排序到左下角.
class VerticalText extends CustomPainter {
  String text;
  double width;
  double height;
  TextStyle textStyle;

  VerticalText(
      {@required this.text,
        @required this.textStyle,
        @required this.width,
        @required this.height});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = new Paint();
    paint.color = textStyle.color;
    double offsetX = width;
    double offsetY = 0;
    bool newLine = true;
    double maxWidth = 0;

    maxWidth = findMaxWidth(text, textStyle);

    text.runes.forEach((rune) {
      String str = new String.fromCharCode(rune);
      TextSpan span = new TextSpan(style: textStyle, text: str);
      TextPainter tp = new TextPainter(
          text: span,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr);
      tp.layout();

      if (offsetY + tp.height > height) {
        newLine = true;
        offsetY = 0;
      }

      if (newLine) {
        offsetX -= maxWidth;
        newLine = false;
      }

      if (offsetX < -maxWidth) {
        return;
      }

      tp.paint(canvas, new Offset(offsetX, offsetY));
      offsetY += tp.height;
    });
  }

  double findMaxWidth(String text, TextStyle style) {
    double maxWidth = 0;

    text.runes.forEach((rune) {
      String str = new String.fromCharCode(rune);
      TextSpan span = new TextSpan(style: style, text: str);
      TextPainter tp = new TextPainter(
          text: span,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr);
      tp.layout();
      maxWidth = max(maxWidth, tp.width);
    });

    return maxWidth;
  }

  @override
  bool shouldRepaint(VerticalText oldDelegate) {
    return oldDelegate.text != text ||
        oldDelegate.textStyle != textStyle ||
        oldDelegate.width != width ||
        oldDelegate.height != height;
  }

  double max(double a, double b) {
    if (a > b) {
      return a;
    } else {
      return b;
    }
  }
}

class VerticalTextContainer extends StatelessWidget {
  final String text;
  final double width;
  final double height;
  final TextStyle textStyle;
  final double topPadding;
  final double leftPadding;
  final Color bgColor;
  final BoxBorder border;
  final BorderRadiusGeometry borderRadius;
  final topIcon;
  final VoidCallback onTap;

  VerticalTextContainer({
    String text,
    double width,
    double height,
    TextStyle textStyle,
    this.topIcon,
    this.topPadding = 3,
    this.leftPadding = 2,
    this.bgColor =  AppPalette.txtWhite,
    this.border,
    BorderRadiusGeometry borderRadius,
    this.onTap,
  }):text = text,
        width = width ?? 24,
        height = height ?? 74,
        textStyle = textStyle??TextStyle(
          color: AppPalette.primary,
          fontSize: 10,
        ),
        borderRadius = BorderRadius.all(Radius.circular(width?? 24)),
        super();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        topIcon != null
            ? Padding(
          padding: EdgeInsets.only(bottom: 0.0),
          child: topIcon,
        )
            : SizedBox(),
        Text(text,style: textStyle,),
      ],
    ).toBtn(
      height,
      bgColor,
      padding: EdgeInsets.fromLTRB(leftPadding,topPadding,leftPadding,topPadding),
      radius: width,
      onTap: onTap,
    );
  }
}