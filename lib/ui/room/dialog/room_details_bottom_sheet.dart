import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/net/host.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/store/room_ctrl.dart';
import 'package:app/store/room_like_ctrl.dart';
import 'package:app/store/wallet_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/common/report_mixin.dart';
import 'package:app/ui/common/tag_icon.dart';
import 'package:app/ui/common/uid_box.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/mine/page/user_page.dart';
import 'package:app/ui/mine/society/society_page.dart';
import 'package:app/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share/share.dart';

class RoomDetailsBottomSheet extends GetWidget<WalletCtrl> with ReportMixin {
  RoomDetailsBottomSheet();

  Future<Map> getData() {
    return Api.Room.getRoomAndFamilyInfo(RoomCtrl.obj.roomID);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 430,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 20, left: 20, bottom: 15),
            child: Text('房间详情', style: TextStyle(fontSize: 16, color: AppPalette.txtWhite, fontWeight: fw$SemiBold)),
          ),
          XFutureBuilder<Map>(
              futureBuilder: getData,
              onData: (data) {
                return Column(
                  children: [
                    _getRoomInfo(data),
                    _getRoomDetails(data),
                    _getRoomNotice(data),
                    _getRoomBtn(data),
                  ],
                );
              }),
        ],
      ),
    );
  }

  _getRoomInfo(Map data) {
    return Row(children: [
      Padding(
        padding: const EdgeInsets.only(left: 16, right: 8),
        child: AvatarView(
          url: data['roomAvatar'],
          size: 62,
          side: BorderSide(width: 2, color: AppPalette.txtWhite),
        ),
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                TagIcon(tag: data['tagPict'] ?? data['roomTag']),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      data['title'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            Spacing.h4,
            Row(
              children: [
                Text('房间ID:${data['roomId']}', style: TextStyle(fontSize: 10, color: Colors.white))
                    .toWarp(color: Color(0x33FFFFFF), padding: EdgeInsets.symmetric(vertical: 1, horizontal: 8)),
              ],
            ),
          ],
        ),
      )
    ]);
  }

  _getRoomDetails(Map data) {
    var getDetail = (String label, String img, String name, int id, var onTap) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Color(0xffFAF9FE), fontSize: 14),
            ),
            Spacing.h10,
            Row(
              children: [
                InkWell(onTap: onTap, child: RectAvatarView(url: img, size: 48, radius: 12)),
                Spacing.w10,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(color: Color(0xffFAF9FE), fontSize: 12),
                    ),
                    UidBox(data: {'userNo': id}, hasBG: false, color: AppPalette.tips),
                  ],
                )
              ],
            )
          ],
        ),
      );
    };

    int familyId = xMapStr(data, 'familyId', defaultStr: -1);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 23),
      child: Row(
        children: [
          getDetail(
              '房主',
              xMapStr(data, 'avatar', defaultStr: ''),
              xMapStr(data, 'nick', defaultStr: ''),
              xMapStr(data, 'erbanNo', defaultStr: 0),
              () => Get.to(UserPage(uid: xMapStr(data, 'uid', defaultStr: null)))),
          familyId != -1
              ? getDetail(
                  '所属公会',
                  xMapStr(data, 'familyAvatar', defaultStr: ''),
                  xMapStr(data, 'familyName', defaultStr: ''),
                  familyId,
                  () => simpleSub(
                        () async {
                          final value = await Api.Family.getFamilyInfo(familyId: familyId);
                          Get.back();
                          Get.to(SocietyPage(value));
                        },
                        msg: null,
                      ))
              : Spacing.exp,
        ],
      ),
    );
  }

  _getRoomNotice(Map data) {
    return AspectRatio(
        aspectRatio: 343 / 100,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            child: Text(
              xMapStr(data, 'roomNotice', defaultStr: ''),
              style: TextStyle(color: Color(0xffF8F7FC), fontSize: 14),
            ),
          ),
        )).toTagView(
      100,
      Color(0xff191535),
      radius: 12,
      margin: EdgeInsets.symmetric(horizontal: 16),
    );
  }

  _getRoomBtn(Map data) {
    var btn = (
      String img,
      String text,
      var onTop, {
      Color textColor,
      Color bgColor,
    }) {
      return Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(SVG.$('room/$img'), width: 15, height: 15),
            Spacing.w4,
            Text(
              text,
              style: TextStyle(color: textColor ?? Color(0xff9A93C2), fontSize: 14),
            )
          ],
        ).toBtn(50, bgColor ?? Color(0xff363059), radius: 12, onTap: onTop),
      );
    };
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          if (Get.isRegistered<RoomLikeCtrl>()) ...[
            btn('举报房间', '举报房间', () {
              reportUser(xMapStr(data, 'erbanNo', defaultStr: 0), true);
            }),
            GetBuilder<RoomLikeCtrl>(builder: (it) {
              return btn(it.isLike ? '收藏房间' : '已收藏', it.isLike ? '已收藏' : '收藏房间', () {
                it.like(!it.isLike);
              }, textColor: it.isLike ? Colors.white : null, bgColor: it.isLike ? Color(0xff7C66FF) : null);
            }),
          ],
          btn('分享房间', '分享房间', () {
            final uri = Uri.http(
              host.host.replaceFirst('api.', ''),
              'share/invitationRoom.html',
              {'roomId': '${RoomCtrl.obj.roomID}'},
            );

            Share.share('${OAuthCtrl.obj.info['nick']}带你走进Ta的直播间，访问 $uri 查看详情', subject: '房间分享');
          }),
        ].separator(SizedBox(width: 10)),
      ),
    );
  }
}
