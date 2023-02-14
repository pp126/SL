import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/store/room_ctrl.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/room/room_mic_view.dart';
import 'package:app/ui/room/user_bottom_sheet.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RoomUserView extends StatefulWidget {
  @override
  _RoomUserViewState createState() => _RoomUserViewState();
}

class _RoomUserViewState extends NetPageList<Map, RoomUserView> {
  final Set<int> micData = RoomMicCtrl.obj.micMap.values.map((e) => e?.user?.uid).toSet();

  @override
  Future fetchPage(PageNum page) {
    final roomID = RoomCtrl.obj.roomID;

    return Api.Room.members(roomID, page);
  }

  @override
  BaseConfig initListConfig() {
    return ListConfig(
      divider: Divider(color: Color(0xFF3B3367), indent: 76, endIndent: 16),
    );
  }

  @override
  Widget itemBuilder(BuildContext context, Map item, int index) {
    final tags = [
      if (item['is_creator'] == true || RoomCtrl.obj.isOwner(item['account'])) '房主',
      if (item['is_manager'] == true) '管理员',
      micData.contains(item['account']) ? '上麦' : '听众',
    ].map((it) {
      List<Color> colors;

      switch (it) {
        case '房主':
        case '管理员':
          colors = [Color(0xFFA882FF), Color(0xFF645BFF)];
          break;
        case '上麦':
          colors = [Color(0xFFFFCBA5), AppPalette.pink];
          break;
        case '听众':
          colors = [Color(0xFF4D2E60), Color(0xFF352E5B)];
          break;
      }

      return $Tag(it, colors);
    }).toList(growable: false);

    return InkWell(
      child: Container(
        height: 80,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            AvatarView(
              url: item['avatar'],
              size: 48,
              side: BorderSide(width: 2, color: AppPalette.txtWhite),
            ),
            Spacing.w8,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item['nick'], style: TextStyle(fontSize: 14, color: Colors.white)),
                  Spacing.h6,
                  Wrap(spacing: 4, runSpacing: 4, children: tags),
                ],
              ),
            )
          ],
        ),
      ),
      onTap: () {
        Get.back();

        UserBottomSheet.to(item['account']);
      },
    );
  }

  Widget $Tag(String title, List<Color> colors) {
    return Container(
      width: 40,
      height: 20,
      decoration: ShapeDecoration(
        shape: StadiumBorder(),
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: TextStyle(fontSize: 10, color: Colors.white),
      ),
    );
  }
}
