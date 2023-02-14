import 'dart:ui';

import 'package:app/common/bus_key.dart';
import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/ui/common/svga_icon.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/room/create_room_page.dart';
import 'package:app/ui/room/setting_room_page.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/num_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocietyRoomManagementPage extends StatefulWidget {
  Map data;

  SocietyRoomManagementPage(this.data);

  @override
  _SocietyRoomManagementPageState createState() => _SocietyRoomManagementPageState();
}

class _SocietyRoomManagementPageState extends State<SocietyRoomManagementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: xAppBar('房间管理',
            action: 'mine/society/更多'.toSvgActionBtn(onPressed: () {
              Get.to(CreateRoomPage(widget.data['familyId']))
                  .then((value) => Bus.send(BUS_SOCIETY_ROOM_MANAGEMENT_REFRESH));
            })),
        body: SocietyRoomList(widget.data));
  }
}

class SocietyRoomList extends StatefulWidget {
  Map data;

  SocietyRoomList(this.data);

  @override
  _SocietyRoomListState createState() => _SocietyRoomListState();
}

class _SocietyRoomListState extends NetPageList<Map, SocietyRoomList> {
  @override
  void initState() {
    super.initState();
    Bus.sub(BUS_SOCIETY_ROOM_MANAGEMENT_REFRESH, (data) {
      doRefresh();
    });
  }

  @override
  void dispose() {
    Bus.fire(BUS_SOCIETY_ROOM_MANAGEMENT_REFRESH);
    super.dispose();
  }

  @override
  Future fetchPage(PageNum page) {
    return Api.Family.getRoomInfo(familyId: widget.data['familyId'], pageNum: page.index, pageSize: page.size);
  }

  @override
  Widget itemBuilder(BuildContext context, Map item, int index) {
    return Container(
        height: 85,
        padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          RectAvatarView(size: 50,url: item['avatar'],),
          SizedBox(width: 10),
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  SvgPicture.asset(SVG.$('home/${item['roomTag']}')),
                  SizedBox(width: 5),
                  Text(item['title'], style: TextStyle(color: AppPalette.dark, fontSize: 14)),
                ]),
                SizedBox(height: 11),
                Row(children: [
                  Container(
                      height: 16,
                      decoration: new BoxDecoration(
                        color: Colors.black.withAlpha(20),
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                      ),
                      child: Row(children: [
                        SizedBox(
                            height: 14,
                            child: AspectRatio(
                                aspectRatio: 160 / 100, child: SVGAIcon(icon: 'wave'))),
                        NumView(num: item['onlineNum'], prefix: 'num/yellow/', height: 11)
                      ])),
                  SizedBox(width: 6),
                  Text('ID:${item['roomId']}', style: TextStyle(color: Colors.white, fontSize: 10))
                      .toTagView(16, Colors.black.withAlpha(20), radius: 2)
                ])
              ]),
              Spacer(),
              Text(
                '删除',
                style: TextStyle(color: AppPalette.pink, fontSize: 10),
              ).toBtn(24, Color(0xffFFECEF), width: 50, onTap: () {
                simpleSub(
                    Api.Room.delFamilyRoom(
                        roomId: item['roomId'].toString(), familyId: widget.data['familyId'].toString()),
                    msg: '删除成功', callback: () {
                  doRefresh();
                });
              }),
              SizedBox(width: 10),
              Text(
                '编辑',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ).toBtn(24, AppPalette.primary, width: 50, onTap: () {
                Get.to(SettingRoomPage(RxMap(item))).then((value) => doRefresh());
              })
            ]),
            Spacer(),
            Divider(height: 1, color: AppPalette.divider)
          ]))
        ]));
  }
}
