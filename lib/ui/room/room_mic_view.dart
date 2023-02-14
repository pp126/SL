import 'dart:async';
import 'dart:io';

import 'package:app/common/app_crypto.dart';
import 'package:app/common/cache_manager.dart';
import 'package:app/common/theme.dart';
import 'package:app/net/ws_event.dart';
import 'package:app/rtc/rtc_help.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/store/room_sticker_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/common/svga_icon.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/room/master_mic_bottom_sheet.dart';
import 'package:app/ui/room/widgets/mic_view.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meta/meta.dart';
import 'package:tuple/tuple.dart';

@protected
class RoomMicView extends GetWidget<RoomMicCtrl> {
  final _keys = <int, GlobalKey>{};

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Stack(
        children: [
          Positioned(
              key: _keys.putIfAbsent(-1, () => GlobalKey()), child: $MicView()),
          ...$StickerView(controller.stickerMap),
        ],
      );
    });
  }

  Iterable<Widget> $StickerView(Map<int, Tuple2<Map, Timer>> data) {
    return data.entries.map(
      (it) {
        try {
          final ctx = _keys[it.key].currentContext;

          assert(ctx != null, 'ctx[${it.key}] is null');

          final box = ctx.findRenderObject() as RenderBox;

          final pos = box.localToGlobal(
            Offset.zero,
            ancestor: _keys[-1].currentContext.findRenderObject(),
          );

          final size = 56.0;

          final top = pos.dy + (box.size.height - size) / 2;
          final left = pos.dx + (box.size.width - size) / 2;

          return Positioned(
            width: size,
            height: size,
            top: top - 10,
            left: left,
            child: StickerCtrl.toView(it.value.item1),
          );
        } catch (_) {
          return SizedBox.shrink();
        }
      },
    );
  }

  Widget $MicView() {
    return Obx(() {
      var i = 0;

      final data = controller.micMap;

      return Column(
        children: <Widget>[
          // itemBuilder(data[i++], i),
          ...List.generate(
            2,
            (index) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (_) => itemBuilder(data[i++], i)),
            ),
          ),
        ].separator(Spacing.h16),
      );
    });
  }

  Widget itemBuilder(RoomMicInfo info, int index) {
    final user = info?.user;
    final state = info?.state;

    return GestureDetector(
      child: Container(
        width: 80,
        height: 90,
        child: user == null
            ? emptyMicView(state, index)
            : userMicView(user, state, index),
      ),
      onTap: () => MasterMicBottomSheet.show(info, index - 1),
    );
  }

  Widget userMicView(RoomMicUser info, RoomMicState state, int index) {
    final uid = info.uid;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        micStateWrap(
          uid: uid,
          micEnable: state?.micEnable ?? true,
          child: SpeakCtrl.use(uid, builder: (anime) {
            Widget avatar = AvatarView(
              url: info.avatar,
              size: 48,
              side: BorderSide(color: AppPalette.txtWhite, width: 2),
            );

            final vgg = info.headWear.item1;
            final img = info.headWear.item2;

            if (!(vgg.isNullOrBlank && img.isNullOrBlank)) {
              avatar = Stack(
                children: [
                  avatar,
                  Positioned.fill(
                    top: -6,
                    bottom: -6,
                    left: -6,
                    right: -6,
                    child: vgg.isNullOrBlank //
                        ? GiftImgState(child: NetImage(img, fit: BoxFit.fill))
                        : FutureBuilder<File>(
                            future:
                                vgg.then(GiftCacheManager.obj.getSingleFile),
                            builder: (_, snapshot) {
                              final vggUrl = snapshot.data;

                              return vggUrl.isNull
                                  ? SizedBox.shrink()
                                  : SVGAImg(file: vggUrl);
                            },
                          ),
                  ),
                ],
              );
            }

            return AnimatedBuilder(
              key: _keys.putIfAbsent(
                  index, () => GlobalKey(debugLabel: 'Mic#$index')),
              animation: anime,
              child: avatar,
              builder: (_, child) {
                final value = anime.value;

                return DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: AppPalette.subSplash,
                          blurRadius: value * 6,
                          spreadRadius: value * 2),
                    ],
                  ),
                  child: child,
                );
              },
            );
          }),
        ),
        micIndexView(index, name: info.nickName, uid: uid),
        MicCharmView(uid),
      ],
    );
  }

  Widget emptyMicView(RoomMicState info, int index) {
    Widget micIcon;

    if (info?.posEnable ?? true) {
      final type = info?.micType;

      switch (type) {
        case 1:
        case 2:
        case 3:
          micIcon = Image.asset(IMG.$('room/pos_$type'), scale: 3);
          break;
        default:
          micIcon = Image.asset(IMG.$('room/pos_0'), scale: 3);
      }
    } else {
      micIcon = SvgPicture.asset(SVG.$('room/禁麦'), width: 28, height: 28);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        micStateWrap(
          micEnable: info?.micEnable ?? true,
          child: MicView(micIcon),
        ),
        micIndexView(index),
        MicCharmView(),
      ],
    );
  }

  Widget micIndexView(int index, {String name = '麦位', int uid}) {
    Widget levelView(int uid) {
      final svg = SVG.$('room/等级地板');

      Widget bg([Color color]) =>
          SvgPicture.asset(svg, color: color, key: Key('$uid#$color'));

      return uid == null //
          ? bg()
          : SpeakCtrl.use2(uid, builder: (b) => bg(b ? AppPalette.pink : null));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          fit: StackFit.loose,
          alignment: Alignment.center,
          children: [
            levelView(uid),
            Text(
              '$index',
              style: TextStyle(fontSize: 8, color: AppPalette.primary),
            ),
          ],
        ),
        Spacing.w4,
        Text(
          name,
          style: TextStyle(fontSize: 10, color: Colors.white),
        ),
      ],
    );
  }

  Widget micStateWrap({Widget child, bool micEnable, int uid}) {
    if (uid == null && micEnable) return child;

    Widget $MicView(bool micEnable, [bool isOpen = false]) {
      return Image.asset(
        IMG.$(
          isOpen
              ? 'mic/开放'
              : micEnable
                  ? 'mic/静音'
                  : 'mic/封禁',
        ),
        scale: 8,
        isAntiAlias: true,
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Transform.translate(
          offset: Offset(16, 16),
          child: uid == null //
              ? $MicView(micEnable)
              : RoomMicCtrl.useState(uid,
                  builder: (b) => $MicView(micEnable, b)),
        ),
      ],
    );
  }
}

