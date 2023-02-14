import 'dart:async';

import 'package:app/widgets.dart';
import 'package:app/widgets/overlay_mixin.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:svgaplayer_flutter/svgaplayer_flutter.dart';

class GiftEffectOverlay extends StatefulWidget with IgnorePointerOverlay {
  @override
  _GiftEffectOverlayState createState() => _GiftEffectOverlayState();
}

class _GiftEffectOverlayState extends State<GiftEffectOverlay> with SingleTickerProviderStateMixin {
  SVGAAnimationController ctrl;

  final queue = StreamQueue(GiftEffectCtrl.obj.stream);

  @override
  void initState() {
    super.initState();

    ctrl = SVGAAnimationController(vsync: this);

    Timer.run(_loop);
  }

  @override
  void dispose() {
    ctrl
      ..videoItem = null
      ..dispose();

    queue.cancel();

    super.dispose();
  }

  _loop() async {
    while (await queue.hasNext && mounted) {
      final data = await queue.next;

      ctrl
        ..videoItem = data
        ..reset();

      ctrl.forward();

      await Future.delayed(ctrl.duration);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SVGAImage(ctrl, fit: BoxFit.cover),
    );
  }
}
