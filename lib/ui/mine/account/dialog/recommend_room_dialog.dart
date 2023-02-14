import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/room/room_page.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/future_builder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RecommendRoomDialog extends StatelessWidget {
  RecommendRoomDialog._();

  static Future<bool> to() => Get.dialog(RecommendRoomDialog._(), barrierDismissible: false);

  final _gk = GlobalKey<XFutureBuilderState>();

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.fitWidth,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            Container(
              width: 303,
              height: 384,
              margin: EdgeInsets.symmetric(horizontal: 36),
              child: Material(
                color: Colors.white,
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 132,
                      child: Image.asset(IMG.$('推荐主播背景'), fit: BoxFit.fill, scale: 2),
                    ),
                    Positioned.fill(
                      top: 73,
                      child: XFutureBuilder(
                        key: _gk,
                        futureBuilder: () => Api.Room.getHomeRecommendRoom(),
                        onData: (data) => $DataView(data),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Spacing.h16,
            CloseButton(color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget $DataView(data) {
    return Column(
      children: [
        RectAvatarView(url: data['avatar'], size: 98),
        Container(
          height: 42,
          alignment: Alignment.bottomCenter,
          child: Text(
            data['title'],
            style: TextStyle(fontSize: 16, color: AppPalette.txtDark),
          ),
        ),
        Spacing.h8,
        Text(
          '邀请你加入房间一起聊天',
          style: TextStyle(fontSize: 14, color: AppPalette.primary),
        ),
        Spacing.h16,
        Material(
          shape: StadiumBorder(),
          color: AppPalette.primary,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            child: Container(
              width: 155,
              height: 50,
              alignment: Alignment.center,
              child: Text(
                '进入房间',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            onTap: () {
              Get.back(result: false);

              RoomPage.to(data['uid']);
            },
          ),
        ),
        Expanded(
          child: Center(
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                child: Container(
                  width: 72,
                  height: 44,
                  alignment: Alignment.center,
                  child: Text(
                    '换一个',
                    style: TextStyle(fontSize: 14, color: AppPalette.tips),
                  ),
                ),
                onTap: () => _gk.currentState.doRefresh(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
