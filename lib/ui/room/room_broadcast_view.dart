import 'package:app/common/theme.dart';
import 'package:app/net/ws_event.dart';
import 'package:app/store/room_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/room/widgets/slide_animated_view.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/level_view.dart';
import 'package:app/widgets/overlay_mixin.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class RoomBroadcastView extends StatefulWidget with IgnorePointerOverlay {
  @override
  _RoomBroadcastViewState createState() => _RoomBroadcastViewState();
}

class _RoomBroadcastViewState extends State<RoomBroadcastView> with BusStateMixin {
  final views = RxMap(<Key, Widget>{});
  final roomCtrl = RoomCtrl.obj;

  @override
  void initState() {
    super.initState();

    on<ChatRoomMemberIn>((event) => onMemberIn(event.data['member']));
    on<OneGiftEvent>((event) => onGift(false, event.data));
    on<MultipleGiftEvent>((event) => onGift(true, event.data));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(color: Colors.white),
      child: Obx(() => Stack(children: views.values.toList(growable: false))),
    );
  }

  void onGift(bool isMultiple, Map data) {
    // TODO 多少钱的礼物需要显示
    final showGiftPrice = 1;

    final giftNum = data['giftNum'];

    if (data['goldPrice'] * giftNum >= showGiftPrice) {
      playGift(
        Tuple2(data['avatar'], data['nick']),
        isMultiple //
            ? Tuple2(null, '全麦')
            : Tuple2(data['targetAvatar'], data['targetNick']),
        giftNum,
        data['giftPic'],
      );
    }

    if (data['hasEffect'] && roomCtrl.value['giftEffectSwitch'] == 0) {
      GiftEffectCtrl.obj.play(data['vggUrl']);
    }
  }

  void onMemberIn(Map member) {
    final showWelcomeLevel = 10;

    // TODO 多少级的用户需要欢迎
    if (member['wealth_level'] >= showWelcomeLevel) {
      playWelcome(member);
    }

    final String carUrl = member['car_url'];

    GiftEffectCtrl.obj.play(carUrl);
  }

  void playWelcome(Map member) {
    final String car = member['car_name'];

    final view = $BorderView(
      color: Tuple2(Color(0x4DDC5C73), Color(0xFFFF607C)),
      children: [
        Spacing.w6,
        WealthIcon(data: member),
        Spacing.w6,
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: member['nick'], style: TextStyle(color: AppPalette.txtPrimary)),
              if (!car.isNullOrBlank) ...[
                TextSpan(text: '\t驾着"'),
                TextSpan(text: car, style: TextStyle(color: AppPalette.txtPrimary)),
                TextSpan(text: '"'),
              ],
              TextSpan(text: '进入了房间'),
            ],
          ),
          style: TextStyle(fontSize: 14, color: Colors.white),
        ),
      ],
    );

    _playAnime(top: Get.height * 0.5, w: 240, h: 48, child: view);
  }

  void playGift(Tuple2 from, Tuple2 to, int giftNum, String giftUrl) {
    Widget $UserView(Tuple2 user) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          AvatarView(
            url: user.item1,
            size: 32,
            side: BorderSide(color: Colors.white),
          ),
          LimitedBox(
            maxWidth: 56,
            child: Text(
              user.item2,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, color: Colors.white),
            ),
          ),
        ],
      );
    }

    final view = $BorderView(
      color: Tuple2(Color(0x337C66FF), Color(0xFF7C66FF)),
      children: [
        Spacing.w8,
        $UserView(from),
        Spacing.w8,
        Text('送', style: TextStyle(fontSize: 18, color: Colors.white)),
        Spacing.w8,
        $UserView(to),
        Spacing.w8,
        GiftImgState(
          child: NetImage(giftUrl, width: 48, height: 48, fit: BoxFit.contain),
        ),
        Spacing.w8,
        Text('×$giftNum', style: TextStyle(fontSize: 14, color: Colors.white)),
      ],
    );

    _playAnime(top: Get.height * 0.3, w: 240, h: 56, child: view);
  }

  void _playAnime({double top, double w, double h, Widget child}) {
    final key = UniqueKey();

    final view = Positioned(
      key: key,
      top: top,
      left: 0,
      width: w,
      height: h,
      child: SlideAnimatedView(
        child: child,
        dock: Tuple3(-(w + 16), 16, -(w + 16)),
        times: Tuple3(Duration(milliseconds: 600), Duration(seconds: 2), Duration(milliseconds: 600)),
        onFinish: () => views.remove(key),
      ),
    );

    views[key] = view;
  }

  Widget $BorderView({Tuple2<Color, Color> color, List<Widget> children}) {
    return Container(
      decoration: ShapeDecoration(
        color: color.item1,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.item2, width: 2),
        ),
      ),
      child: Row(children: children),
    );
  }
}
