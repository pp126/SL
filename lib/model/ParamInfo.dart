import 'dart:ui';

class ParamInfo{
  final int type;
  final String name;
  final String iconPath;
  final VoidCallback onPress;
  final bool diviler;

  ParamInfo({
    this.type,
    this.name,
    this.iconPath,
    this.onPress,
    this.diviler = false,
  });
}