import 'dart:math';

import 'package:agora_rtc_engine/rtc_engine.dart' show AudioMixingStateCode;
import 'package:app/common/asset_pre_cache.dart';
import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/net/host.dart';
import 'package:app/net/ws_event.dart';
import 'package:app/net/ws_help.dart';
import 'package:app/nim/nim_help.dart';
import 'package:app/rtc/rtc_help.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/store/room_ctrl.dart';
import 'package:app/store/room_like_ctrl.dart';
import 'package:app/store/room_manager_ctrl.dart';
import 'package:app/store/room_overlay_ctrl.dart';
import 'package:app/store/room_sticker_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/common/music_dialog.dart';
import 'package:app/ui/common/report_mixin.dart';
import 'package:app/ui/common/tag_icon.dart';
import 'package:app/ui/message/message_list_view.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/room/gift_effect_overlay.dart';
import 'package:app/ui/room/intro/intro_overlay.dart';
import 'package:app/ui/room/menu_bottom_sheet.dart';
import 'package:app/ui/room/mic_stickers_bottom_sheet.dart';
import 'package:app/ui/room/room_bg_page.dart';
import 'package:app/ui/room/room_broadcast_view.dart';
import 'package:app/ui/room/room_mic_view.dart';
import 'package:app/ui/room/room_msg_view.dart';
import 'package:app/ui/room/room_rank_page.dart';
import 'package:app/ui/room/room_user_view.dart';
import 'package:app/ui/room/setting_bottom_sheet.dart';
import 'package:app/ui/room/setting_room_page.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/overlay_mixin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share/share.dart';

import 'dialog/room_details_bottom_sheet.dart';
import 'gift_bottom_sheet.dart';
import 'lucky/dialog/lucky_bottom_sheet.dart';
import 'msg_bottom_sheet.dart';

class RoomPage extends StatefulWidget {
  RoomPage._();

  static void to([int roomUid]) {
    final myUid = OAuthCtrl.obj.uid;

    RoomOverlayCtrl.obj
        .to(roomUid ?? myUid, roomUid == null || myUid == roomUid);
  }

  static void show() async {
    ImgPreCache.x3({'礼物'}).doPreCache();

    final result = await Get.to(
      RoomPage._().toOverlay(),
      popGesture: false,
      duration: Duration.zero,
      transition: Transition.noTransition,
    );

    if (result == true) {
      RoomOverlayCtrl.obj.miniState();
    } else {
      await RoomOverlayCtrl.obj.closeState();
    }
  }

  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage>
    with _RoomClickMixin, BusStateMixin, OverlayMixin {
  @override
  void initState() {
    super.initState();

    onFrameEnd((_) => RoomOverlayCtrl.obj.normalState());

    bus(CMD.at_user_room, (atNick) => onMsgClick(atNick));

    on<ChatRoomMemberKicked>((event) async {
      final msg = event.data['reason_msg'];

      if (msg != null) {
        await Get.alertDialog(msg);
      }

      Get.untilByCtx(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.back(result: true);

        return false;
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(child: $RoomBG()),
          Scaffold(
            backgroundColor: Color(0x66000000),
            drawerEnableOpenDragGesture: false,
            endDrawerEnableOpenDragGesture: false,
            drawer: $Drawer(RoomUserView()),
            endDrawer: $Drawer(RoomBGDrawer()),
            body: SafeArea(
              minimum: EdgeInsets.only(bottom: 20),
              child: $Body(),
            ),
          ),
          Positioned(
              right: 10,
              bottom: 88,
              child: SafeArea(child: _RightActionView())),
        ],
      ),
    );
  }

  Widget $RoomBG() {
    return GetX<RoomCtrl>(
      builder: (ctrl) {
        final String img = ctrl.value['backPic'];

        return img.isNullOrBlank
            ? SizedBox.shrink()
            : NetImage(img, fit: BoxFit.cover);
      },
    );
  }

  Widget $Body() {
    return Column(
      children: [
        _UserInfoView(),
        Spacing.h8,
        _MiddleActionView(),
        Spacing.h16,
        $RoomOwner(),
        Spacing.h16,
        RoomMicView(),
        Spacing.h8,
        Expanded(child: RepaintBoundary(child: RoomMsgView())),
        _BottomActionView(this),
      ],
    );
  }

  Widget $RoomOwner() {
    return Container(
      child: GetX<RoomCtrl>(builder: (it) {
        final data = it.value;
        return Column(
          children: [
            _UserInfoView().$AvatarView(data,70),
            Spacing.h2,
            MicCharmView(it.ownerUid, 0.8),
            Spacing.h2,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.circular(6)),
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    '房主',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${data['title']}',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ],
            )
          ],
        );
      }),
    );
  }

  Widget $Drawer(Widget child) {
    return FractionallySizedBox(
      heightFactor: 1,
      widthFactor: 0.5,
      child: Material(
        color: AppPalette.dark,
        child: SafeArea(child: child),
      ),
    );
  }

  @override
  List<Widget> get overlay => [
        GiftEffectOverlay(),
        RoomBroadcastView(),
        if (showTips(PrefKey.tips('房间引导'))) IntroOverlay(),
      ];
}

