import 'dart:async';
import 'dart:ui' as ui show PlaceholderAlignment;

import 'package:app/common/theme.dart';
import 'package:app/net/ws_event.dart';
import 'package:app/tools.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/room/widgets/slide_animated_view.dart';
import 'package:app/widgets.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:marquee_text/marquee_text.dart';
import 'package:tuple/tuple.dart';

abstract class _BroadcastQueueCtrl<T extends WsEvent> extends GetxService with BusDisposableMixin {
  final _views = <Key, OverlayEntry>{};
  final _ctrl = StreamController<T>.broadcast();

  StreamQueue<T> _queue;

  @override
  void onInit() {
    super.onInit();

    on<T>((event) => _ctrl.add(event));

    _init() {
      try {
        _queue?.cancel(immediate: true);
      } catch (e) {
        errLog(e);
      }

      start(_queue = StreamQueue(_ctrl.stream));
    }

    bus(CMD.logout, (_) => _init());

    _init();
  }

  @override
  void onClose() {
    _ctrl.close();

    super.onClose();
  }

  Future doAnime({
    Widget view,
    double top,
    Tuple3<double, double, double> dock,
    Tuple3<Duration, Duration, Duration> times,
  }) {
    final key = UniqueKey();

    view = SlideAnimatedView(
      child: view,
      dock: dock,
      times: times,
      onFinish: () => _views[key].remove(),
    );

    view = IgnorePointer(child: view);

    view = Positioned(key: key, top: top, child: view);

    _views[key] = Get.insertOverlay(view);

    // 等待上一个横幅
    return Future.delayed(times.item1 + times.item2);
  }

  start(StreamQueue<T> queue);

  loop(StreamQueue<T> queue, Future<void> Function(Map) onItem) async {
    while (await queue.hasNext && !isClosed) {
      final data = (await queue.next).data;

      await onItem(data);
    }
  }

  Widget itemBuilder(Map item);

  double get offsetTop;
}

class RoomDrawBroadcastCtrl extends _BroadcastQueueCtrl<RoomDrawEvent> {
  final _dec = ShapeDecoration(
    color: Color(0xFF7C66FF),
    shape: StadiumBorder(
      side: BorderSide(color: Color(0xFFD8D2FF)),
    ),
  );

  @override
  start(StreamQueue<RoomDrawEvent> queue) {
    final dock = Tuple3(Get.width, 32.0, -Get.width);
    final times = Tuple3(Duration(seconds: 1), Duration(seconds: 2), Duration(milliseconds: 400));

    loop(queue, (data) => doAnime(view: itemBuilder(data), top: offsetTop, dock: dock, times: times));
  }

  @override
  double get offsetTop => Get.statusBarHeight / Get.pixelRatio + 44;

  @override
  Widget itemBuilder(data) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Container(
          height: 28,
          margin: EdgeInsets.only(left: 2),
          padding: EdgeInsets.only(left: 32.0 + 8, right: 8),
          alignment: Alignment.centerLeft,
          decoration: _dec,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: data['nick'],
                  style: TextStyle(color: AppPalette.txtRoomChat),
                ),
                //todo 去掉开奖房间
                // TextSpan(text: '，在'),
                // TextSpan(
                //   text: data['roomTitle'],
                //   style: TextStyle(color: AppPalette.txtGold),
                // ),
                TextSpan(text: '开出'),
                TextSpan(
                  text: data['giftName'],
                  style: TextStyle(color: Color(0xFFFFC22F)),
                ),
                WidgetSpan(
                  alignment: ui.PlaceholderAlignment.middle,
                  child: GiftImgState(
                    child: NetImage(data['giftPic'], width: 18, height: 18),
                  ),
                ),
                TextSpan(
                  text: '×${data['giftNum']}',
                  style: TextStyle(color: Color(0xFFFFC22F)),
                ),
              ],
            ),
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: fw$Regular,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        AvatarView(
          url: data['avatar'],
          size: 36,
          side: BorderSide(width: 2, color: Colors.white),
        ),
      ],
    );
  }
}

class BigGiftBroadcastCtrl extends _BroadcastQueueCtrl<BigGiftEvent> {
  @override
  start(StreamQueue<BigGiftEvent> queue) {
    final dock = Tuple3(Get.width, 0.0, -Get.width);
    final times = Tuple3(Duration(seconds: 1), Duration(milliseconds: 4600), Duration(milliseconds: 400));

    loop(queue, (data) => doAnime(view: itemBuilder(data), top: offsetTop, dock: dock, times: times));
  }

  // @override
  // void onInit() {
  //   super.onInit();
  //
  //   Timer.periodic(2.seconds, (timer) {
  //     Bus.fire(
  //       BigGiftEvent(
  //         {
  //           "giftName": "甜蜜恋情",
  //           "recvNick": "蓝魔白白白",
  //           "giftNum": 1,
  //           "giftPic": "http://img.ligaozhong.com/FsteF_gKGVv3onTRiCs1RqSjVh21?imageslim",
  //           "sendNick": "蓝天",
  //           "roomTitle": "优嘉电竞"
  //         },
  //       ),
  //     );
  //   });
  // }

  @override
  Widget itemBuilder(Map data) {
    return FittedBox(
      fit: BoxFit.fitWidth,
      child: Container(
        width: 375,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(IMG.$('大礼物背景'), width: 699 / 2, height: 264 / 2, scale: 2),
            Positioned(
              top: 58,
              left: 16,
              right: 16,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '        '),
                    TextSpan(
                      text: data['sendNick'],
                      style: TextStyle(color: AppPalette.txtRoomChat),
                    ),
                    TextSpan(text: ' 在 '),
                    TextSpan(
                      text: data['roomTitle'],
                      style: TextStyle(color: AppPalette.txtRoomChat),
                    ),
                    TextSpan(text: ' 送给 '),
                    TextSpan(
                      text: data['recvNick'],
                      style: TextStyle(color: AppPalette.pink),
                    ),
                    TextSpan(
                      text: ' ${data['giftName']}',
                      style: TextStyle(color: Color(0xFFFFCF2B)),
                    ),
                    // WidgetSpan(
                    //   child: GiftImgState(
                    //     child: NetImage(data['giftPic'], width: 20, height: 20),
                    //   ),
                    // ),
                    TextSpan(text: '×${data['giftNum']}'),
                  ],
                ),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: fw$Regular,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  double get offsetTop => Get.statusBarHeight / Get.pixelRatio + 8;
}
