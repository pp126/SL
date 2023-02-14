import 'package:app/common/theme.dart';
import 'package:app/event/moment_event.dart';
import 'package:app/net/api.dart';
import 'package:app/net/ws_help.dart';
import 'package:app/store/gift_ctrl.dart';
import 'package:app/store/wallet_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/common/money_icon.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/mine/wallet/wallet_page.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class GiftBottomSheet extends StatefulWidget {
  final _GiftSendCtrl userCtrl;

  GiftBottomSheet._(this.userCtrl);

  static to(_GiftSendCtrl ctrl) {
    Get.showBottomSheet(
      GiftBottomSheet._(ctrl),
      bgColor: AppPalette.sheetDark,
      safeAreaMinimum: EdgeInsets.only(bottom: 20),
    );

    Get.find<WalletCtrl>().doRefresh();
  }

  @override
  _GiftBottomSheetState createState() => _GiftBottomSheetState();
}

class _GiftBottomSheetState extends State<GiftBottomSheet>
    with SingleTickerProviderStateMixin {
  final numNotifier = ValueNotifier(1);
  final giftNotifier = ValueNotifier<Map>(null);
  final selectTab = RxInt(0);

  TabController ctrl;
  Map<String, Widget> tabs;

  @override
  void initState() {
    super.initState();
    Get.put(PackageGiftCtrl(), permanent: true);

    tabs = {
      '礼物': GetBuilder<GiftCtrl>(
        autoRemove: false,
        builder: (ctrl) {
          final showType = {2, 5};

          final data = ctrl.value.values //
              .where((it) => showType.contains(it['giftType']))
              .toList(growable: false);

          data.sort((a, b) => a['goldPrice'].compareTo(b['goldPrice']));

          return _GiftListView(data, giftNotifier);
        },
      ),
      '背包': GetBuilder<PackageGiftCtrl>(
        builder: (ctrl) => _GiftListView(ctrl.value, giftNotifier),
      ),
    };

    ctrl = TabController(vsync: this, length: tabs.length) //
      ..addListener(() => selectTab.value = ctrl.index);
  }

  @override
  void dispose() {
    ctrl.dispose();

    Get.delete<PackageGiftCtrl>(force: true);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Spacing.h8,
          SizedBox(
            height: 40,
            child: TabBar(
              isScrollable: true,
              controller: ctrl,
              tabs: tabs.keys
                  .map((it) => Tab(text: '$it'))
                  .toList(growable: false),
            ),
          ),
          $UserView(),
          Expanded(
            child: TabBarView(
              controller: ctrl,
              children: tabs.values.toList(growable: false),
            ),
          ),
          $BottomAction(),
        ],
      ),
    );
  }

  Widget $UserView() {
    return Container(
      height: 56,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text('送给', style: TextStyle(fontSize: 10, color: AppPalette.tips)),
          Expanded(
            child: widget.userCtrl.userView(
              selectTab,
              onClear: clearPacket,
            ),
          ),
        ],
      ),
    );
  }

  Widget $BottomAction() {
    return Container(
      height: 34,
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        children: [
          Obx(() => selectTab.value == 0 ? $WalletView() : $PacksackView()),
          Spacing.exp,
          $NumView(),
          Spacing.w6,
          Material(
            color: AppPalette.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(2), right: Radius.circular(20)),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              child: Container(
                width: 62,
                height: 34,
                alignment: Alignment.center,
                child: Text(
                  '赠送',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
              onTap: () {
                final gift = giftNotifier.value['giftId'];
                if (gift == null) {
                  showToast('请选择一个礼物');
                } else {
                  //TODO 是否ID重复的情况？
                  var num = numNotifier.value;
                  if (num == -1) {
                    num = giftNotifier.value['userGiftPurseNum'];
                  }
                  widget.userCtrl.doSend(
                      gift, num, giftNotifier.value['userGiftPurseNum'],
                      selectTab: selectTab.value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget $WalletView() {
    Widget child = Row(
      children: [
        MoneyIcon(size: 24),
        WalletCtrl.useGold(builder: (it) {
          return Text(
            '$it',
            style: TextStyle(
                fontSize: 14,
                color: Color(0xFFFFCB2F),
                fontWeight: fw$SemiBold),
          );
        }),
        Container(
          width: 56,
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('充值', style: TextStyle(fontSize: 14, color: Colors.white)),
              Spacing.w4,
              Container(
                width: 12,
                height: 12,
                decoration:
                    BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Icon(
                  Icons.keyboard_arrow_right,
                  color: AppPalette.primary,
                  size: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    child = InkWell(
      child: child,
      onTap: () async {
        await Get.to(
          WalletPage(),
          preventDuplicates: false, //TODO BottomSheet跳转页面不会刷新路由
        );

        Get.find<WalletCtrl>().doRefresh();
      },
    );

    return child;
  }

  Widget $PacksackView() => Row(
        children: [
          Text(
            '背包总值',
            style: TextStyle(
                fontSize: 14,
                color: Color(0xFF908DA8),
                fontWeight: fw$SemiBold),
          ),
          Spacing.w8,
          MoneyIcon(size: 24),
          Spacing.w2,
          GetX<PackageGiftCtrl>(
            builder: (ctrl) {
              return Text(
                '${ctrl.hPrice.value}',
                style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFFFCB2F),
                    fontWeight: fw$SemiBold),
              );
            },
          )
        ],
      );

  Widget $NumView() {
    Widget child = Obx(() {
      if (selectTab.value == 0 && numNotifier.value == -1)
        numNotifier.value = 1;
      return NotifierView(numNotifier, (data) {
        String value = '';
        if (data == -1) {
          value = '全部';
        } else if (data == -2) {
          value = '一键清包';
        } else {
          value = '$data';
        }
        return Text(
          value,
          style: TextStyle(fontSize: 14, color: AppPalette.primary),
        );
        // return Text(
        //   '${data == -1 ? '全部' : data}',
        //   style: TextStyle(fontSize: 14, color: AppPalette.primary),
        // );
      });
    });

    child = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [child, Icon(Icons.arrow_drop_up, color: AppPalette.primary)],
    );

    itemBuilder(_) {
      final data = {
        // if (selectTab.value == 1) -2: '一键清包',
        if (selectTab.value == 1) -1: '全部',
        1: '一心一意',
        10: '十全十美',
        66: '一切顺利',
        99: '长长久久',
        188: '要抱抱',
        520: '我爱你',
        1314: '一生一世'
      };

      return data.entries
          .map(
            (it) => PopupMenuItem(
              child: it.key != -1 && it.key != -2
                  ? Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: Text(
                            '${it.key} ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xffFFC22F), fontSize: 12),
                          ),
                        ),
                        Text(
                          it.value,
                          style:
                              TextStyle(color: Color(0xffFFFFFF), fontSize: 12),
                        )
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          it.value,
                          style:
                              TextStyle(color: Color(0xffFFFFFF), fontSize: 12),
                        )
                      ],
                    ),
              value: it.key,
            ),
          )
          .toList(growable: false);
    }

    return PopupMenuButton(
      itemBuilder: itemBuilder,
      // onSelected: (it) => numNotifier.value = it,
      onSelected: (it) {
        if (-2 == it) {
          clearPacket();
        } else {
          numNotifier.value = it;
        }
      },
      color: Color(0xFF363059),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(0)),
      ),
      child: Container(
        width: 77,
        height: 34,
        decoration: ShapeDecoration(
          color: Color(0xFF363059),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(
                left: Radius.circular(20), right: Radius.circular(2)),
          ),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  clearPacket() async {
    List listData = Get.find<PackageGiftCtrl>().value;
    if (listData.length > 0) {
      for (var item in listData) {
        int id = item['giftId'];
        int num = item['userGiftPurseNum'];
        widget.userCtrl.doSend(id, num, num, selectTab: selectTab.value);
      }
      listData.clear();
    } else {
      showToast('您的背白还没有礼品');
    }
  }
}

class _GiftListView extends StatelessWidget {
  final List data;
  final ValueNotifier<Map> notifier;

  _GiftListView(this.data, this.notifier);

  @override
  Widget build(BuildContext context) {
    return NotifierView(notifier, (_) {
      return GridView.count(
        padding: EdgeInsets.symmetric(horizontal: 16),
        crossAxisCount: 4,
        childAspectRatio: 78 / 95,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: data.map(itemBuilder).toList(growable: false),
      );
    });
  }

  Widget itemBuilder(data) {
    final int num = data['userGiftPurseNum'];
    var giftId = notifier != null && notifier.value != null
        ? notifier.value['giftId']
        : null;
    return GestureDetector(
      child: AnimatedContainer(
        duration: kThemeAnimationDuration,
        curve: Curves.ease,
        decoration: ShapeDecoration(
          color: Color(0xFF191535),
          shape: RoundedRectangleBorder(
            side: giftId == data['giftId']
                ? BorderSide(color: Colors.white)
                : BorderSide.none,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: GiftImgState(
                    child: NetImage(data['giftUrl'], width: 40, height: 40),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MoneyIcon(
                        size: 10, type: data['giftType'] == 5 ? '珊瑚' : '海星'),
                    Spacing.w2,
                    Text(
                      '${data['goldPrice']}',
                      style: TextStyle(fontSize: 10, color: Color(0xFFFFCB2F)),
                    ),
                  ],
                ),
                Text(
                  data['giftName'],
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ],
            ),
            Column(
              children: [
                if (data['hasLatest'] ?? false) '最新',
                if (data['hasEffect'] ?? false) '特效',
              ].map($Tag).toList(growable: false),
            ),
            if (num > 0)
              Positioned(
                right: 8,
                child: Text('×$num',
                    style: TextStyle(fontSize: 10, color: Colors.white)),
              ),
          ],
        ),
      ),
      onTap: () => notifier.value = data,
    );
  }

  Widget $Tag(String name) {
    Tuple2 colors;

    switch (name) {
      case '最新':
        colors = Tuple2(Color(0xFFFFBC79), Color(0xFFFF7070));
        break;
      case '特效':
        colors = Tuple2(AppPalette.pink, AppPalette.primary);
        break;
    }

    return Container(
      width: 26,
      height: 13,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        shape: StadiumBorder(),
        gradient: LinearGradient(colors: colors.toList(growable: false).cast()),
      ),
      child: Text(
        name,
        style: TextStyle(fontSize: 8, color: Colors.white),
      ),
    );
  }
}

abstract class _GiftSendCtrl {
  Widget userView(RxInt selectTab, {Function() onClear});

  Future doSend(int giftID, int giftNum, int giftCount, {int selectTab: -1});

  Future _pay(Future api) async {
    final result = await api;

    final int useGold = result['useGiftPurseGold'];

    if (useGold > 0) {
      Bus.send(CMD.gold_change, -useGold);
    } else {
      Bus.send(CMD.package_gift_change, result);
    }

    return result;
  }
}

//动态送礼物
class GiftSend2MomentCtrl extends _GiftSendCtrl {
  final Map user;
  final int dynamicMsgId;

  GiftSend2MomentCtrl(this.user, this.dynamicMsgId);

  @override
  Widget userView(RxInt selectTab, {Function() onClear}) {
    return Row(
      children: [
        Spacing.w6,
        AvatarView(
          url: user['avatar'],
          size: 26,
          side: BorderSide(color: AppPalette.txtWhite),
        ),
      ],
    );
  }

  @override
  doSend(int giftID, int giftNum, int giftCount, {int selectTab: -1}) async {
    await simpleSub(
      _pay(
          Api.Gift.sendTypeMonment(user['uid'], giftID, giftNum, dynamicMsgId)),
      msg: '赠送成功',
      callback: () {
        Bus.fire(MomentCommentEvent());
        Get.back();
      },
    );
  }
}

class GiftSend2UserCtrl extends _GiftSendCtrl {
  final Map user;

  GiftSend2UserCtrl(this.user);

  @override
  Widget userView(RxInt selectTab, {Function() onClear}) {
    return Row(
      children: [
        Spacing.w6,
        AvatarView(
          url: user['avatar'],
          size: 26,
          side: BorderSide(color: AppPalette.txtWhite),
        ),
      ],
    );
  }

  @override
  doSend(int giftID, int giftNum, int giftCount, {int selectTab: -1}) async {
    await simpleSub(
      _pay(Api.Gift.send(user['uid'], giftID, giftNum)),
      msg: '赠送成功',
      callback: Get.back,
    );
  }
}

//房间送礼物
class GiftSend2RoomCtrl extends _GiftSendCtrl {
  final int roomUid;
  final RxSet<int> select;
  final List<GiftSend2RoomEntity> micMap;

  GiftSend2RoomCtrl(this.roomUid, this.select, this.micMap);

  @override
  Widget userView(RxInt selectTab, {Function() onClear}) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: _createUserView(),
          ),
        ),
        Obx(
          () => Visibility(
            visible: selectTab.value == 1,
            child: Padding(
              padding: EdgeInsets.only(right: 10),
              child: Material(
                color: Color(0xFF363059),
                shape: StadiumBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  child: Container(
                    width: 60,
                    height: 26,
                    alignment: Alignment.center,
                    child: Text('一键清包',
                        style: TextStyle(fontSize: 10, color: Colors.white)),
                  ),
                  onTap: () => onClear?.call(),
                ),
              ),
            ),
          ),
        ),
        Material(
          color: Color(0xFF363059),
          shape: StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            child: Container(
              width: 60,
              height: 26,
              alignment: Alignment.center,
              child: Text('全麦',
                  style: TextStyle(fontSize: 10, color: Colors.white)),
            ),
            onTap: () => micMap.forEach((it) => select.add(it.uid)),
          ),
        ),
      ],
    );
  }

  Widget _createUserView() {
    Widget $PositionView(String title, List<Color> colors) {
      return Container(
        decoration: ShapeDecoration(
          shape: StadiumBorder(),
          gradient:
              LinearGradient(colors: colors.take(2).toList(growable: false)),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(fontSize: 10, color: colors[2]),
        ),
      );
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: micMap.length,
      itemBuilder: (_, i) {
        final item = micMap[i];
        final uid = item.uid;

        return Center(
          child: Obx(() {
            var side;
            var onTap;

            if (select.contains(uid)) {
              side = BorderSide(width: (1.5*2), color: AppPalette.pink);
              onTap = () => select.remove(uid);
            } else {
              side = BorderSide.none;
              onTap = () => select.add(uid);
            }

            Widget child = AvatarView(url: item.avatar, size: (26*1.5), side: side);

            if (item.index != null) {
              child = Stack(
                alignment: Alignment.topCenter,
                children: [
                  child,
                  item.index == -1 //
                      ? Positioned(
                          width: 30,
                          height: 15,
                          bottom: 0,
                          child: $PositionView(
                            '房主',
                            [
                              Color(0xFFA882FF),
                              Color(0xFF645BFF),
                              Colors.white
                            ],
                          ),
                        )
                      : Positioned(
                          width: 12,
                          height: 8,
                          bottom: 0,
                          child: $PositionView(
                            '${item.index + 1}',
                            [
                              Color(0xFFCBC7E2),
                              Color(0xFFCBC7E2),
                              AppPalette.primary
                            ],
                          ),
                        ),
                ],
              );
            }

            child = InkResponse(child: child, onTap: onTap);

            return child;
          }),
        );
      },
      separatorBuilder: (_, __) => Spacing.w6,
    );
  }

  @override
  doSend(int giftID, int giftNum, int giftCount, {int selectTab: -1}) async {
    if (giftNum == 0) {
      showToast('请选择礼物');
      return;
    }
    final users = select.toSet();
    final micAllCount = micMap.length;
    if (users.length == 0) {
      showToast('请选择收礼物的人');
      return;
    }

    switch (users.length) {
      case 1:
        await simpleTry(
          () async {
            WsApi.sendGift(await _pay(
                Api.Gift.sendGift(roomUid, users.first, giftID, giftNum)));
            showToast('赠送成功');
          },
        );
        break;
      default:
        if (selectTab == 0 || giftCount >= (giftNum * users.length)) {
          await simpleTry(
            () async {
              //区分送单麦还是全麦
              if (users.length != micAllCount) {
                for (var user in users) {
                  WsApi.sendGift(await _pay(
                      Api.Gift.sendGift(roomUid, user, giftID, giftNum)));
                }
              } else {
                WsApi.sendWholeMicro(await _pay(
                    Api.Gift.sendWholeMicro(roomUid, users, giftID, giftNum)));
              }
              showToast('赠送成功');
            },
          );
        } else if (giftCount == giftNum && giftCount > users.length) {
          List userIds = users.toList();
          int num = users.length;
          int mean = giftNum ~/ num;
          int mantissa = giftNum - (mean * num);

          await simpleTry(
            () async {
              //区分送单麦还是全麦
              if (users.length != micAllCount) {
                for (var user in users) {
                  int meanGiftNum = mean;
                  if (mantissa > 0) {
                    meanGiftNum++;
                    mantissa--;
                  }
                  WsApi.sendGift(await _pay(
                      Api.Gift.sendGift(roomUid, user, giftID, meanGiftNum)));
                }
              } else {
                WsApi.sendWholeMicro(await _pay(
                    Api.Gift.sendWholeMicro(roomUid, users, giftID, mean)));
                for (int i = 0, j = mantissa; i < j; i++) {
                  WsApi.sendGift(await _pay(
                      Api.Gift.sendGift(roomUid, userIds[i], giftID, 1)));
                }
              }
              showToast('赠送成功');
            },
          );
        } else {
          showToast('个数不足赠送所选人数');
        }
    }
  }
}

class GiftSend2RoomEntity {
  final int uid;
  final String avatar;
  final int index;

  GiftSend2RoomEntity({this.uid, this.avatar, this.index});
}