class _UserInfoView extends StatelessWidget with _RoomClickMixin, ReportMixin {
  final double _height = 48;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      child: GetX<RoomCtrl>(builder: (it) {
        final data = it.value;

        return Row(
          children: [
            const SizedBox(width: 20),
            // $AvatarView(data),
            Expanded(child: $InfoView(it.ownerUid, data)),
            $ActionView(data),
          ],
        );
      }),
    );
  }

  Widget $AvatarView(Map data,[double height = 48]) {
    final avatar = InkWell(
      onTap: () => Get.showBottomSheet(RoomDetailsBottomSheet(),
          bgColor: AppPalette.sheetDark),
      child: AvatarView(
        url: data['avatar'],
        size: height,
        side: BorderSide(width: 2, color: AppPalette.txtWhite),
      ),
    );

    final sticker = GetX<RoomMicCtrl>(
      builder: (it) {
        final data = it.stickerMap[0];

        if (data == null) return SizedBox.shrink();

        return StickerCtrl.toView(data.item1);
      },
    );

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 8),
      child: Stack(children: [avatar, sticker]),
    );
  }

  Widget $InfoView(int ownerUid, Map data) {
    final String roomPwd = data['roomPwd'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            TagIcon(tag: data['tagPict']),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  data['title'] ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        Spacing.h4,
        Row(
          children: [
            Text('房间ID:${data['roomId']}',
                    style: TextStyle(fontSize: 10, color: Colors.white))
                .toTagView(15, Color(0x33FFFFFF)),
            Spacing.w4,
            MicCharmView(ownerUid),
            Spacing.w4,
            if (!roomPwd.isNullOrBlank)
              Icon(Icons.lock_outline, size: 12, color: AppPalette.pink),
          ],
        ),
      ],
    );
  }

  Widget $ActionView(Map data) {
    return Row(
      children: [
        if (Get.isRegistered<RoomLikeCtrl>())
          GetBuilder<RoomLikeCtrl>(builder: (it) {
            return it.isLike //
                ? xActionBtn(
                    icon: Icon(Icons.favorite, color: AppPalette.pink),
                    onPressed: () => it.like(false),
                  )
                : xActionBtn(
                    icon: SvgPicture.asset(SVG.$('room/ic_add'),
                        color: Colors.white),
                    onPressed: () => it.like(true),
                  );
          }),
        'room/ic_share'.toSvgActionBtn(
          color: Colors.white,
          onPressed: () {
            final uri = host.$default(
              'share/invitationRoom.html',
              {'roomId': '${RoomCtrl.obj.roomID}'},
            );

            Share.share('${OAuthCtrl.obj.info['nick']}带你走进Ta的直播间，访问 $uri 查看详情',
                subject: '房间分享');
          },
        ),
        'room/ic_more'.toSvgActionBtn(
          color: Colors.white,
          onPressed: () async {
            final result = await Get.dialog(
              MenuBottomSheet(),
              barrierColor: AppPalette.transparent,
              barrierDismissible: true,
              useSafeArea: false,
            );

            switch (result) {
              case '关闭房间':
                simpleSub(
                  Api.Room.close(RoomCtrl.obj.roomUid),
                  msg: '关闭房间成功',
                  callback: Get.back,
                );
                break;
              case '最小化':
                Get.back(result: true);
                break;
              case '退出房间':
                Get.back();
                break;
            }
          },
        ),
      ],
    );
  }
}

