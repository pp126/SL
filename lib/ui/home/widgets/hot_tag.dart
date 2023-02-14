import 'package:app/tools.dart';
import 'package:app/ui/common/svga_icon.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:svgaplayer_flutter/player.dart';

class HotTag extends StatelessWidget {
  final int num;

  HotTag(this.num);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16,
      padding: EdgeInsets.all(2),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        color: Colors.black.withOpacity(0.2),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 14,
            child: AspectRatio(
              aspectRatio: 160 / 100,
              child: SVGAIcon(icon: 'wave'),
            ),
          ),
          NumView(num: num, prefix: 'num/yellow/', height: 11),
        ],
      ),
    );
  }
}
