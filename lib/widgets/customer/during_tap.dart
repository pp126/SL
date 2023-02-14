import 'package:flutter/cupertino.dart';

///间隔点击
class DuringTap {
  int time; //几秒能点击一次

  int lastTime;

  int current = DateTime.now().millisecondsSinceEpoch;

  DuringTap({int time}) : time = time ?? 1 ;

  call({GestureTapCallback onTap}) {
    current = DateTime.now().millisecondsSinceEpoch;
    if (null == lastTime) {
      onTap?.call();
      lastTime = current;
      return;
    }
    if (current - lastTime >= time * 1000) {
      onTap?.call();
      lastTime = current;
    }
  }
}