import 'dart:io';

import 'package:app/nim/nim_help.dart';
import 'package:app/store/call_overlay_ctrl.dart';
import 'package:app/store/gift_ctrl.dart';
import 'package:app/store/mq_ctrl.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/store/online_ctrl.dart';
import 'package:app/store/public_chat_ctrl.dart';
import 'package:app/store/rd_avatar_ctrl.dart';
import 'package:app/store/room_sticker_ctrl.dart';
import 'package:app/store/society_ctrl.dart';
import 'package:app/store/wallet_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/home/rank/rank_page.dart';
import 'package:app/ui/main/nav_view.dart';
import 'package:app/ui/main/uni_link_state_mixin.dart';
import 'package:app/ui/message/message_page.dart';
import 'package:app/ui/mine/account/dialog/recommend_call_dialog.dart';
import 'package:app/ui/mine/account/load_set_page.dart';
import 'package:app/ui/mine/mine_page.dart';
import 'package:app/ui/mine/task/my_sign_item.dart';
import 'package:app/ui/moment/moment_page.dart';
import 'package:app/ui/room/room_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';

import '../../widgets.dart';
import '../home/home_page.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with BusStateMixin, GetStateMixin, UniLinkStateMixin {
  final _pageKey = GlobalKey<SlidePageState>();

  final selector = RxInt(0);
  final callShowRx = RxBool(false);
  final pages = <Widget>[], navs = <NavBarItem>[];

  @override
  void initState() {
    super.initState();
    _initPages();

    bindGet(OnlineCtrl());
    bindGet(WalletCtrl());
    bindGet(GiftCtrl());
    bindGet(SocietyCtrl());
    bindGet(MqCtrl());
    bindGet(StickerCtrl());
    bindGet(PublicChatCtrl());
    bindGet(RdAvatarCtrl());
    bindGet(CallOverlayCtrl(callShowRx));

    _doOnInit();
  }

  void _initPages() {
    ever(selector, (i) => _pageKey.currentState.go(i));

    [
      Tuple2('首页', HomePage()),
      Tuple2('动态', MomentPage()),
      // Tuple2('榜单', RankPage()),
      null,
      Tuple2('消息', MessagePage(callShowRx)),
      Tuple2('我的', MinePage()),
    ].forEach((it) {
      if (it == null) {
        navs.add(null);
      } else {
        pages.add(it.item2);

        final label = it.item1;

        if (label == '消息') {
          navs.add(NavBarItem(badge: NimHelp.unreadCount, label: label));
        } else {
          navs.add(NavBarItem(label: label));
        }
      }
    });
  }

  void _doOnInit() {
    onFrameEnd((_) async {
      doNext([int gender]) async {
        await MySignItem.show();
        if (gender != null && gender == 1) {
          //todo 隐藏挑选心动
          // await Get.dialog(RecommendCallDialog(gender), barrierDismissible: false);
        }
      }

      ///未设置男女
      if (OAuthCtrl.obj.gender.value == -1) {
        doNext(await Get.to(LoadSetPage(), popGesture: false));
      } else {
        doNext();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Scaffold(
      body: SlidePageView(key: _pageKey, pages: pages),
      bottomNavigationBar: NavBar(selector: selector, items: navs),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: AppFab(RoomPage.to),
    );

    if (Platform.isAndroid) {
      child = WillPopScope(
        child: child,
        onWillPop: () async {
          goHome();

          return false;
        },
      );
    }

    return child;
  }
}
