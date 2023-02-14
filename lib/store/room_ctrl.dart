import 'dart:async';
import 'dart:math';

import 'package:app/event/room_event.dart';
import 'package:app/net/api.dart';
import 'package:app/net/ws_event.dart';
import 'package:app/net/ws_help.dart';
import 'package:app/rtc/rtc_help.dart';
import 'package:app/tools.dart';
import 'package:app/tools/timer_mixin.dart';

import 'oauth_ctrl.dart';

class RoomCtrl extends GetxController
    with BusDisposableMixin, TimerDisposableMixin {
  final RxMap value;
  final RxInt onlineNum;
  final int roomID, roomUid, ownerUid;
  final bool _isOwner;

  RoomCtrl(Map info)
      : roomID = info['roomId'],
        roomUid = info['uid'],
        ownerUid = info['shareUid'] ?? info['userId'] ?? info['uid'],
        _isOwner = info['isHomeowner'] == true,
        onlineNum = RxInt(max(info['onlineNum'], 1)),
        value = RxMap(info);

  // ignore: close_sinks
  final micStream = StreamController();

  bool isOwner([int uid]) => uid != null ? uid == ownerUid : _isOwner;

  @override
  void onInit() {
    super.onInit();

    Bus.fire(RoomInEvent());

    //<editor-fold desc="刷新麦位">
    final myUid = '${OAuthCtrl.obj.uid}';

    on<UpMicEvent>((event) {
      final data = event.data;

      if (data['uid'] == myUid) {
        showToast('你被邀请上麦');
      }
    });

    on<DownMicEvent>((event) {
      final data = event.data;

      if (data['uid'] == myUid) {
        RtcHelp.leaveMic();

        showToast('你被踢下麦');
      }
    });
    //</editor-fold>

    //<editor-fold desc="刷新房间各个开关">
    on<RoomSettingMsgEvent>((event) {
      switch (event.cmd.name) {
        case RoomSettingCmd.openChat:
          value['publicChatSwitch'] = 0;
          break;
        case RoomSettingCmd.closeChat:
          value['publicChatSwitch'] = 1;
          break;
        case RoomSettingCmd.openCarGift:
          value['giftCardSwitch'] = 0;
          break;
        case RoomSettingCmd.closeCarGift:
          value['giftCardSwitch'] = 1;
          break;
        case RoomSettingCmd.openGift:
          value['giftEffectSwitch'] = 0;
          break;
        case RoomSettingCmd.closeGift:
          value['giftEffectSwitch'] = 1;
          break;
      }
    });
    //</editor-fold>

    //<editor-fold desc="在线人数">
    on<ChatRoomMemberIn>((event) => onlineNum.value = event.data['online_num']);
    on<ChatRoomMemberExit>(
        (event) => onlineNum.value = max(1, (onlineNum.value - 1)));
    //</editor-fold>

    on<ChatRoomInfoUpdated>((event) {
      value
        ..clear()
        ..addAll(event.data['room_info']);
    });

    initRtc();

    addTimer(
      Timer(5.seconds, () {
        _onLine();

        addTimer(Timer.periodic(1.minutes, _onLine));
      }),
    );
  }

  initRtc() async {
    final token = await Api.Room.agoraKey(roomID);

    await RtcHelp.join(token, '$roomID', OAuthCtrl.obj.uid);
  }

  @override
  Future onClose() async {
    super.onClose();

    await simpleTry(Api.Room.leave);
    await simpleTry(WsApi.leaveRoom);

    await simpleTry(() => RtcHelp.leave(OAuthCtrl.obj.uid));

    await simpleTry(micStream.close);
  }

  void _onLine([_]) async {
    if (!isClosed) {
      final result = await Api.User.onLine();

      if (!isClosed) {
        OAuthCtrl.obj.updateLocalInfo('liveness', int.parse(result));
      }
    }
  }

  static RoomCtrl get obj => Get.find();
}

class RoomSettingCmd {
  final int _code;

  RoomSettingCmd(this._code);

  static const openChat = '开启了' + '房间内聊天';
  static const closeChat = '关闭了' + '房间内聊天';
  static const openCarGift = '已开启' + '该房间' + '座骑礼物' + '特效';
  static const closeCarGift = '已屏蔽' + '该房间' + '座骑礼物' + '特效';
  static const openGift = '已开启' + '该房间' + '小礼物' + '特效';
  static const closeGift = '已屏蔽' + '该房间' + '小礼物' + '特效';

  static const _mapper = {
    153: openChat,
    154: closeChat,
    157: closeCarGift,
    158: openCarGift,
    155: closeGift,
    156: openGift,
  };

  get name => _mapper[_code] ?? '';

  static findCode(String name) {
    for (final it in _mapper.entries) {
      if (it.value == name) return it.key;
    }

    return -1;
  }
}