class _MiddleActionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dec = ShapeDecoration(
      shape: StadiumBorder(),
      color: Color(0x33000000),
    );

    Widget $Item({Widget child}) =>
        Container(height: 30, decoration: dec, child: child);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            child: $Item(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    SvgPicture.asset(SVG.$('main/nav_我的'), height: 16),
                    Spacing.w4,
                    GetX<RoomCtrl>(
                      builder: (ctrl) {
                        return Text(
                          '${ctrl.onlineNum.value}',
                          style: TextStyle(
                              fontSize: 14, color: AppPalette.txtWhite),
                        );
                      },
                    ),
                    Icon(Icons.keyboard_arrow_right,
                        size: 16, color: AppPalette.txtWhite),
                  ],
                ),
              ),
            ),
            onTap: () => Scaffold.of(context).openDrawer(),
          ),
          Spacing.w8,
          InkResponse(
            child: $Item(
              child: AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: SvgPicture.asset(SVG.$('room/消息')),
                ),
              ),
            ),
            onTap: () {
              final playInfo = RoomCtrl.obj.value['roomNotice'] ?? '';

              Get.infoDialog(title: '房间公告', msg: playInfo);
            },
          ),
          Spacing.w8,
          $Item(
            child: AspectRatio(
              aspectRatio: 1,
              child: Obx(() {
                final it = RtcHelp.networkQuality.value;

                Color color;

                // 如果SDK网络质量不是按照顺序排列就有问题
                final quality = (it.item1.index + it.item2.index) ~/ 2;

                if (quality < 3) {
                  color = Colors.green;
                } else if (quality < 5) {
                  color = Colors.orange;
                } else {
                  color = Colors.red;
                }

                return Icon(Icons.wifi, size: 16, color: color);
              }),
            ),
          ),
          Spacing.w8,
          RoomMicCtrl.atMic(
            builder: (_, b) => b
                ? InkResponse(
                    child: $Item(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Obx(() {
                          final status = RtcHelp.bgmState.value ==
                                  AudioMixingStateCode.Playing //
                              ? Colors.green
                              : Colors.white;

                          return Icon(Icons.music_note_rounded,
                              size: 16, color: status);
                        }),
                      ),
                    ),
                    onTap: () => Get.dialog(MusicDialog()),
                  )
                : SizedBox.shrink(),
          ),
          Spacing.exp,
          MixinBuilder<RoomManagerCtrl>(
            builder: (managerCtrl) {
              final roomCtrl = RoomCtrl.obj;

              //0 房主，1 管理员，2 所有人 可见
              final status = roomCtrl.value['billboardStatus'] ?? 0;

              bool showRank;

              if (status == 2) {
                showRank = true;
              } else {
                final myUid = OAuthCtrl.obj.uid;

                if (roomCtrl.isOwner()) {
                  showRank = true;
                } else {
                  showRank = status == 1 && managerCtrl.isAdmin(myUid);
                }
              }

              return showRank
                  ? GestureDetector(
                      child: SvgPicture.asset(SVG.$('room/排行榜')),
                      onTap: () => Get.to(RoomRankPage(roomCtrl.roomUid)),
                    )
                  : SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

class _BottomActionView extends StatelessWidget {
  final _RoomClickMixin clickMixin;

  _BottomActionView(this.clickMixin);

  final size = 56.0;

  @override
  Widget build(BuildContext context) {
    final audioSwitch = RtcHelp.audioSwitch;
    final micSwitch = RtcHelp.micSwitch;

    return Container(
      height: size,
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GetX<RoomCtrl>(
            builder: (ctrl) => ctrl.value['publicChatSwitch'] == 0 //
                ? xBtn$1('说说话', clickMixin.onMsgClick)
                : xBtn$1('禁言中', null),
          ),
          Spacing.w6,
          Obx(() => xBtn$2('声音_${audioSwitch.value ? 1 : 0}',
              AppPalette.txtWhite, audioSwitch.toggle)),
          RoomMicCtrl.atMic(
            builder: (state, b) => state != null
                ? Row(
                    children: [
                      if (b) ...[
                        Spacing.w4,
                        Obx(() => xBtn$2('麦克风_${micSwitch.value ? 1 : 0}',
                            AppPalette.txtWhite, micSwitch.toggle))
                      ],
                      Spacing.w4,
                      xBtn$2('贴纸', AppPalette.txtWhite,
                          clickMixin.onStickersClick),
                    ],
                  )
                : SizedBox.shrink(),
          ),
          Spacing.exp,
          NotifierView(NimHelp.unreadCount, (num) {
            var tag = '标签';

            if (num > 0) {
              tag += '_badge';
            }

            return xBtn$2(tag, Color(0xFFFFCB2F), clickMixin.onMessageClick);
          }),
          Spacing.w4,
          xBtn$2(
              '更多', AppPalette.txtWhite, () => clickMixin.onMoreClick(context)),
          Spacing.w6,
          xBtn(
              child:
                  Image.asset(IMG.$('礼物'), width: size, height: size, scale: 3),
              onTap: clickMixin.onGiftClick),
        ],
      ),
    );
  }

  Widget xBtn$1(String title, VoidCallback onTap) {
    final child = Container(
      width: 100,
      height: 34,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(SVG.$('room/$title')),
          Spacing.w4,
          Text(title, style: TextStyle(fontSize: 14, color: AppPalette.dark)),
        ],
      ),
    );

    return xBtn(child: child, color: AppPalette.txtWhite, onTap: onTap);
  }

  Widget xBtn$2(String icon, Color color, VoidCallback onTap) {
    final child = Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      child: SvgPicture.asset(SVG.$('room/$icon')),
    );

    return xBtn(child: child, color: color, onTap: onTap);
  }

  Widget xBtn({Widget child, VoidCallback onTap, Color color}) {
    return Material(
      color: color,
      shape: StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkResponse(child: child, onTap: onTap),
    );
  }
}

