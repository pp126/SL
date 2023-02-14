import 'package:app/tools.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

Widget get _errView {
  if (isDebug) return Container(color: Colors.red);

  return SizedBox.shrink();
}

class TagIcon extends StatelessWidget {
  final String tag;

  TagIcon({this.tag});

  @override
  Widget build(BuildContext context) {
    return ConfigImgState(
      errView: _errView,
      loading: SizedBox.shrink(),
      child: NetImage(tag, width: 32, height: 15),
    );
  }
}
