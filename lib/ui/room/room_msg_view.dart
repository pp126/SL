import 'dart:async';
import 'dart:ui' as ui show PlaceholderAlignment;

import 'package:app/common/theme.dart';
import 'package:app/net/ws_event.dart';
import 'package:app/sticker/stickers_rd_view.dart';
import 'package:app/store/room_ctrl.dart';
import 'package:app/store/room_sticker_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/room/user_bottom_sheet.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/level_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:tuple/tuple.dart';

class RoomMsgCtrl extends GetxController with BusDisposableMixin {
  final int roomID;
  final bool show;

  RoomMsgCtrl(this.roomID, this.show);

  final _data = <_BaseMsg>[].obs;

  @override
  void onInit() {
    super.onInit();

    _addMsg(
      _Msg$Hint(
        '系统通知：官方倡导绿色健康互动，严禁传播色情、赌博、政治等不良信息，一经发现，封停账号。',
        AppPalette.pink,
      ),
    );
    _addMsg(
      _Msg$Hint(
        '房间公告：${RoomCtrl.obj.value['roomNotice'] ?? ''}',
        AppPalette.txtRoomChat,
      ),
    );

    final String playInfo = RoomCtrl.obj.value['playInfo'];

    if (!playInfo.isNullOrBlank) {
      _addMsg(_Msg$Hint(playInfo, Colors.white));
    }

    //<editor-fold desc="各种消息">
    on<ChatRoomMemberIn>((it) => _addMsg(_Msg$UserIn(it.data)));
    on<SendTextReport>((it) => _addMsg(_Msg$Text(it.data)));
    on<OneGiftEvent>((it) => _addMsg(_Msg$SingleGift(it.data)));
    on<MultipleGiftEvent>((it) => _addMsg(_Msg$MultipleGift(it.data)));
    on<RoomSettingMsgEvent>(
        (it) => _addMsg(_Msg$RoomSettingMsg(it.data, it.cmd)));
    on<TipsMsgEvent>((it) => _addMsg(_Msg$TipsMsg(it.data)));
    on<StickersGameMsgEvent>((it) {
      Timer(Duration(seconds: 2), () {
        if (isClosed) return;

        _addMsg(_Msg$Game(it.data));
      });
    });
    on<RoomDrawEvent>(
      (it) => _addMsg(_Msg$Draw(it.data)),
      // test: (it) => it.data['roomId'] == roomID,
      test: (it) => show,
    );
    //</editor-fold>

    //<editor-fold desc="清屏">
    on<ClearMsgEvent>((it) => _data.clear());
    //</editor-fold>
  }

  _addMsg(_BaseMsg msg) {
    _data.add(msg);
  }
}

class RoomMsgView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetX<RoomMsgCtrl>(
      builder: (it) {
        final _data = it._data;
        final _length = _data.length;

        return ScrollablePositionedList.separated(
          reverse: true,
          initialAlignment: 1,
          padding: EdgeInsets.all(16),
          itemCount: _length,
          itemBuilder: (_, i) => itemBuilder(_data[_length - 1 - i]),
          separatorBuilder: (_, __) => Spacing.h12,
        );
      },
    );
  }

  Widget itemBuilder(_BaseMsg item) =>
      Align(alignment: Alignment.centerLeft, child: item.toView());
}

abstract class _BaseMsg {
  final Map data;

  _BaseMsg(this.data);

  Widget toView() {
    return $Decoration(
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: _content,
      ),
    );
  }

  Widget $Decoration(Widget child) => child;

  List<Widget> get _content;
}

abstract class _Msg$User extends _BaseMsg {
  _Msg$User(Map data) : super(data);