class MicCharmView extends StatelessWidget {
  final int uid;
  final double rate;

  MicCharmView([this.uid, this.rate = 1]);

  @override
  Widget build(BuildContext context) {
    final ts = TextStyle(fontSize: 8, color: Colors.white);

    return Container(
      height: 16,
      decoration:
          ShapeDecoration(color: Color(0xFF7C66FF), shape: StadiumBorder()),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 16,
            height: 16,
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: FittedBox(
              fit: BoxFit.contain,
              child: Icon(Icons.favorite, color: Colors.white),
            ),
          ),
          uid == null //
              ? Text('0', style: ts)
              : GetX<RoomMicCtrl>(
                  builder: (it) {
                    final data = it.charmMap[uid];
                    final charm = data == null ? 0 : data['value'];
                    if (rate == 1) {
                      return Text('$charm', style: ts);
                    } else {
                      return Text(
                          '$charm * $rate = ${(charm * rate).toStringAsFixed(1)}',
                          style: ts);
                    }
                  },
                ),
          Spacing.w4,
        ],
      ),
    );
  }
}

class RoomMicCtrl extends GetxController with BusDisposableMixin {
  final RxMap<int, RoomMicInfo> micMap;
  final micState = RxSet<int>({});
  final charmMap = RxMap(<int, Map>{});
  final stickerMap = RxMap(<int, Tuple2<Map, Timer>>{});

  RoomMicCtrl(List queueList) : micMap = RxMap(transform(queueList));

