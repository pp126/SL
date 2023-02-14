import 'dart:async';

import 'package:app/exception.dart';
import 'package:app/net/api.dart';
import 'package:app/net/ws_event.dart';
import 'package:app/net/ws_help.dart';
import 'package:app/rtc/rtc_help.dart';
import 'package:app/store/room_ctrl.dart';
import 'package:app/store/room_like_ctrl.dart';
import 'package:app/store/room_manager_ctrl.dart';
import 'package:app/store/room_self_gift_ctrl.dart';
import 'package:app/store/room_sticker_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/call/call_ctrl.dart';
import 'package:app/ui/room/create_room_page.dart';
import 'package:app/ui/room/room_mic_view.dart';
import 'package:app/ui/room/room_mini_view.dart';
import 'package:app/ui/room/room_msg_view.dart';
import 'package:app/ui/room/room_page.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tuple/tuple.dart';

import 'oauth_ctrl.dart';

enum RoomState { None, Normal, Mini }

class RoomOverlayCtrl extends GetxService with BusDisposableMixin {
  final _state = Rx(RoomState.None);

  @override
  void onReady() {
    super.onReady();
    Get.insertOverlay(_RoomOverlay());

    //<editor-fold desc="房间踢人">
    on<ChatRoomMemberKicked>(
      (event) => RtcHelp.leave(OAuthCtrl.obj.uid),
    );

    on<ChatRoomMemberKicked>(
      (event) async {
        final msg = event.data['reason_msg'];

        if (msg != null) {
          await Get.alertDialog(msg);
        }

        await closeState();
      },
      test: (_) => _state.value == RoomState.Mini,
    );
    //</editor-fold>

    bus(
      CMD.logout,
      (_) => closeState(),
      test: (_) => _state.value != RoomState.None,
    );
  }

  void _putCtrl(final bool isSelf, final Map info, final List queueList) {
    final roomID = info['roomId'];
    final show = info['show'];

    Get.put(RoomCtrl(info), permanent: true);
    Get.put(RoomMicCtrl(queueList), permanent: true);
    Get.put(RoomManagerCtrl(roomID), permanent: true);
    Get.put(RoomSelfGiftCtrl(), permanent: true);
    Get.put(RoomMsgCtrl(roomID,show), permanent: true);
    Get.put(RoomStickerCtrl(roomID), permanent: true);

    if (!isSelf) Get.put(RoomLikeCtrl(roomID), permanent: true);
  }

  Future _delCtrl() async {
    await Get.delete<RoomCtrl>(force: true);
    await Get.delete<RoomMicCtrl>(force: true);
    await Get.delete<RoomManagerCtrl>(force: true);
    await Get.delete<RoomSelfGiftCtrl>(force: true);
    await Get.delete<RoomMsgCtrl>(force: true);
    await Get.delete<RoomStickerCtrl>(force: true);

    await Get.delete<RoomLikeCtrl>(force: true);

    await SpeakCtrl.delAll();
  }

  void to(int roomUid, bool isSelfRoom) async {
    if (Get.isRegistered<CallCtrl>()) {
      Get.alertDialog('闪聊中，无法进入房间');

      return;
    }

    switch (_state.value) {
      case RoomState.Normal:
        return;
      case RoomState.Mini:
        try {
          final _roomUid = RoomCtrl.obj.roomUid;

          if (_roomUid == roomUid) {
            RoomPage.show();

            return;
          } else {
            if (await Get.simpleDialog(msg: '已在另一个房间，需要切换房间吗', okLabel: '切换') != '切换') return;

            // 清除原房间资源
            await closeState();
          }
        } catch (e) {
          // 忽略房间为空异常
        }

        continue join;
      join:
      case RoomState.None:
        await simpleSub(
          () async {
            final data = roomUid != -1 ? await Api.Room.info(roomUid) : await Api.Room.randomIn();

            if (data == null) {
              if (isSelfRoom) {
                Get.to(CreateRoomPage());
              } else {
                throw LogicException(-1, '房间不存在');
              }
            } else {
              final String roomPwd = data['roomPwd'];

              if (!(isSelfRoom || data['isHomeowner'] == true || roomPwd.isNullOrBlank)) {
                final String result = await holderProgress(
                  Get.showInputDialog(
                    title: '房间已加锁',
                    keyboardType: TextInputType.number,
                  ),
                );

                if (result.isNullOrBlank) {
                  return;
                } else if (result != roomPwd) {
                  throw LogicException(-1, '密码不正确');
                }
              }

              Future<void> _init(int roomUid, int roomID) async {
                if (!await Permission.microphone.request().isGranted) return;

                Future<Tuple2<Map, List>> _joinRoom(int roomUid, int roomID) async {
                  await WsHelp.init();

                  final joinInfo = await Api.Room.join(roomUid);

                  try {
                    final result = await WsApi.joinRoom(roomID);

                    return Tuple2(joinInfo, result['queue_list']);
                  } catch (e) {
                    Api.Room.leave();

                    rethrow;
                  }
                }

                final result = await _joinRoom(roomUid, roomID);

                _putCtrl(isSelfRoom, result.item1, result.item2);

                RoomPage.show();
              }

              await _init(data['uid'], data['roomId']);
            }
          },
          msg: null,
        );
        break;
    }
  }

  void miniState() => _state.value = RoomState.Mini;

  void normalState() => _state.value = RoomState.Normal;

  Future closeState() async {
    await _delCtrl();

    _state.value = RoomState.None;
  }

  static RoomOverlayCtrl get obj => Get.find();
}

class _RoomOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetX<RoomOverlayCtrl>(builder: (it) {
      switch (it._state.value) {
        case RoomState.Mini:
          return RoomMiniView(it);
        default:
          return SizedBox.shrink();
      }
    });
  }
}
