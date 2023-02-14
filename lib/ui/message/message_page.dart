import 'package:app/common/theme.dart';
import 'package:app/nim/nim_help.dart';
import 'package:app/tools.dart';
import 'package:app/ui/home/search/search_button.dart';
import 'package:app/ui/message/fans_list_view.dart';
import 'package:app/ui/message/follow_list_view.dart';
import 'package:app/ui/message/friend_list_view.dart';
import 'package:app/ui/message/message_list_view.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/customer/custom_indicator.dart';
import 'package:flutter/material.dart' hide kToolbarHeight;
import 'package:tuple/tuple.dart';
import 'package:visibility_detector/visibility_detector.dart';

class MessagePage extends StatefulWidget {
  final RxBool callShowRx;

  MessagePage(this.callShowRx);

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final tabs = {
    '消息': MessageListView(),
    '好友': FriendListView(),
    '关注': FollowListView(showFans: true),
    '粉丝': FansListView(showLike: true),
  };

  final _gk = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _gk,
      child: $Body(),
      onVisibilityChanged: (it) {
        widget.callShowRx.value = it.visibleFraction >= 1;
      },
    );
  }

  Widget $Body() {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: xAppBar(
          xAppBar$TabBar(
            tabs.keys.map((it) => Tab(text: it)).toList(growable: false),
            alignment: Alignment.bottomLeft,
            labelColor: AppPalette.dark,
            labelStyle: Tuple2(TextStyle(fontWeight: fw$SemiBold, fontSize: 18), TextStyle(fontSize: 18)),
            indicator: APPTabIndicator(),
          ),
          action: ['chat/清理'.toSvgActionBtn(onPressed: NimHelp.markAllMessageRead), SearchButton()],
        ),
        body: Material(
          color: Colors.white,
          child: TabBarView(
            children: tabs.values.map((it) => DelayView(it)).toList(growable: false),
          ),
        ),
      ),
    );
  }
}