  static Map<int, RoomMicInfo> transform(List data) {
    return Map.fromIterable(
      data,
      key: (it) => it['key'],
      value: (it) => RoomMicInfo.fromJson(it['value']),
    );
  }

  @override
  void onInit() {
    super.onInit();
    //<editor-fold desc="麦序">
    // 重新上线回刷新
    bus(CMD.refreshMic, (data) => micMap.assignAll(transform(data)));

    void _update(int key, RoomMicInfo Function(RoomMicInfo) fun) {
      final newInfo = fun(micMap[key]);

      final newUser = newInfo?.user;

      if (newUser != null &&
          !newInfo.state.micEnable &&
          RtcHelp.micSwitch.value) {
        if (newUser.uid == OAuthCtrl.obj.uid) {
          showToast('麦位已被禁言');

          RtcHelp.micSwitch.value = false;
        }
      }

      micMap[key] = newInfo;
    }

    on<QueueMemberUpdateNotice>((event) {
      final data = event.data;

      final key = data['key'];

      switch (data['type']) {
        case 1: //上麦
          final user = RoomMicUser.fromJson(data['value']);

          micMap.forEach((k, v) {
            final _user = v.user;

            if (_user != null && _user.uid == user.uid) {
              _update(
                k,
                (it) => RoomMicInfo(user: null, state: it?.state),
              );
            }
          });

          _update(
            key,
            (it) => RoomMicInfo(user: user, state: it?.state),
          );

          break;
        case 2: //下麦
          _update(
            key,
            (it) => RoomMicInfo(user: null, state: it?.state),
          );

          break;
        default:
          assert(false, '未处理的数据 => $data');
      }
    });

    on<QueueMicUpdateNotice>((event) {
      final data = event.data;

      _update(
        data['key'],
        (it) => RoomMicInfo(
            user: it?.user, state: RoomMicState.fromJson(data['mic_info'])),
      );
    });
    //</editor-fold>

    //<editor-fold desc="贴纸">
    final keepDuration = Duration(seconds: 2);

    playStickers(int uid, Map sticker, Duration keep) {
      for (final it in micMap.entries) {
        if (uid == it.value?.user?.uid) {
          final pos = it.key + 1;

          stickerMap.remove(pos)?.item2?.cancel();

          stickerMap[pos] = Tuple2(
            sticker,
            Timer(keep, () => stickerMap.remove(pos)),
          );

          return;
        }
      }

      assert(false, '逻辑异常【下麦发送贴纸】=> $sticker');
    }

    on<StickersMsgEvent>((event) {
      final data = event.data;
      final sticker = {'name': data['sticker'], 'type': 1};
      final uid = int.parse('${data['uid']}');

      playStickers(uid, sticker, keepDuration);
    });

    on<StickersGameMsgEvent>((event) {
      final data = event.data;
      final uid = int.parse('${data['uid']}');

      playStickers(uid, data['sticker'], keepDuration * 2);
    });
    //</editor-fold>

    //<editor-fold desc="更新魅力">
    on<UpdateCharmEvent>((event) {
      charmMap
        ..clear()
        ..addAll(event.charm);
    });
    //</editor-fold>

    bus<Tuple2<int, bool>>(CMD.micState, (it) {
      if (it.item2) {
        if (micState.add(it.item1)) {
          assert(false, '逻辑错误 => $it');
        }
      } else {
        if (micState.remove(it.item1)) {
          assert(false, '逻辑错误 => $it');
        }
      }
    });
  }

  @override
  void onClose() {
    super.onClose();

    stickerMap
      ..forEach((_, v) => v.item2.cancel())
      ..clear();
  }

  static Widget atMic({Widget Function(RoomMicState state, bool b) builder}) {
    return GetX<RoomMicCtrl>(
      builder: (it) {
        final myUid = OAuthCtrl.obj.uid;

        final atMic = it.micMap.values.firstWhere(
          (it) => it.user?.uid == myUid,
          orElse: () => null,
        );

        final state = atMic?.state;

        return builder(state, state?.micEnable ?? false);
      },
    );
  }

