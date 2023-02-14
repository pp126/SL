import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/net/file_api.dart';
import 'package:app/net/host.dart';
import 'package:app/tools.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/room/room_bg_page.dart';
import 'package:app/ui/room/room_tag_page.dart';
import 'package:app/ui/web/web_page.dart';
import 'package:app/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CreateRoomPage extends StatefulWidget {
  final int familyID;

  CreateRoomPage([this.familyID]);

  @override
  _CreateRoomPageState createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  final _ctrl = TextEditingController();
  final _tagNotifier = ValueNotifier<Map>(null);
  final _bgNotifier = ValueNotifier<String>(null);
  final _avatarNotifier = ValueNotifier<String>(null);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeDark,
      child: Scaffold(
        appBar: xAppBar('创建房间'),
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 36),
          child: $Body(),
        ),
      ),
    );
  }

  Widget $Body() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        $UserView(),
        Spacing.h16,
        $Title('选择房间标签'),
        Spacing.h16,
        RoomTagView(_tagNotifier),
        Spacing.h8 * 5,
        $Title('添加房间背景'),
        Spacing.h16,
        $SelectImg(),
        Spacing.exp,
        Center(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '创建房间即表示同意本平台'),
                TextSpan(
                    text: '直播协议',
                    style: TextStyle(color: AppPalette.primary),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Get.to(AppWebPage(
                            title: '直播协议',
                            url: 'http://${host.host}/agreement/broadcast.html',
                          ))),
              ],
            ),
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
        ),
        Spacing.h16,
        Center(
          child: Material(
            color: Color(0xFF353050),
            clipBehavior: Clip.antiAlias,
            shape: StadiumBorder(),
            child: InkWell(
              onTap: doSub,
              child: Container(
                width: 270,
                height: 40,
                alignment: Alignment.center,
                child: Text(
                  '开启你的有声直播',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Text $Title(String title) => Text(title, style: TextStyle(fontSize: 16, color: AppPalette.hint));

  Widget $UserView() {
    return Row(
      children: [
        NotifierView(
          _avatarNotifier,
          (it) {
            return InkResponse(
              child: AvatarView(url: it),
              onTap: () {
                imagePicker(
                  (file) {
                    simpleSub(
                      () async => _avatarNotifier.value = await FileApi.upLoadFile(file, 'cover/'),
                      msg: null,
                    );
                  },
                  max: 512,
                );
              },
            );
          },
        ),
        Spacing.w16,
        Column(
          children: [
            Container(
              width: 130,
              height: 50,
              child: TextField(
                controller: _ctrl,
                style: TextStyle(fontSize: 14, color: Colors.white),
                decoration: InputDecoration(
                  hintText: '请输入房间标题',
                  hintStyle: TextStyle(fontSize: 14, color: AppPalette.tips),
                  border: OutlineInputBorder(
                    gapPadding: 0,
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  fillColor: Color(0xFF1E1A39),
                  filled: true,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget $SelectImg() {
    return Material(
      color: Color(0xFF1E1A39),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: InkWell(
        child: NotifierView(_bgNotifier, (data) {
          return data != null //
              ? NetImage(data, width: 90, height: 90, fit: BoxFit.cover)
              : Container(
                  width: 90,
                  height: 90,
                  alignment: Alignment.center,
                  child: Icon(Icons.add, color: AppPalette.primary, size: 32),
                );
        }),
        onTap: () async {
          final result = await Get.to(RoomBGPage());

          if (result is Map) {
            _bgNotifier.value = result['picUrl'];
          }
        },
      ),
    );
  }

  doSub() {
    final String title = _ctrl.text;
    if (title.isNullOrBlank) {
      showToast('请输入房间标题');

      return;
    }

    final avatar = _avatarNotifier.value;
    if (avatar == null) {
      showToast('请选择房间封面');

      return;
    }

    final tag = _tagNotifier.value;
    if (tag == null) {
      showToast('请选择房间标签');

      return;
    }

    final bg = _bgNotifier.value;
    if (bg == null) {
      showToast('请选择房间背景');

      return;
    }

    simpleSub(Api.Room.createRoom(widget.familyID, title, avatar, tag['id'], bg), callback: Get.back);
  }
}
