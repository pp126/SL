import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:app/common/theme.dart';
import 'package:app/nim/nim_help.dart';
import 'package:app/store/red_envelope_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/red_envelope/red_envelope_dialog.dart';
import 'package:app/ui/room/room_page.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/customer/photo_view.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bubble/bubble.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nim_core/nim_core.dart';

class MsgView {
  final NIMMessage data;
  final NIMMessageAttachment obj;

  MsgView(this.data) : obj = data.messageAttachment;

  factory MsgView.fromMsg(NIMMessage data) {
    try {
      switch (data.messageType) {
        case NIMMessageType.text:
          return _Txt$MsgView(data);
          break;
        case NIMMessageType.image:
          return _Img$MsgView(data);
          break;
        case NIMMessageType.audio:
          return _Audio$MsgView(data);
          break;
        case NIMMessageType.custom:
          final custom = jsonDecode(data.content);

          switch (custom['first']) {
            case 6:
              return _Online$MsgView(custom['data'], data);
            case 8:
              return _Gift$MsgView(jsonDecode(custom['data']), data);
            case 9:
              return _RedEnvelope$MsgView(jsonDecode(custom['data']), data);
            case 10:
              data.content = custom['data'];

              return _Txt$MsgView(data);
            case 11:
              return _NewUser$MsgView(custom['data'], data);
          }

          return _Custom$MsgView(custom['data'], data);
          break;
        default:
      }
    } catch (e) {
      // ignore
    }

    return MsgView(data);
  }

  Color get backgroundColor => null;

  VoidCallback get onClick => null;

  Widget content() => Text(data.content);

  Widget _filter(Widget child) => child;

  Widget _padding(Widget child) =>
      Padding(padding: EdgeInsets.all(12), child: child);

  Widget createView() {
    final uid = data.uuid;

    Widget child = _padding(content());

    if (onClick != null) {
      child = GestureDetector(
        child: child,
        onTap: onClick,
        behavior: HitTestBehavior.opaque,
      );
    }

    if (data.isOutgoingMsg) {
      child = $AppBubble(
        child: child,
        nip: BubbleNip.rightTop,
        color: backgroundColor ?? AppPalette.txtWhite,
      );

      child = _filter(child);

      child = outView(uid, child, data.deliveryState);
    } else {
      child = $AppBubble(
        child: child,
        nip: BubbleNip.leftTop,
        color: backgroundColor ?? Colors.white,
      );

      child = _filter(child);

      child = inView(uid, child);
    }

    return child;
  }

  static Widget $Avatar(String uid) {
    try {
      return AvatarView(
        size: 48,
        url: Get.find<String>(tag: 'avatar#$uid'),
      );
    } catch (e) {
      return SizedBox.fromSize(size: Size.square(48));
    }
  }

  static Widget outView(
      String uid, Widget bubble, NIMMessageDeliveryState state) {
    switch (state) {
      case NIMMessageDeliveryState.Failed:
        bubble = Row(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                '失败',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
            ),
            bubble,
          ],
        );
        break;
      case NIMMessageDeliveryState.Delivering:
        bubble = Row(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: CupertinoActivityIndicator(radius: 8),
            ),
            bubble,
          ],
        );
        break;
      case NIMMessageDeliveryState.Delivered:
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [bubble, Spacing.w12, $Avatar(uid)],
    );
  }

  static Widget inView(String uid, Widget bubble) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        $Avatar(uid),
        Spacing.w12,
        bubble,
      ],
    );
  }
}

class _Txt$MsgView extends MsgView {
  _Txt$MsgView(NIMMessage data) : super(data);

  final ts = TextStyle(fontSize: 14, color: AppPalette.dark);

  @override
  Widget content() => Text('${data.text}', style: ts);
}

class _Img$MsgView extends MsgView {
  _Img$MsgView(NIMMessage data) : super(data);

  final _pixelRatio = window.devicePixelRatio;

  @override
  VoidCallback get onClick {
    return () {
      Get.to(
        PhotoViewGalleryScreen(images: [obj.url], index: 0, heroTag: obj.url),
        transition: Transition.noTransition,
      );
    };
  }

  @override
  Widget content() {
    final minW = min(150, obj.width) / _pixelRatio;
    final minH = min(150, obj.height) / _pixelRatio;

    Widget image;

    if (!obj.thumbPath.isNullOrBlank) {
      image = Image.file(File(obj.thumbPath), fit: BoxFit.cover);
    } else if (!obj.path.isNullOrBlank) {
      image = Image.file(File(obj.path), fit: BoxFit.cover);
    } else {
      image = NetImage(obj.thumbUrl, fit: BoxFit.cover);
    }

    Widget child = Container(
      constraints:
          BoxConstraints(minWidth: minW, minHeight: minH, maxHeight: 250),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: obj.width / obj.height,
        child: image,
      ),
    );

    return child;
  }

  @override
  Widget _padding(Widget child) =>
      Padding(padding: EdgeInsets.all(6), child: child);
}

class _Audio$MsgView extends MsgView {
  _Audio$MsgView(NIMMessage data) : super(data);
  static final _player = AudioPlayer() //
    ..playingRouteState = PlayingRouteState.SPEAKERS;

