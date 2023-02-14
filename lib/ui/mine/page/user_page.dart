import 'dart:async';

import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/tools/view.dart';
import 'package:app/ui/common/svga_icon.dart';
import 'package:app/ui/home/widgets/tab_bar_persistent_header_delegate.dart';
import 'package:app/ui/message/chat/chat_page.dart';
import 'package:app/ui/mine/account/account_page.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/mine/page/user_honour_page.dart';
import 'package:app/ui/mine/page/user_moment_page.dart';
import 'package:app/ui/moment/moment_action_tap.dart';
import 'package:app/ui/room/room_page.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/customer/app_swiper_pagination.dart';
import 'package:app/widgets/customer/app_text_button.dart';
import 'package:app/widgets/customer/photo_view.dart';
import 'package:app/widgets/future_builder.dart';
import 'package:app/widgets/level_view.dart';
import 'package:app/widgets/spacing.dart';
import 'package:app/widgets/waiting_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_sound/flutter_sound.dart';

///用户主页
class UserPage extends StatefulWidget {
  final int uid;

  UserPage({
    this.uid,
  });

  @override
  UserPageState createState() => new UserPageState();
}

class UserPageState extends State<UserPage> {
  bool isShowBlackTitle = false;
  bool isSelf = false;
  Map tabs;
  var userInfo;
  final _key = GlobalKey<XFutureBuilderState>();

  bool isLike = false;

  FlutterSoundPlayer _mPlayer = FlutterSoundPlayer();
  String _audioUrl;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();

