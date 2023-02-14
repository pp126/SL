import 'package:flutter/material.dart';

class AppIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onPress;
  final double width;
  final double height;
  final double iconSize;
  AppIconButton({
    this.icon,
    this.onPress,
    this.width,
    this.height,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      constraints: BoxConstraints(
        minWidth: width??32,
        minHeight: height??32,
      ),
      iconSize: iconSize??24,
      padding: EdgeInsets.zero,
      onPressed: onPress,
      icon: icon,
    );
  }
}