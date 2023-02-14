import 'package:app/common/theme.dart';
import 'package:app/net/ws_event.dart';
import 'package:app/rtc/rtc_help.dart';
import 'package:app/store/call_overlay_ctrl.dart';
import 'package:app/store/room_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/call/call_ctrl.dart';
import 'package:app/ui/call/call_find_view.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CallPage extends StatefulWidget {
  CallPage._();

  static void show() async {
    if (Get.isRegistered<RoomCtrl>()) {
      Bus.fire(ChatRoomMemberKicked({}));

      await Future.delayed(kTabScrollDuration);
    }

    await Get.to(
      CallPage._(),
      popGesture: false,
      duration: Duration.zero,
      transition: Transition.noTransition,
    );

    final ctrl = CallOverlayCtrl.obj;

    if (Get.isRegistered<CallCtrl>()) {
      ctrl.backState();
    } else if (ctrl.showRx.value) {
      ctrl.miniState();
    }
  }

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> with BusStateMixin {
  @override
  void initState() {
    super.initState();

    onFrameEnd((_) => CallOverlayCtrl.obj.hideState());

    bus(CMD.call_finish, (msg) {
      Get.untilByCtx(context);

      CallCtrl.finish(msg);
    });
  }

  @override
  Widget build(BuildContext context) {
    final exitBtn = IconButton(icon: SvgPicture.asset(SVG.$('call/缩小')), onPressed: Get.back);

    return Scaffold(
      backgroundColor: AppPalette.dark,
      appBar: xAppBar(null, leading: exitBtn, bgColor: Colors.transparent),
      body: SafeArea(
        minimum: AppSize.safeAreaMini,
        child: DefaultTextStyle(
          style: TextStyle(color: Colors.white, fontWeight: fw$SemiBold),
          child: Column(
            children: [
              Expanded(
                child: GetX<CallCtrl>(
                  builder: (it) {
                    final user = it.targetUser.value;

                    return user == null ? FindStatusView() : _CallStatusView(user);
                  },
                ),
              ),
              _BottomActionView(),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomActionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final audioSwitch = RtcHelp.audioSwitch;
    final micSwitch = RtcHelp.micSwitch;

    return Row(
      children: [
        Spacing(flex: 48),
        $CircleBtn(
          child: ObxValue<RxBool>((it) => SvgPicture.asset(SVG.$('call/麦克风_${it.isFalse ? 0 : 1}')), micSwitch),
          onTap: micSwitch.toggle,
        ),
        Spacing(flex: 30),
        $CircleBtn(
          child: Text('挂断', style: TextStyle(fontSize: 14)),
          bgColor: Color(0xFFDE4065),
          width: 106,
          onTap: doClose,
        ),
        Spacing(flex: 30),
        $CircleBtn(
          child: ObxValue<RxBool>((it) => SvgPicture.asset(SVG.$('call/喇叭_${it.isFalse ? 0 : 1}')), audioSwitch),
          onTap: audioSwitch.toggle,
        ),
        Spacing(flex: 48),
      ],
    );
  }

  Widget $CircleBtn({Widget child, double width: 56, Color bgColor = const Color(0xFF4A4476), VoidCallback onTap}) {
    return InkResponse(
      onTap: onTap,
      child: Container(
        decoration: ShapeDecoration(shape: StadiumBorder(), color: bgColor),
        alignment: Alignment.center,
        height: 56,
        width: width,
        child: child,
      ),
    );
  }

  void doClose() {
    Get.back();

    CallCtrl.finish();
  }
}

class _CallStatusView extends StatelessWidget {
  final TargetUser data;

  _CallStatusView(this.data);

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: fw$SemiBold),
      child: Column(
        children: [
          Spacing.h32,
          RectAvatarView(url: data.avatar),
          Spacing.h32,
          Text(data.nick ?? ''),
          Spacing.exp,
          CallCtrl.useCallTimer(builder: (it) => Text(it)),
          Spacing.h32,
        ],
      ),
    );
  }
}
