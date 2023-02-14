import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/store/room_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/level_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RoomManagerPage extends _StatefulWidget {
  RoomManagerPage(int roomID) : super('管理员', roomID);

  @override
  _State createState() => _State();

  @override
  Future fetchPage(PageNum page) => Api.Room.roomManagers(roomID, page);

  @override
  Future onItemDel(Map item) => Api.Room.setRoomAdmin(RoomCtrl.obj.roomUid, roomID, item['account'], false);
}

class RoomBlockUserPage extends _StatefulWidget {
  RoomBlockUserPage(int roomID) : super('黑名单', roomID);

  @override
  _State createState() => _State();

  @override
  Future fetchPage(PageNum page) => Api.Room.roomBlackList(roomID, page);

  @override
  Future onItemDel(Map item) => Api.Room.setRoomBlack(roomID, item['account'], false);
}

abstract class _StatefulWidget extends StatefulWidget {
  final int roomID;
  final String title;

  _StatefulWidget(this.title, this.roomID);

  Future fetchPage(PageNum page);

  Future onItemDel(Map item);
}

class _State extends NetPageList<Map, _StatefulWidget> {
  @override
  Future fetchPage(PageNum page) => widget.fetchPage(page);

  @override
  BaseConfig initListConfig() {
    return ListConfig(
      divider: Divider(indent: 76, endIndent: 16),
    );
  }

  @override
  Widget itemBuilder(BuildContext context, Map item, int index) => _ItemView(item, onItemDel);

  @override
  Widget build(BuildContext context) => Scaffold(appBar: xAppBar(widget.title), body: super.build(context));

  void onItemDel(Map data) {
    simpleSub(
      widget.onItemDel(data),
      callback: () {
        setState(() {
          listData.remove(data);
        });
      },
    );
  }
}

class _ItemView extends StatelessWidget {
  final Map data;
  final void Function(Map) onItemDel;

  _ItemView(this.data, this.onItemDel);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          AvatarView(
            url: data['avatar'],
            size: 48,
            side: BorderSide(width: 2, color: AppPalette.txtWhite),
          ),
          Spacing.w8,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data['nick'],
                  style: TextStyle(fontSize: 14, color: AppPalette.txtDark),
                ),
                Spacing.h4,
                Row(
                  children: [
                    SvgPicture.asset(SVG.$('mine/性别_${data['gender']}')),
                    WealthIcon(data: data),
                    CharmIcon(data: data, height: 16),
                  ].separator(Spacing.w4),
                ),
              ],
            ),
          ),
          if (RoomCtrl.obj.isOwner()) //房主才能修改管理员
            IconButton(
              icon: Icon(Icons.delete, color: AppPalette.tips),
              onPressed: () => onItemDel(data),
            ),
        ],
      ),
    );
  }
}