  static final _shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(2),
      topRight: Radius.circular(12),
      bottomLeft: Radius.circular(12),
      bottomRight: Radius.circular(12),
    ),
  );

  Map get _member => data['member'] ?? data;

  Widget $UserClick(Widget child) {
    final uid = _member['account'] ?? _member['uid'];

    return GestureDetector(
      onTap: () => UserBottomSheet.to(int.parse('$uid')),
      child: child,
    );
  }

  @override
  List<Widget> get _content {
    final member = _member;

    return [
      $UserClick(AvatarView(url: member['avatar'], size: 34)),
      Spacing.w10,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              $UserClick(
                Text(
                  member['nick'] ?? '',
                  style: TextStyle(fontSize: 12, color: AppPalette.txtRoomChat),
                ),
              ),
              Spacing.w6,
              WealthIcon(data: member),
              Spacing.w2,
              CharmIcon(data: member)
            ],
          ),
          Spacing.h8,
          Material(
            color: Colors.black.withOpacity(0.3),
            shape: _shape,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: LimitedBox(
                maxWidth: Get.width * 0.6,
                child: content,
              ),
            ),
          ),
        ],
      ),
    ];
  }

  Widget get content;
}

class _Msg$UserIn extends _BaseMsg {
  _Msg$UserIn(Map data) : super(data);

  @override
  List<Widget> get _content {
    final Map _member = data['member'];
    final String car = _member['car_name'];

    return [
      WealthIcon(data: _member),
      Spacing.w2,
      CharmIcon(data: _member),
      Spacing.w6,
      Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: _member['nick'],
              style: TextStyle(color: AppPalette.txtRoomChat),
              recognizer: TapGestureRecognizer() //
                ..onTap = () => UserBottomSheet.to(_member['account']),
            ),
            TextSpan(text: ' '),
            if (!car.isNullOrBlank) ...[
              TextSpan(text: '驾着'),
              TextSpan(text: ' '),
              TextSpan(
                text: car,
                style: TextStyle(color: Color(0xFFFFC22F)),
              ),
              TextSpan(text: ' '),
            ],
            TextSpan(text: '进入了房间'),
          ],
        ),
        style: TextStyle(fontSize: 12, color: Colors.white),
      ),
    ];
  }
}

class _Msg$Text extends _Msg$User {
  _Msg$Text(Map data) : super(data);

  @override
  Widget get content {
    return SelectableText(
      data['content'],
      style: TextStyle(fontSize: 12, color: Colors.white),
    );
  }
}

class _Msg$Game extends _Msg$User {
  _Msg$Game(Map data) : super(data);

  @override
  Widget get content {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Spacing.w6,
        Text(
          '出',
          style: TextStyle(fontSize: 12, color: Colors.white),
        ),
        Spacing.w2,
        $View(),
      ],
    );
  }

  Widget $View() {
    final sticker = data['sticker'];
    final num = sticker['num'];

    final info = StickerCtrl.obj.findByName(sticker['name']);

    switch (info?.type) {
      case 2:
        return GiftImgState(
          child: NetImage(info.getRes(num),
              width: 32, height: 32, optimization: false),
        );
      case 3:
        return Stickers3RdView(num, info);
    }

    return SizedBox.shrink();
  }
}

class _Msg$Draw extends _BaseMsg {
  _Msg$Draw(Map data) : super(data);

  @override
  List<Widget> get _content => [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: '恭喜'),
              TextSpan(
                text: data['nick'],
                style: TextStyle(color: AppPalette.txtRoomChat),
              ),
              TextSpan(text: '玩家在 '),
              // TextSpan(
              //     text: ' ${data['roomTitle']} ',
              //     style: TextStyle(color: AppPalette.pink)),
              TextSpan(
                  text: '${data['drawType'] == 0 ? '普通宝箱' : '高级宝箱'} ',
                  style: TextStyle(color: AppPalette.txtGold)),
              TextSpan(text: ' 开出'),
              TextSpan(
                text: data['giftName'],
                style: TextStyle(color: Color(0xFFFFC22F)),
              ),
              WidgetSpan(
                alignment: ui.PlaceholderAlignment.middle,
                child: NetImage(data['giftPic'], width: 18, height: 18),
              ),
              TextSpan(
                text: '(${data['goldPrice']})',
                style: TextStyle(color: Color(0xFFFFFFFF)),
              ),
              TextSpan(
                text: '×${data['giftNum']}',
                style: TextStyle(color: Color(0xFFFFC22F)),
              ),
            ],
          ),
          style: TextStyle(fontSize: 12, color: Colors.white),
        ),
      ];
}

//<editor-fold desc="礼物">
abstract class _Msg$Gift extends _Msg$User {
  _Msg$Gift(Map data) : super(data);

