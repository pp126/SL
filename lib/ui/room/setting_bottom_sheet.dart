import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/net/ws_help.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/store/room_ctrl.dart';
import 'package:app/store/room_manager_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/common/report_mixin.dart';
import 'package:app/ui/room/room_manager_page.dart';
import 'package:app/ui/room/room_rank_page.dart';
import 'package:app/ui/room/room_self_gift_dialog.dart';
import 'package:app/ui/room/setting_room_page.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SettingBottomSheet extends StatelessWidget with ReportMixin {
  final int uid;
  final int roomID;
  final int roomUid;
  final Set<String> data;

  SettingBottomSheet._(this.uid, this.roomID, this.roomUid, this.data);

  static Future to() {
    final myUid = OAuthCtrl.obj.uid;
    final roomCtrl = RoomCtrl.obj;
    final isMaster = roomCtrl.isOwner();

    final data = isMaster || RoomManagerCtrl.obj.isAdmin(myUid)
        ? {'推送首页', '房间背景', '管理员', '黑名单', '礼物', '公屏', '清空公屏', '清空魅力值', '设置榜单', '房间设置', '音频设置', '礼物记录'}
        : {'举报房间', '礼物记录'};

    return Get.showBottomSheet(
      SettingBottomSheet._(myUid, roomCtrl.roomID, roomCtrl.roomUid, data),
      bgColor: AppPalette.sheetWhite,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            '房间功能箱',
            style: TextStyle(fontSize: 16, color: AppPalette.txtDark, fontWeight: fw$SemiBold),
          ),
        ),
        GridLayout(
          childAspectRatio: 1,
          crossAxisCount: 4,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
          children: data.map(createItem).toList(growable: false),
        ),
      ],
    );
  }

  Widget createItem(String action) {
    String title;

    switch (action) {
      case '公屏':
        title = '${switchName('publicChatSwitch')}$action';
        break;
      case '礼物':
        title = '${switchName('giftEffectSwitch')}$action';
        break;
      default:
        title = action;
    }

    return Material(
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(SVG.$('room/setting/$title')),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: AppPalette.txtDark),
            ),
          ],
        ),
        onTap: () => onItemClick(title),
      ),
    );
  }

  String switchName(String key) {
    final data = RoomCtrl.obj.value;

    return data[key] == 0 ? '关闭' : '打开';
  }

  void onItemClick(String action) {
    Get.back(result: action);

    switch (action) {
      case '推送首页':
        break;
      case '管理员':
        Get.to(RoomManagerPage(RoomCtrl.obj.roomID));
        break;
      case '打开公屏':
        roomSwitch('publicChatSwitch', true);
        break;
      case '关闭公屏':
        roomSwitch('publicChatSwitch', false);
        break;
      case '打开礼物':
        roomSwitch('giftEffectSwitch', true);
        break;
      case '关闭礼物':
        roomSwitch('giftEffectSwitch', false);
        break;
      case '清空魅力值':
        simpleSub(Api.Room.deleteRoomCharm(roomUid), msg: '清空成功');
        break;
      case '设置榜单':
        Get.to(SettingRoomRankPage(RoomCtrl.obj.roomID));
        break;
      case '房间设置':
        Get.to(SettingRoomPage(RoomCtrl.obj.value));
        break;
      case '礼物记录':
        RoomSelfGiftDialog.to();
        break;
      case '黑名单':
        Get.to(RoomBlockUserPage(RoomCtrl.obj.roomID));
        break;
      case '音频设置':
        showToast('请使用背景音乐播放器设置');
        break;
      case '清空公屏':
        WsApi.clearMsg();
        break;
      case '举报房间':
        reportUser(roomUid, true);
        break;
    }
  }

  roomSwitch(String key, bool value) => simpleTry(
        () async {
          try {
            await Api.Room.roomSwitch(RoomCtrl.obj.roomID, key, value);

            switch (key) {
              case 'publicChatSwitch':
                await WsApi.settingChat(value);
                break;
              case 'giftEffectSwitch':
                await WsApi.settingGift(value);
                break;
            }
          } catch (e) {
            errLog(e);
          }
        },
      );
}
