import 'package:app/common/theme.dart';
import 'package:app/event/moment_event.dart';
import 'package:app/event/room_event.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/ui/home/widgets/home_card.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/room/room_page.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/customer/app_roration_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeIndexFollowView extends StatefulWidget {
  @override
  _HomeIndexFollowViewState createState() => _HomeIndexFollowViewState();
}

class _HomeIndexFollowViewState extends State<HomeIndexFollowView> {
  final _historyKey = GlobalKey<XFutureBuilderState>();
  final _followKey = GlobalKey<XFutureBuilderState>();

  @override
  void initState() {
    super.initState();
    Bus.on<RoomInEvent>((data) {
      refreshHistory();
      refreshFollow();
    });
  }

  Future<List> requestRoomData() {
    return Api.Home.getRoomAttentionByUid(PageNum());
  }

  Future<List> requestForHistoryData() {
    return Api.Home.historyList();
  }

  refreshHistory() {
    _historyKey.currentState.doRefresh();
  }

  refreshFollow() {
    _followKey.currentState.doRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(padding: EdgeInsets.only(top: 10)),
        XFutureBuilder<List>(
          key: _followKey,
          futureBuilder: requestRoomData,
          onData: (data) {
            final tabs = (data ?? []).toList().take(10).toList();
            return SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: RoomCard.gridDelegate,
                delegate: SliverChildBuilderDelegate((_, i) => RoomCard(tabs[i]), childCount: tabs.length),
              ),
            );
          },
          sliverToBox: true,
          tipsSize: 100,
        ),
        SliverPadding(padding: EdgeInsets.only(top: 20)),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(child: _Recommend()),
        ),
        SliverPadding(padding: EdgeInsets.only(top: 31)),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
              child: _FootprintTitle(
            clearAll: onClearTap,
          )),
        ),
        SliverPadding(padding: EdgeInsets.only(bottom: 20)),
        XFutureBuilder<List>(
          key: _historyKey,
          futureBuilder: requestForHistoryData,
          onData: (data) {
            final tabs = data;
            return SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: RoomCard.gridDelegate,
                delegate: SliverChildBuilderDelegate((_, i) => RoomCard(tabs[i]), childCount: tabs.length),
              ),
            );
          },
          sliverToBox: true,
          tipsSize: 100,
        ),
        SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }

  ///清空足迹
  onClearTap() {
    simpleSub(Api.Home.clearRoomHistory(), msg: '清空成功', callback: () {
      refreshHistory();
    });
  }
}

class _FootprintTitle extends StatelessWidget {
  final VoidCallback clearAll;

  _FootprintTitle({this.clearAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(SVG.$('home/足迹')),
        Text('我的足迹', style: TextStyle(color: AppPalette.dark, fontSize: 16, fontWeight: FontWeight.w600)),
        Spacing(),
        Row(children: [
          SvgPicture.asset(SVG.$('home/删除')),
          SizedBox(width: 2),
          Text('清空', style: TextStyle(color: AppPalette.primary, fontSize: 10, height: 1)),
        ]).toBtn(24, AppPalette.txtWhite,
            padding: EdgeInsets.symmetric(horizontal: 16), margin: EdgeInsets.only(right: 0), onTap: () {
          if (clearAll != null) {
            clearAll();
          }
        }),
      ],
    );
  }
}

class _Recommend extends StatefulWidget {
  @override
  __RecommendState createState() => __RecommendState();
}

class __RecommendState extends State<_Recommend> with SingleTickerProviderStateMixin {
  int pageNum = 1;
  AnimationController _animationController;
  final _key = GlobalKey<XFutureBuilderState>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<List> requestForData() {
    return Api.Home.getRoomRecommendList(PageNum(index: pageNum, size: 3));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 343,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                IMG.$('推荐关注底板'),
                fit: BoxFit.fill,
                width: double.infinity,
                height: 60,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text('惊鸿一瞥 浮生若梦',
                        style: TextStyle(color: AppPalette.primary, fontSize: 15, fontWeight: fw$Regular)),
                  ),
                  RotationIconText(
                    '换一批',
                    icon: SvgPicture.asset(SVG.$('home/刷新')),
                    textPadding: EdgeInsets.only(
                      left: 6,
                    ),
                    padding: EdgeInsets.all(0),
                    gravity: Gravity.LEFT,
                    height: 30,
                    style: TextStyle(color: AppPalette.primary, fontSize: 10, height: 1),
                    animationController: _animationController,
                  ).toBtn(
                    30,
                    Colors.white,
                    width: 80,
//                    padding: EdgeInsets.symmetric(horizontal: 10),
                    margin: EdgeInsets.only(right: 16),
                    onTap: () {
                      setState(() {
                        pageNum += 1;
                        _animationController.repeat();
                        _key.currentState.doRefresh();
                      });
                    },
                  ),
                ],
              )
            ],
          ),
          XFutureBuilder<List>(
            key: _key,
            futureBuilder: requestForData,
            onData: (data) {
              Future.delayed(Duration(milliseconds: 1000), () {
                _animationController.reset();
              });
              return Container(
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
                  ),
                  child: Column(
                    children: data.map((item) {
                      return _RecommendItem(item, _key);
                    }).toList(),
                  ));
            },
            onComplete: (data) {
              if ((data is Map && data.isEmpty) || (data is List && data.isEmpty)) {
                pageNum = 0;
              }
            },
          ),
        ],
      ),
    );
  }
}

class _RecommendItem extends StatelessWidget {
  final data;
  GlobalKey<XFutureBuilderState> listkey;

  _RecommendItem(this.data, this.listkey);

  RxBool isFollow = false.obs;

  @override
  Widget build(BuildContext context) {
    var uid = xMapStr(data, 'uid');
    isFollow.value = xMapStr(data, 'isFans', defaultStr: false); //是否关注
    var tagImage = xMapStr(data, 'tagPict');

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => RoomPage.to(uid),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 14),
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            RectAvatarView(
              borderRadius: BorderRadius.circular(6),
              url: data['avatar'],
              size: 62,
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(xMapStr(data, 'title'), style: TextStyle(color: AppPalette.dark, fontSize: 15)),
                SizedBox(height: 10),
                Row(
                  children: [
                    NetImage(tagImage, width: 30, height: 15, fit: BoxFit.fill),
                    SizedBox(width: 8),
                    Text(
                      'ID:${xMapStr(data, 'roomId')}',
                      style: TextStyle(color: AppPalette.primary, fontSize: 10),
                    ).toTagView(15, AppPalette.txtWhite, radius: 100, padding: EdgeInsets.symmetric(horizontal: 8)),
                  ],
                )
              ],
            ),
            Spacing(),
            Obx(() => Text(isFollow.value ? '已关注' : '关注',
                    style:
                        TextStyle(color: isFollow.value ? AppPalette.primary : Colors.white, fontSize: 10, height: 1))
                .toBtn(24, isFollow.value ? AppPalette.txtWhite : AppPalette.primary, width: 57, onTap: onFollowTap)),
          ],
        ),
      ),
    );
  }

  ///关注用户
  onFollowTap() {
    var roomId = xMapStr(data, 'roomId', defaultStr: null);
    simpleSub(Api.Room.like(roomId, !isFollow.value), callback: () {
      Bus.fire(MomentEvent());
      Bus.fire(RoomInEvent());
      data['isFans'] = !isFollow.value;
      isFollow.value = !isFollow.value;
    }, msg: isFollow.value ? '取消关注' : '关注成功');
  }
}
