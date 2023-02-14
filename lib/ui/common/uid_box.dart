import 'package:app/common/theme.dart';
import 'package:app/tools.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

class UidBox extends StatelessWidget {
  final Map data;
  final bool hasBG;
  final Color color;
  final double height;

  UidBox({this.data, this.hasBG = true, this.height = 16, this.color});

  static final _txtStyle = TextStyle(
    fontSize: 12,
    color: AppPalette.primary,
  );
  static final _bg = ShapeDecoration(
    color: AppPalette.txtWhite,
    shape: StadiumBorder(),
  );

  @override
  Widget build(BuildContext context) {
    var txtStyle = _txtStyle;

    if (color != null) {
      txtStyle = txtStyle.copyWith(color: color);
    }

    Widget child = SelectableText(
      'ID:${data['erbanNo'] ?? data['userNo']}',
      style: txtStyle,
      toolbarOptions: ToolbarOptions(copy: true),
    );

    if (hasBG) {
      child = Container(
        height: height,
        decoration: _bg,
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: 6, right: 4),
        child: child,
      );
    }

    final isPretty = data['hasPrettyErbanNo'] == true;

    child = Row(
      children: [
        if (isPretty) ...[
          Image.asset(IMG.$('靓号'), height: height, scale: 4),
          Spacing.w2,
        ],
        child,
      ],
    );

    return child;
  }
}
