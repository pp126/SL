import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/store/room_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/common/money_icon.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/mine/page/user_page.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/level_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RoomRankPage extends StatefulWidget {
  final int roomUid;

  RoomRankPage(this.roomUid);

  @override
  _RoomRankPageState createState() => _RoomRankPageState();
}

class _RoomRankPageState extends State<RoomRankPage> {
  final tabs = {'财富榜': 1, '魅力榜': 2};
  RxMap oneData = RxMap({});
  RxMap twoData = RxMap({});
  RxMap threeData = RxMap({});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Theme(
        data: themeDark,
        child: Scaffold(
          appBar: xAppBar(
            xAppBar$TabBar(
              tabs.keys.map((it) => Tab(text: it)).toList(growable: false),
              labelColor: Color(0xffFFCB2F),
            ),
          ),
          backgroundColor: AppPalette.dark,
          body: TabBarView(children: tabs.entries.map(createItem).toList(growable: false)),
        ),
      ),
    );
  }

  Widget createItem(MapEntry data) {
    final tabs = {'日榜': 1, '周榜': 2, '总榜': 3};

    return Column(
      children: [
        Stack(
          children: [
            AspectRatio(
              aspectRatio: 375 / 276.0,
              child: Image.asset(IMG.$('房间排行背景'), scale: 3, fit: BoxFit.fill, alignment: Alignment.topCenter),
            ),
            Positioned(
              left: Get.width / 2 - 40,
              top: 5,
              child: Obx(() {
                return _itme(1, oneData, 68, 9.5);
              }),
            ),
            Positioned(
              left: Get.width * (61 / 375),
              top: 49,
              child: Obx(() {
                return _itme(2, twoData, 56.4, 7.2);
              }),
            ),
            Positioned(
              left: Get.width * (250 / 375),
              top: 83,
              child: Obx(() {
                return _itme(3, threeData, 51.8, 4.9, positionedL: 3.2);
              }),
            ),
          ],
        ),
        Expanded(
          child: Transform.translate(
            offset: Offset(0, -16),
            child: Material(
              color: AppPalette.dark,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: DefaultTabController(
                length: tabs.length,
                child: Column(
                  children: [
                    Spacing.h6,
                    xAppBar$TabBar(
                      tabs.keys.map((it) => Tab(text: it)).toList(growable: false),
                      alignment:  Alignment.topLeft,
                    ),
                    Expanded(
                      child: TabBarView(
                        children: tabs.values
                            .map((dataType) => RoomRankView(widget.roomUid, data.value, dataType, (value) {
                                  if (value != null) {
                                    final one = xListStr(value, 0, defaultStr: {});
                                    final two = xListStr(value, 1, defaultStr: {});
                                    final three = xListStr(value, 2, defaultStr: {});
                                    Future.delayed(Duration(milliseconds: 200), () {
                                      oneData.assignAll(one);
                                      twoData.assignAll(two);
                                      threeData.assignAll(three);
                                    });
                                  }
                                }))
                            .toList(growable: false),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  _itme(int i, Map data, double avatarSize, double positioned, {double positionedL}) {
    return data != null && data.isNotEmpty
        ? Column(
            children: [
              Stack(
                children: [
                  Image.asset(IMG.$('房间排行榜头$i'), scale: 3, fit: BoxFit.fill),
                  Positioned(
                    top: positioned,
                    left: positionedL ?? positioned,
                    child: InkResponse(
                      onTap: () => Get.to(UserPage(uid: xMapStr(data, 'ctrbUid', defaultStr: null))),
                      child: AvatarView(url: data['avatar'] ?? '', size: avatarSize),
                    ),
                  ),
                ],
              ),
              Spacing.h2,
              Text(
                data['nick'] ?? '',
                style: TextStyle(fontSize: 13, color: AppPalette.txtWhite),
              ),
              Row(
                children: [
                  MoneyIcon(size: 13),
                  Text(
                    '${data['sumGold']}',
                    style: TextStyle(fontSize: 13, color: AppPalette.txtGold),
                  ),
                ],
              ),
            ],
          )
        : SizedBox();
  }
}

class RoomRankView extends StatelessWidget {
  final int roomUid, type, dataType;
  final ValueChanged<List> firstData;
  final _key = GlobalKey<XFutureBuilderState>();

  RoomRankView(this.roomUid, this.type, this.dataType, this.firstData);

  @override
  Widget build(BuildContext context) {
    return XFutureBuilder(
      key: _key,
      futureBuilder: () => Api.Room.rank(roomUid, type, dataType),
      onData: (data) {
        final one = xListStr(data, 0, defaultStr: null);
        final two = xListStr(data, 1, defaultStr: null);
        final three = xListStr(data, 2, defaultStr: null);
        List list = [];
        if (one != null) {
          one['dataType'] = dataType;
          list.add(one);
        }
        if (two != null) {
          two['dataType'] = dataType;
          list.add(two);
        }
        if (three != null) {
          three['dataType'] = dataType;
          list.add(three);
        }
        firstData(list);

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20),
          itemCount: data.length,
          itemExtent: 48.0 + 30,
          itemBuilder: (_, i) => createItem(i + 1, data[i]),
        );
      },
      onEmpty: ({msg}) {
        firstData([]);
        return TipsView(
          _key.currentState.doRefresh,
          message: msg,
          imageSize: 250,
          noImage: true,
        );
      },
      tipsSize: 250,
    );
  }

  Widget createItem(int index, Map data) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          child: index <= 3
              ? SvgPicture.asset(SVG.$('home/rank/crown_$index'))
              : Text(
                  '$index',
                  style: TextStyle(fontSize: 16, color: AppPalette.tips, fontWeight: fw$SemiBold),
                ),
        ),
        Spacing.w16,
        InkResponse(
          onTap: () => Get.to(UserPage(uid: xMapStr(data, 'ctrbUid', defaultStr: null))),
          child: AvatarView(url: data['avatar'], size: 48),
        ),
        Spacing.w10,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                data['nick'],
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
              Spacing.h4,
              Row(
                children: [
                  SvgPicture.asset(SVG.$('mine/性别_${data['gender']}')),
                  WealthIcon(data: data, height: 16),
                  CharmIcon(data: data),
                ].separator(Spacing.w4),
              ),
            ],
          ),
        ),
        Row(
          children: [
            MoneyIcon(size: 20),
            Text(
              '${data['sumGold']}',
              style: TextStyle(fontSize: 14, color: Color(0xFF7C66FF), fontWeight: fw$SemiBold),
            ),
          ],
        ),
      ],
    );
  }
}

class SettingRoomRankPage extends StatelessWidget {
  final int roomID;

  SettingRoomRankPage(this.roomID);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar('设置榜单'),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GetX<RoomCtrl>(builder: (ctrl) {
          final status = ctrl.value['billboardStatus'] ?? 0;

          return Column(
            children: {'仅房主可见': 0, '管理员可见': 1, '所有人可见': 2}
                .entries
                .map(
                  (it) => RadioListTile(
                    title: Text(it.key),
                    value: it.value,
                    groupValue: status,
                    onChanged: (it) async {
                      ctrl.value['billboardStatus'] = it;

                      simpleTry(() => Api.Room.updateRoom(roomID, info: {'billboardStatus': it}));
                    },
                  ),
                )
                .toList(growable: false),
          );
        }),
      ),
    );
  }
}
