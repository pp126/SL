import 'dart:async';

import 'package:app/net/api.dart';
import 'package:app/rtc/rtc_help.dart';
import 'package:app/store/call_overlay_ctrl.dart';
import 'package:app/store/mq_ctrl.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/tools/timer_mixin.dart';
import 'package:app/ui/call/call_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class CallCtrl extends GetxController with TimerDisposableMixin {
  final String room;
  final String token;
  final String topic;
  final bool isCaller;
  final int timeOut;
  final Rx<TargetUser> targetUser;

  CallCtrl._({this.room, this.token, this.topic, this.timeOut, TargetUser target, this.isCaller = false}) //
      : targetUser = Rx(target);

  final mqCtrl = MqCtrl.obj;
  final myUid = OAuthCtrl.obj.uid;

  final activeRx = RxInt(0);

  @override
  void onInit() async {
    super.onInit();

    if (isCaller) {
      addTimer(
        Timer(
          timeOut.seconds,
          () => Bus.send(CMD.call_finish, '未找到需要的人'),
        ),
      );
    } else {
      _startCallTimer();
    }

    mqCtrl.sub(topic, (data) {
      switch (data['type']) {
        case 1 /*已接收*/ :
          _onAccept(data);
          break;
        case 2 /*已结束*/ :
          _onStop(data);
          break;
        case 3 /*心跳*/ :
          Api.Home.activationFlashChat(room);
          break;
        case 4 /*心跳*/ :
          Api.Home.activationFlashChatOnLine(room);
          break;
        case 5 /*余额不足*/ :
          _onNoMoney(data);
          break;
      }
    });

    await RtcHelp.join(token, room, myUid);
  }

  @override
  void onClose() async {
    Api.Home.refuseFlashChat(room);

    mqCtrl.unsub(topic);

    await RtcHelp.leave(myUid);

    CallOverlayCtrl.obj.callHold.unLock();

    super.onClose();
  }

  void _onStop(Map data) {
    Bus.send(CMD.call_finish, data['msg']);
  }

  void _onNoMoney(Map data) {
    Bus.send(
      CMD.call_finish,
      isCaller ? data['msg'] : '因[余额不足]，已结束闪聊',
    );
  }

  void _onAccept(Map data) {
    cancelTimer();

    targetUser.value = TargetUser(nick: data['targetNick'], avatar: data['targetAvatar']);
    _startCallTimer();
  }

  void _startCallTimer() => addTimer(Timer.periodic(1.seconds, (_) => activeRx.value += 1));

  //接收人
  static void putByAccept(TargetUser target, Map data) {
    CallOverlayCtrl.obj.callHold.lock();

    Get.put(
      CallCtrl._(
        room: data['roomId'],
        token: data['channelKey'],
        topic: data['key'],
        target: target,
      ),
      permanent: true,
    );

    CallPage.show();
  }

  //拨打人
  static void putByDial(Map data) {
    CallOverlayCtrl.obj.callHold.lock();

    Get.put(
      CallCtrl._(
        room: data['roomId'],
        token: data['channelKey'],
        topic: data['key'],
        timeOut: data['time'],
        isCaller: true,
      ),
      permanent: true,
    );

    CallPage.show();
  }

  static void finish([String msg]) {
    Get.delete<CallCtrl>(force: true);

    if (msg != null) Get.alertDialog(msg);
  }

  static Widget useCallTimer({@required final Widget Function(String) builder}) {
    final format = NumberFormat('00');

    return GetX<CallCtrl>(
      builder: (it) {
        final time = it.activeRx.value;

        if (time <= 0) return Text('接通中');

        return builder('${time ~/ 60} : ${format.format(time % 60)}');
      },
    );
  }
}

class TargetUser {
  final String nick;
  final String avatar;

  TargetUser({this.nick, this.avatar});
}
