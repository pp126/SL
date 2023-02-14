
import 'package:app/common/theme.dart';
import 'package:app/tools.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TipPop extends StatelessWidget {
  final Widget child;//点击child事件
  final double left; //距离左边位置
  final double top; //距离上面位置

  TipPop({
    @required this.child,
    this.left,
    this.top,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: GestureDetector(
            onTap: Get.back,
            child: Stack(children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.transparent,
              ),
              Positioned(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: AppPalette.hint),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: child,
                  ),
                  left: left,
                  top: top)
            ])));
  }
}
