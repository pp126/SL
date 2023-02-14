import 'package:flutter/material.dart';

class MyFontText extends StatelessWidget {
  final String name;
  final TextStyle style;
  final bool showIndicator;
  final Gradient gradient;

  MyFontText(this.name,{
    this.style,
    this.showIndicator = false,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: <Widget>[
          showIndicator
              ? Positioned(
            bottom: 4,
            left: 0,
            right: 0,
            child: Container(
              width: 10,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(2.0)),
                gradient: gradient??LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[Color(0xff353AFF), Color(0xffFF47B4)],
                ),
              ),
            ),
          ) : SizedBox(),
          Text(
            name,
            style: style.copyWith(fontFamily: 'FZTextFont'),
          ),
        ],
      ),
    );
  }
}