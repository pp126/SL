import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/net/ws_help.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/store/room_ctrl.dart';
import 'package:app/store/room_manager_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/tools/common_utils.dart';
import 'package:app/ui/common/report_mixin.dart';
import 'package:app/ui/common/uid_box.dart';
import 'package:app/ui/message/chat/chat_page.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/mine/page/user_page.dart';
import 'package:app/ui/red_envelope/chat_red_envelope_page.dart';
import 'package:app/ui/room/gift_bottom_sheet.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/level_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tuple/tuple.dart';

class UserBottomSheet extends StatelessWidget with ReportMixin {
  final Map data;
  final int roomID;
  final _CanManage canManage;

  UserBottomSheet._(this.data, this.roomID, this.canManage);

  final _key = GlobalKey<XFutureBuilderState>();

  static to(int uid, {bool roomMode = true}) {
    if (roomMode) {
      simpleSub(
        () async {
          final data = await Api.User.info(uid);

          final roomCtrl = RoomCtrl.obj;
          final mgrCtrl = RoomManagerCtrl.obj;

          final isMaster = roomCtrl.isOwner();
          final myUid = OAuthCtrl.obj.uid;

          Get.showBottomSheet(
            UserBottomSheet._(
              data,
              roomCtrl.roomID,
              (isMaster || mgrCtrl.isAdmin(myUid)) &&
                      !(roomCtrl.isOwner(uid) || mgrCtrl.isAdmin(uid)) //
                  ? _CanManage(
                      isMaster ? roomCtrl.roomUid /*用来绕过im的权限管理*/ : myUid)
                  : null,
            ),
          );
        },
        msg: null,
      );
    } else {
      simpleSub(
        () async {
          final data = await Api.User.info(uid);

          Get.showBottomSheet(UserBottomSheet._(data, null, null));
        },
        msg: null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final action2 = ['逛逛ta的主页', '举报'];

    if (canManage != null) {
      action2 //
        ..add('踢出房间')
        ..add('加入黑名单');
    }

    return Container(
      height: 200,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        children: [
          InkWell(
            onTap: () =>
                Get.to(UserPage(uid: data['uid']), preventDuplicates: false),
            child: Transform.translate(
              offset: Offset(12, -33),
              child: AvatarView(
                  url: data['avatar'],
                  side: BorderSide(width: 6, color: Colors.white),
                  size: 66),
            ),
          ),
          Positioned.fill(
            top: 43,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      data['nick'],
                      style: TextStyle(
                          fontSize: 16,
                          color: AppPalette.txtDark,
                          fontWeight: fw$SemiBold),
                    ),
                    SvgPicture.asset(SVG.$('mine/性别_${data['gender']}')),
                    WealthIcon(data: data),
                    CharmIcon(data: data),
                  ].separator(Spacing.w4),
                ),
                Spacing.h8,
                Row(
                  children: [
                    UidBox(data: data, hasBG: false, color: AppPalette.primary),
                    Spacing.w8,
                    Container(
                      width: 54,
                      height: 26,
                      child: xBtn$2('复制',
                          Tuple2(AppPalette.txtWhite, AppPalette.txtPrimary)),
                    ),
                  ],
                ),
                Spacing.h10,
                XFutureBuilder(
                  key: _key,
                  futureBuilder: () => Api.User.isLike(data['uid']),
                  onData: (data) {
                    final action1 = {
                      '私聊': Color(0xFF36ADFE),
                      '@ta': Color(0xFFFFBD2F),
                      '送礼': Color(0xFFFE6790),
                      // data == false ? '关注' : '已关注': Color(0xFF7C66FF),
                      '转赠': Color(0xFFF99FFF),
                    };
                    return Row(
                      children: action1.entries //
                          .map<Widget>((it) => Expanded(
                              child: xBtn$2(
                                  it.key, Tuple2(it.value, Colors.white))))
                          .separator(Spacing.w6),
                    );
                  },
                ),
                Spacing.h10,
                Row(
                  children: action2
                      .map<Widget>(
                        (it) => xBtn$2(
                          it,
                          Tuple2(Color(0xFFFBFBFB), AppPalette.hint),
                          padding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                      )
                      .separator(Spacing.w6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget xBtn$2(String title, Tuple2<Color, Color> color,
      {EdgeInsetsGeometry padding}) {
    return Material(
      color: color.item1,
      borderRadius: BorderRadius.circular(4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onItemClick(title),
        child: Container(
          height: 32,
          alignment: Alignment.center,
          padding: padding,
          child: Text(
            title,
            style: TextStyle(fontSize: 12, color: color.item2),
          ),
        ),
      ),
    );
  }

  void onItemClick(String item) {
    final uid = data['uid'];

    switch (item) {
      case '复制':
        CommonUtils.copyToClipboard(data['erbanNo']);
        break;
      case '私聊':
        ChatPage.to(data['nick'], data['avatar'], uid);
        break;
      case '@ta':
        Get.back();

        Bus.send(
            roomID == null ? CMD.at_user_chat : CMD.at_user_room, data['nick']);
        break;
      case '送礼':
        if (roomID == null) {
          GiftBottomSheet.to(GiftSend2UserCtrl(data));
        } else {
          GiftBottomSheet.to(
            GiftSend2RoomCtrl(
              RoomCtrl.obj.roomUid,
              RxSet({uid}),
              [GiftSend2RoomEntity(uid: uid, avatar: data['avatar'])],
            ),
          );
        }
        break;
      case '关注':
        simpleSub(Api.User.like(uid, true),
            msg: '已关注', callback: _key.currentState.doRefresh);
        break;
      case '已关注':
        simpleSub(Api.User.like(uid, false),
            msg: '取消关注', callback: _key.currentState.doRefresh);
        break;
      case '逛逛ta的主页':
        Get.to(UserPage(uid: uid), preventDuplicates: false);

        break;
      case '举报':
        Get.back();

        reportUser(uid, false);
        break;
      case '踢出房间':
        simpleSub(
          () async {
            await Api.Room.kickMember(canManage.myUid, roomID, data['uid']);
            await WsApi.tips('[${data['nick']}]已被踢出本房间');
          },
          callback: Get.back,
        );

        break;
      case '加入黑名单':
        simpleSub(
          () => Api.Room.setRoomBlack(roomID, data['uid'], true),
          callback: Get.back,
        );

        break;
      case '转赠':
        Get.to(ChatRedEnvelopePage(data['uid']));
        break;
    }
  }
}

class _CanManage {
  final int myUid;

  _CanManage(this.myUid);
}
