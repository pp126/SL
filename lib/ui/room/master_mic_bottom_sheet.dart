import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/net/ws_help.dart';
import 'package:app/rtc/rtc_help.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/store/room_ctrl.dart';
import 'package:app/store/room_manager_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/room/dialog/setting_mic_dialog.dart';
import 'package:app/ui/room/room_user_page.dart';
import 'package:app/ui/room/user_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import 'room_mic_view.dart';

class MasterMicBottomSheet extends StatelessWidget {
  final List<Tuple3<String, Color, Function>> action;

  static void show(RoomMicInfo info, int position) {
    final roomCtrl = RoomCtrl.obj;

    final roomID = roomCtrl.roomID;
    final roomUid = roomCtrl.roomUid;
    final myUid = OAuthCtrl.obj.uid;
    final posUid = info?.user?.uid;
    final posNickName = info?.user?.nickName;

    final managerCtrl = RoomManagerCtrl.obj;

    final hasUser = posUid != null;
    final isAdmin = managerCtrl.isAdmin(myUid);
    final posAdmin = hasUser && managerCtrl.isAdmin(posUid);
    final isMaster = roomCtrl.isOwner();
    final canManage = isMaster || isAdmin;
    final isSelf = hasUser && posUid == myUid;

    // 用来绕过im的权限管理
    final _myUid = isMaster ? roomUid : myUid;

    final state = info?.state ?? RoomMicState();

    final posEnable = state.posEnable;
    final micEnable = state.micEnable;

    final action = [
      if (hasUser && !isSelf)
        Tuple3(
          '查看资料',
          Color(0xFF71E8D4),
          () => UserBottomSheet.to(posUid),
        ),
      if (hasUser && !isSelf && canManage)
        Tuple3(
          '抱Ta' + '下麦',
          Color(0xFF64E06F),
          () => WsApi.micDown(posUid, position),
        ),
      if (!hasUser && canManage)
        Tuple3(
          '抱Ta' + '上麦',
          Color(0xFF64E06F),
          () => RoomUserPage.to((uid) => WsApi.micUp(uid, position)),
        ),
      if (micEnable && canManage)
        Tuple3(
          '禁' + '麦此麦位',
          Color(0xFFFFBE25),
          () => Api.Room.lockMic(roomUid, position, false),
        ),
      if (!micEnable && canManage)
        Tuple3(
          '解' + '禁此麦位',
          Color(0xFFFFBE25),
          () => Api.Room.lockMic(roomUid, position, true),
        ),
      if (posEnable && canManage)
        Tuple3(
          '封' + '锁此座位',
          Color(0xFFFF9940),
          () {
            //锁此座位
            Api.Room.lockPos(roomUid, position, false);
            //如果有人就踢人下麦
            if (posUid != null) {
              WsApi.micDown(posUid, position);
            }
          },
        ),
      if (!posEnable && canManage)
        Tuple3(
          '解' + '锁此座位',
          Color(0xFFFF9940),
          () => Api.Room.lockPos(roomUid, position, true),
        ),
      if (canManage)
        Tuple3(
          '设置座位',
          AppPalette.pink,
          () => SettingMicDialog.to(
              (type) => Api.Room.setMicType(roomUid, position, type)),
        ),
      if (hasUser && canManage)
        Tuple3(
          '清空魅力值',
          Color(0xFFD94E78),
          () => simpleSub(
              Api.Room.receiveRoomMicMsg(roomCtrl.roomUid, userid: posUid),
              msg: '清空成功'),
        ),
      if (hasUser && !isSelf && canManage && !roomCtrl.isOwner(posUid))
        Tuple3(
          '踢出房间',
          Color(0xFFD94E78),
          () async {
            await Api.Room.kickMember(_myUid, roomID, posUid);
            await WsApi.tips('[$posNickName]已被踢出本房间');
          },
        ),
      if (hasUser && !isSelf && !posAdmin && canManage)
        Tuple3(
          '加入黑名单',
          Color(0xFFEF6464),
          () => Api.Room.setRoomBlack(roomID, posUid, true),
        ),
      if (hasUser && !posAdmin && isMaster && !isSelf)
        Tuple3(
          '添加' + '管理员',
          Color(0xFF5B87FF),
          () => Api.Room.setRoomAdmin(_myUid, roomID, posUid, true),
        ),
      if (hasUser && posAdmin && isMaster && !isSelf)
        Tuple3(
          '移除' + '管理员',
          Color(0xFF5B87FF),
          () => Api.Room.setRoomAdmin(_myUid, roomID, posUid, false),
        ),
      if (roomUid != myUid && !hasUser && posEnable)
        Tuple3(
            '移到此座位',
            Color(0xFF7C66FF),
            () async => {
                  if (await Get.simpleDialog(msg: '确定上麦？', okLabel: '确定') ==
                      '确定')
                    {
                      WsApi.joinMic(position, myUid),
                    }
                }),
      if (isSelf)
        Tuple3(
          '下麦旁听',
          Color(0xFF7C66FF),
          () async {
            if (await Get.simpleDialog(msg: '确定下麦？', okLabel: '确定') == '确定') {
              RtcHelp.leaveMic();

              WsApi.leaveMic(position);
            }
          },
        ),
    ];

    switch (action.length) {
      case 0:
        break;
      case 1:
        action.single.item3();
        break;
      default:
        Get.showBottomSheet(
          MasterMicBottomSheet._(action),
          isScrollControlled: false,
          bgColor: AppPalette.sheetDark,
        );
    }
  }

  MasterMicBottomSheet._(this.action);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: GridView.count(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        shrinkWrap: true,
        crossAxisCount: 2,
        mainAxisSpacing: 15,
        crossAxisSpacing: 10,
        childAspectRatio: 145 / 40,
        children: action.map(xBtn).toList(growable: false),
      ),
    );
  }

  Widget xBtn(Tuple3<String, Color, Function> data) {
    final color = data.item2;
    return Material(
      color: color,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: InkWell(
        child: Container(
          height: 40,
          alignment: Alignment.center,
          child: Text(
            data.item1,
            style: TextStyle(
                fontSize: 14, color: Colors.white, fontWeight: fw$SemiBold),
          ),
        ),
        onTap: () {
          Get.back();

          data.item3();
        },
      ),
    );
  }
}
