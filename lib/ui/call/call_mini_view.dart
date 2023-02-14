import 'dart:async';
import 'dart:math';

import 'package:app/common/theme.dart';
import 'package:app/store/call_overlay_ctrl.dart';
import 'package:app/store/rd_avatar_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/tools/timer_mixin.dart';
import 'package:app/ui/call/call_ctrl.dart';
import 'package:app/ui/call/call_page.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sequence_animation/flutter_sequence_animation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tuple/tuple.dart';

class CallMiniView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      bottom: 104 + Get.bottomBarHeight / Get.pixelRatio,
      width: 167,
      height: 46,
      child: DefaultTextStyle(
        style: TextStyle(fontSize: 14, color: Colors.white),
        child: GestureDetector(
          child: $Body(),
          onTap: () async {
            if (!await Permission.microphone.request().isGranted) return;

            CallOverlayCtrl.obj.to();
          },
        ),
      ),
    );
  }

  Widget $Body() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(999)),
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [Color(0xFFCE7EFF), Color(0xFF7C66FF)],
        ),
      ),
      child: Row(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Center(child: SvgPicture.asset(SVG.$('call/语聊'))),
          ),
          Spacing.w4,
          Text(
            '闪聊',
            style: TextStyle(fontWeight: fw$SemiBold),
          ),
          Spacing.w16,
          Expanded(child: _AnimeView()),
        ],
      ),
    );
  }
}

class _AnimeView extends StatefulWidget {
  @override
  __AnimeViewState createState() => __AnimeViewState();
}

class __AnimeViewState extends State<_AnimeView> with TickerProviderStateMixin, TimerStateMixin {
  final views = RxList(<Tuple2<AnimationController, Widget>>[]);

  final avatarCtrl = Get.find<RdAvatarCtrl>();

  @override
  void initState() {
    super.initState();

    views //
      ..add($View($Anime(0.5)))
      ..add($View($Anime()));

    addTimer(
      Timer.periodic(1.seconds, (_) {
        views.add($View($Anime()));
      }),
    );
  }

  @override
  void dispose() {
    views
      ..forEach((it) {
        try {
          it.item1.dispose();
        } catch (e) {
          //ignore
        }
      })
      ..clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ObxValue<RxList<Tuple2<AnimationController, Widget>>>(
      (it) => Stack(
        alignment: Alignment.centerLeft,
        children: it.map((it) => it.item2).toList(growable: false),
      ),
      views,
    );
  }

  Tuple2<AnimationController, Widget> $View(Tuple2<AnimationController, SequenceAnimation> anime) {
    final data = avatarCtrl.value;

    final _ctrl = anime.item1;
    final _anime = anime.item2['pos'];

    final out = Tuple2(
      _ctrl,
      AnimatedBuilder(
        key: UniqueKey(),
        animation: _ctrl,
        child: $Avatar(isEmpty(data) ? '' : data[Random.secure().nextInt(data.length)]),
        builder: (_, child) {
          return Positioned(left: _anime.value, child: child);
        },
      ),
    );

    final _tmp = Expando<AnimationStatusListener>();

    _ctrl.addStatusListener(
      _tmp[out] = (it) {
        if (it == AnimationStatus.completed) {
          _ctrl.removeStatusListener(_tmp[out]);

          _ctrl.dispose();

          addTimer(
            Timer(0.618.seconds, () => views.remove(out)),
          );
        }
      },
    );

    return out;
  }

  Tuple2<AnimationController, SequenceAnimation> $Anime([double forward = 0]) {
    final ctrl = AnimationController(vsync: this, duration: 2.seconds);

    final anime = //
        SequenceAnimationBuilder()
            .addAnimatable(animatable: Tween(begin: 56.0, end: 22.0), from: 0.seconds, to: 0.618.seconds, tag: 'pos')
            .addAnimatable(animatable: Tween(begin: 22.0, end: 0.0), from: 1.3.seconds, to: 2.seconds, tag: 'pos')
            .animate(ctrl);

    ctrl.forward(from: forward);

    return Tuple2(ctrl, anime);
  }

  Widget $Avatar(String url) {
    return AvatarView(
      url: url,
      size: 32,
      side: BorderSide(color: Color(0x80F1EEFF), width: 2),
    );
  }
}

class CallBackView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: Get.height * 0.3,
      right: 16,
      width: 75,
      height: 105,
      child: DefaultTextStyle(
        style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: fw$SemiBold),
        child: GestureDetector(child: $Body(), onTap: CallPage.show),
      ),
    );
  }

  Widget $Body() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xE6252142),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Spacing.exp,
          GetX<CallCtrl>(builder: (it) {
            final user = it.targetUser.value;

            return AvatarView(url: user?.avatar, size: 54);
          }),
          Container(
            height: 40,
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: CallCtrl.useCallTimer(builder: (it) => Text(it)),
            ),
          ),
        ],
      ),
    );
  }
}
