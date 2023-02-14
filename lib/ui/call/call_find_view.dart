import 'dart:async';

import 'package:app/common/theme.dart';
import 'package:app/store/rd_avatar_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/tools/timer_mixin.dart';
import 'package:app/ui/common/svga_icon.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:svgaplayer_flutter/svgaplayer_flutter.dart';

class FindStatusView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.fitWidth,
      child: Container(
        width: 375,
        height: 548,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              children: [
                Spacing.h54,
                Text('正在为您匹配有缘人', style: TextStyle(fontSize: 20)),
                Spacing.h16,
                Text(
                  '小羊马上配发一个小可爱',
                  style: TextStyle(fontSize: 12, color: AppPalette.primary, fontWeight: fw$Regular),
                ),
                Spacing.h32,
                SelfView(size: 72, circle: false),
              ],
            ),
            Positioned(
              top: 72,
              width: 360,
              child: AspectRatio(
                aspectRatio: 1098 / 1381,
                child: _AnimeView(),
              ),
            ),
            Positioned(
              top: 220,
              width: 125,
              child: AspectRatio(
                aspectRatio: 500 / 441,
                child: SVGAImg(assets: SVGA.$('心')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimeView extends StatefulWidget {
  @override
  _AnimeViewState createState() => _AnimeViewState();
}

class _AnimeViewState extends State<_AnimeView> with SingleTickerProviderStateMixin, TimerStateMixin {
  static final _assets = SVGAParser.shared.decodeFromAssets(SVGA.$('雷达效果'));

  SVGAAnimationController _ctrl;

  @override
  void initState() {
    super.initState();

    _ctrl = SVGAAnimationController(vsync: this);

    _assets.then((videoItem) {
      if (!mounted) return;

      _ctrl
        ..videoItem = videoItem
        ..repeat();

      final avatarCtrl = Get.find<RdAvatarCtrl>();
      final dynamicItem = videoItem.dynamicItem;

      rdImage([_]) {
        var i = 1;

        avatarCtrl.take5.forEach((it) async => dynamicItem.setImage(await it, 'img_${i++}'));
      }

      rdImage();

      addTimer(Timer.periodic(_ctrl.duration, rdImage));
    });
  }

  @override
  void dispose() {
    _ctrl
      ..videoItem = null
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SVGAImage(_ctrl);
}