  Widget $GiftView(/*名称&图片*/ Tuple2<String, String> gift);

  List<InlineSpan> $GiftSpan(/*名称&图片*/ Tuple2<String, String> gift) {
    return [
      TextSpan(text: gift.item1),
      WidgetSpan(
        alignment: ui.PlaceholderAlignment.middle,
        child: GiftImgState(
          child: NetImage(gift.item2, width: 18, height: 18),
        ),
      ),
      TextSpan(text: '×${data['giftNum']}'),
    ];
  }

  @override
  Widget get content => $GiftView(Tuple2(data['giftName'], data['giftPic']));
}

class _Msg$SingleGift extends _Msg$Gift {
  _Msg$SingleGift(Map data) : super(data);

  @override
  Widget $GiftView(Tuple2<String, String> gift) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '送给',
            style: TextStyle(color: Colors.white),
          ),
          TextSpan(
            text: ' ${data['targetNick']} ',
            style: TextStyle(color: AppPalette.txtRoomChat),
          ),
          ...$GiftSpan(gift),
        ],
      ),
      style: TextStyle(fontSize: 12, color: Color(0xFFFFC22F)),
    );
  }
}

class _Msg$MultipleGift extends _Msg$Gift {
  _Msg$MultipleGift(Map data) : super(data);

  @override
  Widget $GiftView(Tuple2<String, String> gift) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '全麦送出 ',
            style: TextStyle(color: Colors.white),
          ),
          ...$GiftSpan(gift),
        ],
      ),
      style: TextStyle(fontSize: 12, color: Color(0xFFFFC22F)),
    );
  }
}
//</editor-fold>

class _Msg$RoomSettingMsg extends _BaseMsg {
  final RoomSettingCmd cmd;

  _Msg$RoomSettingMsg(Map data, this.cmd) : super(data);

  static final _shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(12),
      topRight: Radius.circular(12),
      bottomLeft: Radius.circular(2),
      bottomRight: Radius.circular(12),
    ),
  );

  @override
  List<Widget> get _content => [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '系统消息',
                style: TextStyle(color: Color(0xFFFFA8A8)),
              ),
              // TODO data['uid'] 显示昵称
              TextSpan(
                text: ' 管理员 ',
                style: TextStyle(color: AppPalette.txtRoomChat),
              ),
              TextSpan(
                text: cmd.name,
                style: TextStyle(color: Color(0xFFE2DDFF)),
              ),
            ],
          ),
          style: TextStyle(fontSize: 12),
        ),
      ];

  @override
  Widget $Decoration(Widget child) {
    return Material(
      color: Colors.black.withOpacity(0.3),
      shape: _shape,
      child: Padding(padding: EdgeInsets.all(12), child: child),
    );
  }
}

class _Msg$TipsMsg extends _BaseMsg {
  _Msg$TipsMsg(Map data) : super(data);

  static final _shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(12),
      topRight: Radius.circular(12),
      bottomLeft: Radius.circular(2),
      bottomRight: Radius.circular(12),
    ),
  );

  @override
  List<Widget> get _content => [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '系统提醒：',
                style: TextStyle(color: Color(0xFFFFA8A8)),
              ),
              TextSpan(
                text: data['msg'],
                style: TextStyle(color: Color(0xFFE2DDFF)),
              ),
            ],
          ),
          style: TextStyle(fontSize: 12),
        ),
      ];

  @override
  Widget $Decoration(Widget child) {
    return Material(
      color: Colors.black.withOpacity(0.3),
      shape: _shape,
      child: Padding(padding: EdgeInsets.all(12), child: child),
    );
  }
}

class _Msg$Hint extends _BaseMsg {
  final String msg;
  final Color color;

  _Msg$Hint(this.msg, this.color) : super(null);

  static final _shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  );

  @override
  List<Widget> get _content => [
        LimitedBox(
          maxWidth: Get.width * 0.5,
          child: Text(
            msg,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ),
      ];

  @override
  Widget $Decoration(Widget child) {
    return Material(
      color: Colors.black.withOpacity(0.3),
      shape: _shape,
      child: Padding(padding: EdgeInsets.all(8), child: child),
    );
  }
}
