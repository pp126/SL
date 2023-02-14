import 'package:flutter/material.dart';

class RightArrowIcon extends StatelessWidget {
  RightArrowIcon();

  static Widget child;

  @override
  Widget build(BuildContext context) {
    if (child == null) {
      child = Icon(Icons.keyboard_arrow_right, color: Theme.of(context).disabledColor);

      child = Container(
        width: 32,
        height: 32,
        padding: EdgeInsets.all(4),
        child: FittedBox(child: child),
      );
    }

    return child;
  }
}
