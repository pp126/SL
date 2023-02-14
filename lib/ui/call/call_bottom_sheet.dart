import 'dart:async';

import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/net/ws_event.dart';
import 'package:app/tools.dart';
import 'package:app/tools/timer_mixin.dart';
import 'package:app/ui/call/call_ctrl.dart';
import 'package:app/ui/call/common/style.dart';
import 'package:app/ui/common/gender_icon.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/mine/page/user_page.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/level_view.dart';
import 'package:flutter/material.dart';

class CallBottomSheet extends StatefulWidget {
  final CallPushEvent event;

  CallBottomSheet(this.event);

  @override
  _CallBottomSheetState createState() => _CallBottomSheetState();
}

class _CallBottomSheetState extends State<CallBottomSheet> with TimerStateMixin {
  Map data;
  RxInt rxTime;

  @override
  void initState() {
    super.initState();
    data = widget.event.data;
    rxTime = RxInt(data['time']);

    ever(rxTime, (it) {
      if (it <= 0) {
        Get.back();
      }
    });

    addTimer(Timer.periodic(1.seconds, (_) => rxTime.value -= 1));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          InkWell(
            onTap: () => Get.to(UserPage(uid: data['uid']), preventDuplicates: false),
            child: Transform.translate(
              offset: Offset(0, -33),
              child: AvatarView(url: data['avatar'], side: BorderSide(width: 6, color: Colors.white), size: 66),
            ),
          ),
          Positioned.fill(
            top: 43,
            child: Column(
              children: [
                Text(
                  data['nick'],
                  style: TextStyle(fontSize: 16, color: AppPalette.txtDark, fontWeight: fw$SemiBold),
                ),
                Spacing.h8,
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GenderIcon(data['gender']),
                    WealthIcon(data: data),
                    CharmIcon(data: data),
                  ].separator(Spacing.w4),
                ),
                Spacing.exp,
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'ta发起了 '),
                      TextSpan(text: '闪聊', style: TextStyle(color: AppPalette.primary)),
                      TextSpan(text: ' 需求，渴望您的陪伴'),
                    ],
                  ),
                  style: TextStyle(fontSize: 14, color: AppPalette.tips, fontWeight: fw$SemiBold),
                ),
                Spacing.exp,
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Style.btn(
                      title: '忽略',
                      style: BtnStyle.left(bgColor: Color(0xFFFFE9E9), txtColor: Color(0xFFE02020)),
                      onTap: doRefuse,
                    ),
                    Spacing.w4,
                    Style.btn(
                      title: '接听',
                      style: BtnStyle.right(),
                      onTap: doAccept,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            width: 32,
            height: 32,
            child: Material(
              color: Color(0xFFFFE9E9),
              borderRadius: BorderRadius.circular(6),
              textStyle: TextStyle(fontSize: 12, color: Color(0xFFE02020), fontWeight: fw$SemiBold),
              child: Center(
                child: ObxValue<RxInt>((it) => Text('${it}s'), rxTime),
              ),
            ),
          )
        ],
      ),
    );
  }

  void doRefuse() {
    Get.back();

    if ('直聊' == widget.event.type) {
      Api.Home.refuseFlashChat(data['roomId']);
    }
  }

  void doAccept() async {
    Get.back();

    final api = Api.Home.acceptFlashChat(data['roomId']);

    simpleSub(
      api,
      msg: null,
      callback: () async {
        CallCtrl.putByAccept(
          TargetUser(nick: data['nick'], avatar: data['avatar']),
          await api,
        );
      },
    );
  }
}
