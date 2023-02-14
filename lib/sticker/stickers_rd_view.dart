import 'dart:async';

import 'package:app/store/room_sticker_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StickersRdView extends StatefulWidget {
  final int num;
  final StickersInfo info;

  StickersRdView(Map data, this.info)
      : num = data['num'],
        super(key: ObjectKey(data));

  @override
  _StickersRdViewState createState() => _StickersRdViewState();
}

class _StickersRdViewState extends State<StickersRdView> with SingleTickerProviderStateMixin {
  final _status = RxBool(false);

  AnimationController _ctrl;
  Animation<int> _anime;
  Timer _timer;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(vsync: this, duration: Duration(milliseconds: 618)) //
      ..repeat();

    _timer = Timer(Duration(milliseconds: 1618), () {
      _ctrl.stop(canceled: false);

      _status.value = true;
    });

    final ext = widget.info.ext;

    _anime = StepTween(begin: ext['min'], end: ext['max']) //
        .animate(_ctrl);
  }

  @override
  void dispose() {
    _timer.cancel();
    _ctrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _status.value
          ? $View(widget.num)
          : AnimatedBuilder(
              animation: _anime,
              builder: (_, __) => $View(_anime.value),
            ),
    );
  }

  Widget $View(int num) {
    return GiftImgState(
      child: NetImage(widget.info.getRes(num), optimization: false),
    );
  }
}

class Stickers3RdViewX extends StickersRdView {
  Stickers3RdViewX(Map data, StickersInfo info) : super(data, info);

  @override
  _Stickers3RdState createState() => _Stickers3RdState();
}

class _Stickers3RdState extends _StickersRdViewState {
  @override
  Widget $View(int num) => Container(child: Stickers3RdView(num, widget.info), width: 48);
}

class Stickers3RdView extends StatelessWidget {
  final List<String> num;
  final StickersInfo info;

  Stickers3RdView(int num, this.info) : num = _format.format(num).split('');

  static final _format = NumberFormat('000');
  static final _scale = 6;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.fitWidth,
      alignment: Alignment.center,
      child: Container(
        width: 342 / _scale,
        height: 182 / _scale,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetImage.provider0(Uri.parse(info.getRes('bg'))),
            fit: BoxFit.fill,
          ),
        ),
        child: Container(
          height: 81 / _scale,
          padding: EdgeInsets.only(left: 20 / _scale, right: 64 / _scale, bottom: 30 / _scale),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: num.map($View).toList(growable: false),
          ),
        ),
      ),
    );
  }

  Widget $View(String num) {
    return Container(
      width: 81 / _scale,
      height: 107 / _scale,
      child: GiftImgState(
        child: NetImage(info.getRes(num), optimization: false),
      ),
    );
  }
}
