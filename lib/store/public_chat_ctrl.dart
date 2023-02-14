import 'dart:async';
import 'dart:convert';

import 'package:app/net/api.dart';
import 'package:app/net/ws_event.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/tools/timer_mixin.dart';
import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class PublicChatCtrl extends GetxController with BusDisposableMixin, TimerDisposableMixin {
  final data = RxList<Map>();

  final linkedCtrl = LinkedScrollControllerGroup();
  final delegate = SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 14,
    crossAxisSpacing: 10,
  );

  @override
  void onInit() {
    super.onInit();
    //<editor-fold desc="Timer">
    final duration = 1.seconds;
    final maxOffset = 1 << 31;

    addTimer(
      Timer.periodic(duration, (_) {
        try {
          var offset = linkedCtrl.offset + 60;

          if (offset > maxOffset) {
            offset = 60;

            linkedCtrl.resetScroll();
          }

          linkedCtrl.animateTo(offset, duration: duration, curve: Curves.linear);
        } catch (e) {
          //ignore
        }
      }),
    );
    //</editor-fold>

    //<editor-fold desc="消息处理">
    final myUid = OAuthCtrl.obj.uid;

    void addData(Map data) {
      final member = Map.fromIterable(
        ['uid', 'nick', 'avatar', 'wealthLevel', 'charmLevel'],
        value: (k) => data[k],
      );

      this.data.add({
        'member': member,
        'isOut': myUid == member['uid'],
        'data': {
          'type': 0,
          'content': data['content'],
        },
      });
    }

    on<PublicChatEvent>((event) => addData(event.data));

    Api.Home.pubChatHistory() //
        .then((it) => it.reversed.forEach((it) => addData(jsonDecode(it))));
    //</editor-fold>
  }
}
