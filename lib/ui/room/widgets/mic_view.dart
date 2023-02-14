import 'package:app/common/theme.dart';
import 'package:flutter/material.dart';

class MicView extends StatelessWidget {
  final Widget icon;

  MicView(this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Color(0x1A7C66FF),
        border: Border.all(width: 2, color: AppPalette.txtWhite),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: icon,
    );
  }
}