  static Widget useState(int uid, {Widget Function(bool b) builder}) {
    final myUid = OAuthCtrl.obj.uid;

    if (uid == myUid) {
      return ObxValue<RxBool>((it) => builder(it.value), RtcHelp.micSwitch);
    }

    return GetX<RoomMicCtrl>(
      builder: (it) {
        return builder(it.micState.contains(uid));
      },
    );
  }

  static RoomMicCtrl get obj => Get.find();
}

class RoomMicInfo {
  final RoomMicUser user;
  final RoomMicState state;

  RoomMicInfo({this.user, this.state});

  factory RoomMicInfo.fromJson(Map data) {
    final member = data['member'];

    return RoomMicInfo(
      user: member == null ? null : RoomMicUser.fromJson(member),
      state: RoomMicState.fromJson(data['mic_info']),
    );
  }
}

class RoomMicUser {
  final int uid;
  final String avatar;
  final String nickName;
  final Tuple2<Future<String>, String> headWear;

  RoomMicUser({this.uid, this.avatar, this.nickName, this.headWear}) {
    SpeakCtrl._putCtrl(uid);
  }

  factory RoomMicUser.fromJson(Map data) {
    Future<String> vgg;

    final String vggUrl = data['headwear_vgg_url'];

    if (!vggUrl.isNullOrBlank) {
      vgg = UrlCrypto.decode(vggUrl);
    }

    return RoomMicUser(
      uid: data['account'],
      avatar: data['avatar'],
      nickName: data['nick'],
      headWear: Tuple2(vgg, data['headwear_url']),
    );
  }
}

class RoomMicState {
  final bool posEnable;
  final bool micEnable;
  final int micType;

  RoomMicState({this.posEnable = true, this.micEnable = true, this.micType});

  factory RoomMicState.fromJson(Map data) {
    return RoomMicState(
      posEnable: data['posState'] == 0,
      micEnable: data['micState'] == 0,
      micType: data['micType'] ?? 0,
    );
  }
}

class SpeakCtrl extends GetxController
    with SingleGetTickerProviderMixin, BusDisposableMixin {
  final int uid;

  SpeakCtrl._(this.uid);

  static final _users = Set<String>();

  static void _putCtrl(int uid) {
    final tag = '$uid';

    Get.put<SpeakCtrl>(SpeakCtrl._(uid), tag: tag, permanent: true);

    _users.add(tag);
  }

  static Future delAll() async {
    for (final it in _users) {
      await Get.delete<SpeakCtrl>(tag: it, force: true);
    }

    _users.clear();
  }

  static Widget use(int uid,
      {@required Widget Function(Animation<double>) builder}) {
    return GetBuilder<SpeakCtrl>(
        tag: '$uid', builder: (it) => builder(it._anime));
  }

  static Widget use2(int uid, {@required Widget Function(bool) builder}) {
    return GetX<SpeakCtrl>(
        tag: '$uid', builder: (it) => builder(it._status.value));
  }

  Timer _timer;
  AnimationController _ctrl;
  Animation<double> _anime;

  final _status = false.obs;

  @override
  void onInit() {
    super.onInit();

    final duration = Duration(milliseconds: 1000);

    _ctrl = AnimationController(
      vsync: this,
      duration: duration,
      animationBehavior: AnimationBehavior.preserve,
    );

    _anime = CurvedAnimation(
      parent: CurvedAnimation(parent: _ctrl, curve: SawTooth(2)),
      curve: Curves.bounceOut,
    );

    bus(CMD.speak(OAuthCtrl.obj.uid == uid ? 0 : uid), (_) {
      _status.value = true;

      _timer?.cancel();
      _timer = Timer(duration, () {
        _status.value = false;

        _ctrl
          ..stop()
          ..reset();
      });

      _ctrl.repeat();
    });
  }

  @override
  void onClose() {
    super.onClose();

    _timer?.cancel();
    _ctrl.dispose();
  }
}
