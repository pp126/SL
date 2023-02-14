import 'package:app/common/theme.dart';
import 'package:app/nim/nim_help.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/common/report_mixin.dart';
import 'package:app/ui/message/chat/chat_ctrl.dart';
import 'package:app/ui/message/chat/chat_msg_send_view.dart';
import 'package:app/ui/message/chat/chat_tips_view.dart';
import 'package:app/ui/message/chat/msg_view.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ChatPage extends GetWidget<ChatCtrl> with ReportMixin {
  ChatPage._();

  /// 单个用户传用户ID，群传群ID
  static to(String title, String avatar, dynamic imUid) {
    final uid = int.parse('$imUid');

    return Get.to(
      ChatPage._(),
      preventDuplicates: false, //TODO BottomSheet跳转页面不会刷新路由
      binding: BindingsBuilder(() {
        final authCtrl = OAuthCtrl.obj;

        Get.put(avatar, tag: 'avatar#$imUid');
        Get.put<String>(authCtrl.info['avatar'], tag: 'avatar#${authCtrl.uid}');

        Get.put(ChatCtrl(title, avatar, uid));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final action = '举报'.toTxtActionBtn2(
      onPressed: () => reportUser(controller.imUid, false),
    );

    return Scaffold(
      backgroundColor: AppPalette.divider,
      appBar: xAppBar(controller.title, bgColor: Colors.white, action: action),
      body: $Body(),
      bottomNavigationBar: $BNB(),
    );
  }

  Widget $Body() {
    Widget child = _MsgListView();

    final tips = OAuthCtrl.obj.isMale //
        ? '完成与异性互动3句的任务，可免费与异性语音通话'
        : '异性与你互动10句后，每次收获5珍珠收益哟～';

    if (Storage.read(PrefKey.chatTips(tips)) != true) {
      child = Column(
        children: [
          ObxValue<RxBool>(
            (it) => it.value ? ChatTipsView(it, tips) : SizedBox.shrink(),
            true.obs,
          ),
          Expanded(child: child),
        ],
      );
    }

    return child;
  }

  Widget $BNB() => Obx(
        () {
          Widget child = MsgSendView();

          if (!controller.inputRx.value) {
            child = GestureDetector(
              child: Container(
                color: AppPalette.transparent,
                child: IgnorePointer(child: child),
              ),
              onTap: () async {
                final tips = '账号海星余额不足';

                Get.rechargeDialog(tips);
              },
            );
          }

          return child;
        },
      );
}

class _MsgListView extends StatefulWidget {
  @override
  _MsgListViewState createState() => _MsgListViewState();
}

class _MsgListViewState extends State<_MsgListView> with SingleTickerProviderStateMixin, AutoScrollStateMixin {
  final maxMsgWidth = Get.width * 213 / 375;

  @override
  void initState() {
    super.initState();

    NimHelp.loadMessage(-1);
  }

  @override
  Widget build(BuildContext context) {
    return NotifierView(NimHelp.messagesNotifier, (data) {
      autoScroll();

      return wrapList(
        ListView.separated(
          controller: listCtrl,
          padding: EdgeInsets.all(16),
          itemCount: data.length,
          itemBuilder: (_, i) => itemBuilder(data[i]),
          separatorBuilder: (_, __) => Spacing.h8,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        ),
      );
    });
  }

  Widget itemBuilder(NIMMessage data) => MsgView.fromMsg(data).createView();
}