    isSelf = widget.uid == OAuthCtrl.obj.uid;
    tabs = {
      '资料': 1,
      '荣耀': 2,
    };
    getFollowData();
    _mPlayer.openPlayer();
  }

  @override
  void dispose() {
    stopPlayer();
    // Be careful : you must `close` the audio session when you have finished with it.
    _mPlayer.closePlayer();
    _mPlayer = null;

    super.dispose();
  }

  Future<Map> getData() {
    return Api.User.info(widget.uid);
  }

  ///获取关注信息
  getFollowData() {
    if (!isSelf) {
      Api.User.isLike(widget.uid).then((value) {
        if (value != null) {
          setState(() {
            isLike = value;
          });
        }
      });
    }
  }

  //判断滚动改变透明度
  void _onScroll(offset) {
    if (offset > 100) {
      setState(() {
        isShowBlackTitle = true;
      });
    } else {
      setState(() {
        isShowBlackTitle = false;
      });
    }
  }

  void play() async {
    await _mPlayer.startPlayer(
        fromURI: _audioUrl,
        codec: Codec.aacADTS,
        whenFinished: () {
          setState(() {
            _isPlaying = false;
          });
        });
    setState(() {
      _isPlaying = true;
    });
  }

  Future<void> stopPlayer() async {
    if (_mPlayer != null) {
      await _mPlayer.stopPlayer();
    }
  }

  @override
  Widget build(BuildContext context) {
    Color color = isShowBlackTitle ? Colors.black : Colors.white;
    var name = xMapStr(userInfo, 'nick');
    var avatar = xMapStr(userInfo, 'avatar');

    return Scaffold(
      backgroundColor: Colors.white,
      body: NotificationListener(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollUpdateNotification &&
              scrollNotification.depth == 0) {
            //滚动并且是列表滚动的时候
            _onScroll(scrollNotification.metrics.pixels);
          }
          return true;
        },
        child: Stack(
          children: <Widget>[
            XFutureBuilder<Map>(
              key: _key,
              futureBuilder: getData,
              onData: (data) {
                userInfo = data;
                _audioUrl = xMapStr(userInfo, 'voiceUrl');
                return DefaultTabController(
                  length: tabs.length,
                  child: NestedScrollView(
                    headerSliverBuilder:
                        (BuildContext context, bool innerBoxIsScrolled) {
                      final tabBar = Material(
                        color: Colors.white,
                        child: Row(
                          children: [
                            Expanded(
                              child: xAppBar$TabBar(
                                tabs.keys
                                    .map((it) => Tab(text: it))
                                    .toList(growable: false),
                                alignment: Alignment.bottomLeft,
                              ),
                            ),
                            Spacing.w4,
//                            Text(
//                              'ta的房间',
//                              style: TextStyle(
//                                  fontSize: 10, color: Colors.white, height: 1),
//                            ).toBtn(20, AppPalette.primary, onTap: () {
//                              RoomPage.to(widget.uid);
//                            }),
                            isSelf
                                ? SizedBox()
                                : Text(
                                    isLike ? '已关注' : '关注',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        height: 1),
                                  ).toBtn(
                                    30,
                                    isLike
                                        ? AppPalette.hint
                                        : AppPalette.primary,
                                    width: 60, onTap: () {
                                    onFollowTap();
                                  }),
                            Spacing.w6,
                            isSelf
                                ? SizedBox()
                                : Text(
                                    '聊天',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        height: 1),
                                  ).toBtn(30, AppPalette.pink, width: 60,
                                    onTap: () {
                                    ChatPage.to(name, avatar, '${widget.uid}');
                                  }),
//                            isSelf
//                                ? SizedBox()
//                                : Text(
//                                    '去找ta',
//                                    style: TextStyle(
//                                        fontSize: 10,
//                                        color: Colors.white,
//                                        height: 1),
//                                  ).toBtn(20, AppPalette.pink,
//                                    margin: const EdgeInsets.only(left: 10),
//                                    onTap: () {
//                                    WaitingCtrl.obj.show();
//                                    Api.User.roomInfo(widget.uid).then((value) {
//                                      var roomUid = xMapStr(value, 'uid',
//                                          defaultStr: null);
//                                      if (roomUid != null) {
//                                        RoomPage.to(roomUid);
//                                      } else {
//                                        showToast('对方不在房间！');
//                                      }
//                                    }).catchError((e) {
//                                      showToast('对方不在房间！');
//                                    }).whenComplete(
//                                        () => WaitingCtrl.obj.hidden());
//                                  }),
                            Spacing.w16,
                          ],
                        ),
                      );

                      return [
                        SliverAppBar(
                          brightness: isShowBlackTitle
                              ? Brightness.light
                              : Brightness.dark,
                          leading: Navigator.canPop(context)
                              ? InkResponse(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Icon(
                                    Icons.arrow_back_ios,
                                    color: color,
                                  ),
                                )
                              : null,
                          title: isShowBlackTitle ? Text('主页') : Text(''),
                          centerTitle: true,
                          pinned: true,
                          floating: false,
                          snap: false,
                          primary: true,
                          expandedHeight: 280.0,
                          backgroundColor: Colors.white,
                          elevation: 0,
                          //是否显示阴影，直接取值innerBoxIsScrolled，展开不显示阴影，合并后会显示
                          forceElevated: innerBoxIsScrolled,
                          actions: <Widget>[
                            isSelf
                                ? '编辑'.toTxtActionBtn2(
                                    onPressed: () => Get.to(AccountPage()).then(
                                        (value) => setState(() =>
                                            _key.currentState.doRefresh())))
                                : MoreItem(
                                    uid: widget.uid,
                                    color: color,
                                  ),
                            Spacing.w16,
                          ],

                          flexibleSpace: FlexibleSpaceBar(
                            collapseMode: CollapseMode.pin,
                            background: _buildTopView(),
                          ),
                        ),
                        SliverPersistentHeader(
                            delegate:
                                TabBarPersistentHeaderDelegate(tabBar, 44),
                            pinned: true),
                      ];
                    },
                    body: TabBarView(
                      children: tabs.values.map((it) {
                        return it == 1
                            ? UserMomentPage(
                                uid: widget.uid,
                                userInfo: userInfo,
                              )
                            : UserHonourPage(
                                uid: widget.uid,
                                userInfo: userInfo,
                              );
                      }).toList(growable: false),
                    ),
                  ),
                );
              },
            ),
//            isSelf ? new Container() : _detailBottom(),
          ],
        ),
      ),
    );
  }

  Widget _detailBottom() {
    var name = xMapStr(userInfo, 'nick');
    var avatar = xMapStr(userInfo, 'avatar');
    return Positioned(
      left: 0,
      right: 0,
      bottom: 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Material(
            elevation: 4,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              topRight: Radius.circular(2),
              bottomRight: Radius.circular(2),
            ),
            child: AppTextButton(
              width: 136,
              height: 40,
              bgColor: isLike ? AppPalette.txtWhite : AppPalette.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                topRight: Radius.circular(2),
                bottomRight: Radius.circular(2),
              ),
              title: Text(
                isLike ? '已关注' : '关注',
                style: TextStyle(
                    fontSize: 14,
                    color: isLike ? AppPalette.primary : Colors.white),
              ),
              onPress: onFollowTap,
            ),
          ),
          Spacing.w4,
          Material(
            elevation: 4,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(2),
              bottomLeft: Radius.circular(2),
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            child: AppTextButton(
              width: 136,
              height: 40,
              bgColor: AppPalette.txtWhite,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(2),
                bottomLeft: Radius.circular(2),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              title: Text(
                '聊天',
                style: TextStyle(fontSize: 14, color: AppPalette.primary),
              ),
              onPress: () {
                ChatPage.to(name, avatar, widget.uid);
              },
            ),
          ),
        ],
      ),
    );
  }

  _buildTopView() {
    var name = xMapStr(userInfo, 'nick');
    var avatar = xMapStr(userInfo, 'avatar');
    var erbanNo = xMapStr(userInfo, 'erbanNo');
    bool isMan = xMapStr(userInfo, 'gender') == 1;
    final data = [
      [xMapStr(userInfo, 'followNum', defaultStr: 0).toString(), '关注'],
      [xMapStr(userInfo, 'fansNum', defaultStr: 0).toString(), '粉丝'],
//      [xMapStr(userInfo, 'liveness', defaultStr: 0).toString(), '活跃'],
    ];
    var photos = xMapStr(userInfo, 'privatePhoto', defaultStr: []);
    return Stack(
      children: [
        _PhotoView(photos),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(16, 50, 16, 10),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                )),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                              SVG.$(isMan ? 'mine/性别_1' : 'mine/性别_2')),
                          Spacing.w4,
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            height: 20,
                            decoration: BoxDecoration(
                                color: AppPalette.hint,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0))),
                            child: Text(
                              'ID:$erbanNo',
                              style: TextStyle(
                                  color: AppPalette.primary, fontSize: 10.0),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 15,
                              height: 15,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(7.5)),
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xffFFCB2F),
                                        Color(0xffFF982F)
                                      ])),
                              child: Text(
                                '${userInfo['experLevel']}',
                                style: TextStyle(
                                    fontSize: 6.0, color: AppPalette.txtWhite),
                              ),
                            ),
                            Spacing.w4,
                            WealthIcon(data: userInfo),
                            Spacing.w4,
                            CharmIcon(data: userInfo),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Spacing.exp,
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      for (final it in data)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                it[0],
                                style: TextStyle(
                                    fontSize: 14,
                                    color: AppPalette.dark,
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                it[1],
                                style: TextStyle(
                                    fontSize: 10, color: AppPalette.hint),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        Positioned(
          left: 20,
          bottom: 63,
          child: Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(60),
                )),
            child: AvatarView(url: avatar),
          ),
        ),
        Positioned(
          left: 118,
          bottom: 107,
          child: Container(
            child: Text(
              name,
              style: TextStyle(
                  fontSize: 16,
                  color: AppPalette.txtWhite,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
        _audioUrl == null || _audioUrl.isEmpty
            ? SizedBox()
            : Positioned(
                right: 20,
                bottom: 85,
                child: Container(
                  width: 100,
                  height: 38,
                  child: MaterialButton(
                    padding: const EdgeInsets.all(0.0),
                    color: AppPalette.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(19))),
                    onPressed: () {
                      playerRecord();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        !_isPlaying
                            ? Container(
                                width: 28,
                                height: 24,
                                child: Image.asset(IMG.$('mic/喇叭')),
                              )
                            : Container(
                                width: 28,
                                height: 24,
                                child: SVGAImg(
                                  assets: SVGA.$('喇叭'),
                                )),
                        Container(
                          margin: const EdgeInsets.only(left: 3),
                          child: Text(
                            'ta说',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  playerRecord() {
    if (null != _audioUrl) {
      play();
    }
  }

  ///关注用户
  onFollowTap() {
    simpleSub(
        Api.Home.followUser(
          likedUid: widget.uid,
          isFollow: isLike,
        ), callback: () {
      OAuthCtrl.obj.doRefresh();
      setState(() {
        var fansNum =
            xMapStr(userInfo, 'fansNum', defaultStr: 0) + (isLike ? -1 : 1);
        if (fansNum < 0) fansNum = 0;
        userInfo['fansNum'] = fansNum;
        isLike = !isLike;
      });
    }, msg: isLike ? '取消关注' : '关注成功');
  }
}

class _PhotoView extends StatelessWidget {
  final List photos;

  _PhotoView(this.photos);

  @override
  Widget build(BuildContext context) {
    bool isEmpty = photos == null || photos.isEmpty;
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: isEmpty
          ? Container(
              color: Color(0xffCBC8DC),
              padding: EdgeInsets.only(bottom: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '没有图片呢',
                    style: TextStyle(fontSize: 14, color: Color(0xffF1EEFF)),
                  ),
                  Text(
                    '快提醒ta上传',
                    style: TextStyle(fontSize: 12, color: Color(0x80F1EEFF)),
                  ),
                ],
              ),
            )
          : Swiper(
              itemBuilder: (BuildContext context, int index) {
                var item = photos[index];
                return InkWell(
                  onTap: () {
                    List data = photos.map((e) => e['photoUrl']).toList();
                    showPhotoView(context, data, item['photoUrl']);
                  },
                  child: Container(
                    child: NetImage(item['photoUrl'], fit: BoxFit.cover),
                  ),
                );
              },
              itemCount: photos.length,
              viewportFraction: 1.0,
              loop: true,
              autoplay: true,
              autoplayDelay: 3000,
              pagination: photos.length > 1
                  ? SwiperPagination(
                      alignment: Alignment.bottomRight,
                      builder: APPDotSwiperPaginationBuilder(),
                      margin: const EdgeInsets.only(right: 20, bottom: 10))
                  : null,
            ),
    );
  }

  ///图片浏览器
  showPhotoView(BuildContext context, List data, String image) {
    Navigator.of(context).push(new FadeRoute(
        page: PhotoViewGalleryScreen(
      images: data,
      index: data.indexOf(image), //传入当前点击的图片的index
      heroTag: image,
    )));
  }
}
