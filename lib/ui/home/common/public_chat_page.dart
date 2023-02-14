import 'dart:convert';

import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/store/public_chat_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/room/user_bottom_sheet.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/level_view.dart';
import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';

class PublicChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar('聊天广场'),
      body: _MsgListView(),
      bottomNavigationBar: SafeArea(child: MsgSendView()),
    );
  }
}

class _MsgListView extends StatefulWidget {
  @override
  _MsgListViewState createState() => _MsgListViewState();
}

class _MsgListViewState extends State<_MsgListView> with SingleTickerProviderStateMixin, AutoScrollStateMixin {
  final maxMsgWidth = Get.width * 213 / 375;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(IMG.$('公聊背景')),
          alignment: Alignment.topCenter,
          fit: BoxFit.fitWidth,
          scale: 2,
        ),
      ),
      child: GetX<PublicChatCtrl>(builder: (it) {
        final data = it.data;

        autoScroll();

        return wrapList(
          ListView.separated(
            controller: listCtrl,
            padding: EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (_, i) => itemBuilder(data[i]),
            separatorBuilder: (_, __) => Spacing.h12,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          ),
        );
      }),
    );
  }

  Widget itemBuilder(Map data) {
    return data['isOut'] == true //
        ? outView(data['member'], data['data']['content'])
        : inView(data['member'], data['data']['content']);
  }

  Widget outView(Map member, String content) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                CharmIcon(data: member),
                WealthIcon(data: member),
                Spacing.w4,
                Text(
                  '我',
                  style: TextStyle(fontSize: 12, color: AppPalette.txtDark),
                ),
              ],
            ),
            $AppBubble(
              child: $TxtMsg(content),
              nip: BubbleNip.rightTop,
              color: AppPalette.txtWhite,
            ),
          ],
        ),
        Spacing.w10,
        AvatarView(url: member['avatar'], size: 44),
      ],
    );
  }

  Widget inView(Map member, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          child: AvatarView(url: member['avatar'], size: 44),
          onTap: () => UserBottomSheet.to(member['uid'], roomMode: false),
        ),
        Spacing.w10,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  member['nick'],
                  style: TextStyle(fontSize: 12, color: AppPalette.txtDark),
                ),
                Spacing.w4,
                WealthIcon(data: member),
                CharmIcon(data: member),
              ],
            ),
            $AppBubble(
              child: $TxtMsg(content),
              nip: BubbleNip.leftTop,
              color: Colors.white,
            ),
          ],
        ),
      ],
    );
  }

  Widget $TxtMsg(String content) {
    String decodeStr = content;
    try {
      decodeStr = utf8.decode(base64Decode(content));
    } catch (e) {
      //todo base64 decode error
    }
    return Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        decodeStr,
        style: TextStyle(fontSize: 14, color: AppPalette.txtDark),
      ),
    );
  }
}

class MsgSendView extends StatefulWidget {
  @override
  _MsgSendViewState createState() => _MsgSendViewState();
}

class _MsgSendViewState extends State<MsgSendView> with BusStateMixin {
  final ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    bus(CMD.at_user_chat, (atNick) => ctrl.text += ' @$atNick ');
  }

  @override
  Widget build(BuildContext context) {
    final _bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: _bottom),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                decoration: ShapeDecoration(
                  color: Color(0xFFF1F0F7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(4), left: Radius.circular(20)),
                  ),
                ),
                alignment: Alignment.centerLeft,
                child: TextField(
                  controller: ctrl,
                  style: TextStyle(fontSize: 14, color: AppPalette.dark),
                  decoration: InputDecoration(
                    hintText: '说点什么吧。',
                    hintStyle: TextStyle(fontSize: 14, color: AppPalette.hint),
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              ),
            ),
            Spacing.w6,
            Material(
              color: AppPalette.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.horizontal(left: Radius.circular(4), right: Radius.circular(20)),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                child: Container(
                  width: 72,
                  height: 40,
                  alignment: Alignment.center,
                  child: Text(
                    '发送',
                    style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: fw$SemiBold),
                  ),
                ),
                onTap: doSend,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void doSend() {
    final String text = ctrl.text;

    if (text.isNullOrBlank) return;

    Api.Home.sendPublicChat(text);

    ctrl.clear();
  }
}