class _RightActionView extends StatelessWidget {
  final data = {
    // '红包': AppPalette.txtWhite,
    '宝箱': AppPalette.primary,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: data.entries.map(createItem).separator(Spacing.h20),
    );
  }

  Widget createItem(MapEntry data) {
    return Material(
      type: MaterialType.circle,
      color: data.value,
      child: InkResponse(
        onTap: () => onItemClick(data.key),
        child: Container(
          width: 56,
          height: 56,
          child: Image.asset(IMG.$('ic_${data.key}'), scale: 1.9),
        ),
      ),
    );
  }

  void onItemClick(String item) {
    switch (item) {
      case '宝箱':
        final api = Api.User.getMaxPrizeSeniority();

        simpleSub(api, msg: null, callback: () async {
          final List result = await api;

          if (result.isBlank) {
            showToast('暂不可用');
          } else {
            Get.showBottomSheet(
              LuckyBottomSheet(RoomCtrl.obj.roomID, result),
              bgColor: AppPalette.sheetDark,
            );
          }
        });

        return;
    }
  }
}

mixin _RoomClickMixin {
  final _msgCtrl = TextEditingController();

  void onMsgClick([atNick]) {
    if (atNick is String) _msgCtrl.text += ' @$atNick ';

    final onSub = (txt) async {
      try {
        WsApi.sendTxtMsg(txt);
      } catch (e) {
        errLog(e);

        _msgCtrl.text += txt;

        showToast('消息发送失败');
      }
    };

    Get.showBottomSheet(MsgBottomSheet(_msgCtrl, onSub));
  }

  void onGiftClick() {
    final roomCtrl = RoomCtrl.obj;

    final ownerUid = roomCtrl.ownerUid;
    final myUid = OAuthCtrl.obj.uid;

    final select = RxSet<int>({});
    final users = <GiftSend2RoomEntity>[];

    RoomMicCtrl.obj.micMap.forEach((key, value) {
      final user = value?.user;
      if (key != -1 &&
          user != null
          && user.uid != myUid
          && user.uid != ownerUid
      ) {
        users.add(
          GiftSend2RoomEntity(
            index: key,
            uid: user.uid,
            avatar: user.avatar,
          ),
        );
      }
    });

    //todo 房主可以刷给自己礼物
    // if (myUid != ownerUid) {
      select.add(ownerUid);

      users.insert(
        0,
        GiftSend2RoomEntity(
          index: -1,
          uid: ownerUid,
          avatar: roomCtrl.value['avatar'],
        ),
      );
    // }

    GiftBottomSheet.to(GiftSend2RoomCtrl(roomCtrl.roomUid, select, users));
  }

  void onSettingClick() async {
    final ctrl = RoomCtrl.obj;

    final result = await Get.to(SettingRoomPage(ctrl.value));

    if (result is Map) {
      ctrl.value.addAll(result);
    }
  }

  void onMoreClick(BuildContext context) async {
    final result = await SettingBottomSheet.to();

    switch (result) {
      case '房间背景':
        Scaffold.of(context).openEndDrawer();
        break;
    }
  }

  void onStickersClick() async {
    final result = await Get.showBottomSheet(
      MicStickersBottomSheet(),
      bgColor: AppPalette.sheetDark,
    );

    if (result is StickersInfo) {
      switch (result.type) {
        case 1:
          WsApi.sendStickersMsg(result.name);
          break;
        case 2:
        case 3:
          final ext = result.ext;

          final num = StepTween(begin: ext['min'], end: ext['max']) //
              .transform(Random.secure().nextDouble());

          WsApi.sendStickersGameMsg(
              {'name': result.name, 'type': result.type, 'num': num});
          break;
      }
    }
  }

  void onMessageClick() {
    Get.showBottomSheet(
      MessageListBottomSheet(),
      isScrollControlled: false,
    );
  }
}
