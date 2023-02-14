import 'package:app/common/theme.dart';
import 'package:app/tools.dart';
import 'package:app/tools/view.dart';
import 'package:app/ui/common/tag_icon.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/mine/page/user_page.dart';
import 'package:app/ui/room/room_page.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/level_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

titleSearch(controller, {String tips}) {
  return Align(
    alignment: Alignment.bottomCenter,
    child: Container(
      height: $ToolbarHeight,
      alignment: Alignment.center,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 60),
        height: 32,
        decoration: ShapeDecoration(shape: StadiumBorder(), color: Color(0xFFF3F2F8)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            maxLines: 1,
            controller: controller,
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
            style: TextStyle(color: AppPalette.dark, fontSize: 14, height: 1),
            decoration: InputDecoration(
              hintText: tips ?? '输入想要搜索的ID、昵称、房间号',
              hintStyle: TextStyle(color: AppPalette.hint, fontSize: 14),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    ),
  );
}

roomItem(dynamic data) {
  return InkWell(
    onTap: () => RoomPage.to(data['uid']),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          AvatarView(
            size: 62,
            url: data['avatar'],
          ),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                TagIcon(tag: data['tagPict']),
                SizedBox(width: 5),
                Text(data['title'] ?? '', style: TextStyle(color: AppPalette.dark, fontSize: 14))
              ]),
              SizedBox(height: 11),
              Row(children: [
                Text(
                  'ID:${data['roomId']}',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ).toTagView(16, Colors.black.withAlpha(20), radius: 2),
                if (data['operatorStatus'] == 2)
                  Text(
                    '休息中...',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ).toTagView(16, Colors.black.withAlpha(20), radius: 2)
              ])
            ],
          )
        ],
      ),
    ),
  );
}

userItem(dynamic data) {
  return InkWell(
    onTap: () {
      int uid = xMapStr(data, 'uid', defaultStr: null);
      int operatorStatus = xMapStr(data, 'operatorStatus', defaultStr: null);
      int roomId = xMapStr(data, 'roomId', defaultStr: null);
      if (operatorStatus != null && roomId != null) {
        RoomPage.to(roomId);
      } else if (uid != null) {
        Get.to(UserPage(uid: uid));
      }
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(children: [
        InkWell(
            onTap: () => Get.to(UserPage(
                  uid: xMapStr(data, 'uid', defaultStr: null),
                )),
            child: AvatarView(size: 62, url: data['avatar'])),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(xMapStr(data, 'nick', defaultStr: ''), style: TextStyle(color: AppPalette.dark, fontSize: 14)),
            SizedBox(height: 10),
            Row(
              children: [
                SvgPicture.asset(SVG.$('mine/性别_${data['gender']}')),
                SizedBox(width: 6),
                Container(
                    alignment: Alignment.center,
                    height: 15,
                    width: 15,
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xffFFCB2F), Color(0xffFF982F)]),
                        borderRadius: BorderRadius.all(Radius.circular(100))),
                    child: Text('${xMapStr(data, 'level', defaultStr: 0)}',
                        style: TextStyle(color: Colors.white, fontSize: 6))),
                SizedBox(width: 6),
                CharmIcon(data: data),
                SizedBox(width: 6),
                WealthIcon(data: data),
              ],
            )
          ],
        ),
      ]),
    ),
  );
}