  static final playerIngIds = RxSet({});

  @override
  Widget content() {
    _player.onPlayerStateChanged.listen((AudioPlayerState s) {
      if (s == AudioPlayerState.COMPLETED) {
        playerIngIds.clear();
      }
    });

    final durationView = Text(
      '${Duration(milliseconds: obj.duration).inSeconds}″',
      style: TextStyle(fontSize: 14, color: AppPalette.dark),
    );

    final playView = InkResponse(
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        child: Obx(() {
          return Icon(
            playerIngIds.contains(data.messageId) //
                ? Icons.stop_circle_outlined
                : Icons.play_circle_outline,
            color: Colors.black54,
          );
        }),
      ),
      onTap: () => playerIngIds.contains(data.messageId) ? stop() : play(),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: data.isOutgoingMsg //
          ? [Spacing.w12, durationView, playView]
          : [playView, durationView, Spacing.w12],
    );
  }

  @override
  Widget _padding(Widget child) => child;

  void play() async {
    int result = 0;
    if (File(obj.path).existsSync()) {
      result = await _player.play(obj.path, isLocal: true);
    } else {
      result = await _player.play(obj.url, isLocal: false);
    }
    if (result == 1) {
      playerIngIds.add(data.messageId);
    }
  }

  void stop() async {
    if ((await _player.stop()) == 1) {
      playerIngIds.remove(data.messageId);
    }
  }
}

class _Custom$MsgView extends MsgView {
  final Map ext;

  _Custom$MsgView(this.ext, NIMMessage data) : super(data);

  @override
  Widget content() {
    if (isDebug) {
      final _data = jsonDecode(data.customMessageContent);

      return Text('[${_data['first']},${_data['second']}]');
    }

    return Text('[版本过低]');
  }
}

class _Online$MsgView extends _Custom$MsgView {
  _Online$MsgView(Map ext, NIMMessage data) : super(ext, data);

  @override
  VoidCallback get onClick => () => RoomPage.to(int.parse(ext['uid']));

  @override
  Widget content() {
    final info = ext['userVo'];

    return Row(
      children: [
        AvatarView(url: info['avatar'], size: 48),
        Spacing.w6,
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '您关注的TA\n'),
                TextSpan(
                    text: '${info['nick']} ',
                    style: TextStyle(color: AppPalette.txtPrimary)),
                TextSpan(text: '开播啦'),
              ],
            ),
            style: TextStyle(fontSize: 12, height: 1.5),
          ),
        ),
      ],
    );
  }
}

class _NewUser$MsgView extends _Custom$MsgView {
  _NewUser$MsgView(Map ext, NIMMessage data) : super(ext, data);

  @override
  VoidCallback get onClick => () => RoomPage.to(int.parse(ext['uid']));

  @override
  Widget content() => Text('恭喜您，注册成功');
}

class _Gift$MsgView extends _Custom$MsgView {
  _Gift$MsgView(Map ext, NIMMessage data) : super(ext, data);

  @override
  VoidCallback get onClick => () => RoomPage.to(int.parse(ext['uid']));

  @override
  Widget content() {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '送出 '),
          TextSpan(
            text: ext['giftName'],
            style: TextStyle(color: AppPalette.txtPrimary),
          ),
          WidgetSpan(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: GiftImgState(
                child: NetImage(ext['picUrl'], width: 32, height: 32),
              ),
            ),
          ),
          TextSpan(text: '(${ext['giftPrice']})×'),
          TextSpan(text: '${ext['countNum']}'),
          TextSpan(text: '\n总计：${ext['countNum'] * ext['giftPrice']}'),
        ],
        style: TextStyle(fontSize: 14, color: AppPalette.txtDark),
      ),
    );
  }
}

class _RedEnvelope$MsgView extends _Custom$MsgView {
  _RedEnvelope$MsgView(Map ext, NIMMessage data) : super(ext, data);

  @override
  Color get backgroundColor => Color(0xFFFF4A4A);

  @override
  VoidCallback get onClick =>
      () => RedEnvelopeDialog.to(ext['id'], data.isOutgoingMsg);

  @override
  Widget content() {
    print(ext);
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        width: 217,
        height: 89,
        padding: EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Container(
              width: 35,
              height: 45,
              margin: EdgeInsets.only(right: 10),
              child: Image.asset(IMG.$('packet/图标')),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ext['remark'],
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: fw$SemiBold),
                  ),
                  Divider(color: Colors.white.withOpacity(0.3), height: 10),
                  RedEnvelopeCtrl.use(ext['id'], builder: (status) {
                    return Text(
                      status+"   ${ext['packetNum']}",
                      style: TextStyle(
                          fontSize: 12, color: Colors.white.withOpacity(0.6)),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget _padding(Widget child) => child;

  @override
  Widget _filter(Widget child) {
    final mode = ColorFilter.mode(
      AppPalette.background.withOpacity(0.6),
      BlendMode.dstIn,
    );

    return RedEnvelopeCtrl.use(ext['id'], builder: (status) {
      switch (status) {
        case '已领取':
        case '红包已退回':
        case '红包已过期':
          return ColorFiltered(colorFilter: mode, child: child);
        default:
          return child;
      }
    });
  }
}
