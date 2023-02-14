import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/net/file_api.dart';
import 'package:app/tools.dart';
import 'package:app/ui/common/input_page.dart';
import 'package:app/ui/common/tag_icon.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/room/room_bg_page.dart';
import 'package:app/ui/room/room_manager_page.dart';
import 'package:app/ui/room/room_tag_page.dart';
import 'package:app/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingRoomPage extends StatelessWidget {
  final RxMap data;

  SettingRoomPage(this.data);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: xAppBar('编辑房间资料'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16) - EdgeInsets.only(top: 16),
        child: Obx(() {
          VoidCallback onTap;

          if (data['familyId'] == null) {
            onTap = () {
              imagePicker(
                (file) {
                  simpleSub(
                    () async {
                      final url = await FileApi.upLoadFile(file, 'cover/');

                      data.addAll(await Api.Room.updateRoom(data['roomId'], info: {'avatar': url}));
                    },
                    msg: null,
                  );
                },
                max: 512,
              );
            };
          }

          return Column(
            children: [
              Container(
                height: 122,
                alignment: Alignment.center,
                child: InkResponse(
                  child: AvatarView(url: data['avatar'], size: 82),
                  onTap: onTap,
                ),
              ),
              ...actions().separator(Spacing.h10),
            ],
          );
        }),
      ),
    );
  }

  Iterable<Widget> actions() {
    return [
      _InputAction(title: '房间名称', data: data, doSub: doSub, show: 'title'),
      _TagAction(title: '房间类型', data: data, doSub: doSub, page: RoomTagPage()),
      _InputAction(title: '房间密码', data: data, doSub: doSub, show: 'roomPwd', keyboardType: TextInputType.number),
      _SelectAction(title: '房间背景', data: data, doSub: doSub, page: RoomBGPage()),
      _SelectAction(title: '房间管理员', data: data, doSub: doSub, page: RoomManagerPage(data['roomId'])),
      _SelectAction(title: '房间黑名单', data: data, doSub: doSub, page: RoomBlockUserPage(data['roomId'])),
      _Input2Action(title: '房间公告', data: data, doSub: doSub, show: 'roomNotice'),
      _Input2Action(title: '房间欢迎语', data: data, doSub: doSub, show: 'playInfo'),
    ].map((it) => $Action(it));
  }

  Widget $Action(_Action item) {
    final trailing = item.trailing;

    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: item._onTap,
        child: Container(
          height: 60,
          padding: EdgeInsets.only(left: 20, right: 10),
          child: Row(
            children: [
              Text(item.title, style: TextStyle(fontSize: 14, color: AppPalette.tips)),
              Spacing.exp,
              if (trailing != null) trailing,
              RightArrowIcon(),
            ],
          ),
        ),
      ),
    );
  }

  void doSub(String item, result) {
    Map info;

    switch (item) {
      case '房间名称':
        info = {'title': result};
        break;
      case '房间类型':
        info = {'tagId': result['id']};
        break;
      case '房间密码':
        info = {'roomPwd': result};
        break;
      case '房间背景':
        info = {'backPic': result['picUrl']};
        break;
      case '房间公告':
        info = {'roomNotice': result};
        break;
      case '房间欢迎语':
        info = {'playInfo': result};
        break;
      default:
        return;
    }

    final api = Api.Room.updateRoom(data['roomId'], info: info);

    simpleSub(
      api,
      msg: null,
      callback: () async => data.addAll(await api),
    );
  }
}

abstract class _Action<T> {
  final String title;
  final Map data;
  final Function(String, T) doSub;

  _Action(this.title, this.data, this.doSub);

  final Widget trailing = null;

  void _onTap() async {
    final f = task;

    if (f != null) {
      final result = await f;

      if (result is T) doSub(title, result);
    }
  }

  Future get task;
}

class _SelectAction extends _Action<Map> {
  final Widget page;

  _SelectAction({this.page, String title, Map data, doSub}) : super(title, data, doSub);

  @override
  Future get task => Get.to(page);
}

class _TagAction extends _SelectAction {
  _TagAction({Widget page, String title, Map data, doSub}) : super(page: page, title: title, data: data, doSub: doSub);

  @override
  Widget get trailing {
    return TagIcon(tag: data['tagPict']);
  }
}

class _InputAction extends _Action<String> {
  final String show;
  final TextInputType keyboardType;

  _InputAction({this.show, this.keyboardType, String title, Map data, doSub}) : super(title, data, doSub);

  @override
  Widget get trailing {
    return LimitedBox(
      maxWidth: 100,
      child: Text(
        data[show]?.replaceAll('\n', '') ?? '',
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 14, color: AppPalette.txtDark),
      ),
    );
  }

  @override
  Future get task => Get.showInputDialog(initial: data[show], keyboardType: keyboardType);
}

class _Input2Action extends _InputAction {
  _Input2Action({String show, String title, Map data, doSub})
      : super(show: show, title: title, data: data, doSub: doSub);

  @override
  Future get task => Get.to(InputPage(title: title, initial: data[show]));
}
