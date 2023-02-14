import 'dart:ui';

import 'package:app/common/bus_key.dart';
import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/store/society_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/tools/common_utils.dart';
import 'package:app/tools/num_utils.dart';
import 'package:app/tools/screen.dart';
import 'package:app/tools/view.dart';
import 'package:app/ui/home/widgets/home_card.dart';
import 'package:app/ui/home/widgets/tab_bar_persistent_header_delegate.dart';
import 'package:app/ui/mine/society/contribution/contribution_page.dart';
import 'package:app/ui/mine/society/dialog/dialogs.dart';
import 'package:app/ui/mine/society/rank/society_rank_page.dart';
import 'package:app/ui/mine/society/society_out_time.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/circular_linear_progressIndicator.dart';
import 'package:app/widgets/customer/app_net_image.dart';
import 'package:app/widgets/network_cache_image.dart';
import 'package:app/widgets/pop/pop_route.dart';
import 'package:app/widgets/pop/tip_pop.dart';
import 'package:app/widgets/spacing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'apply/society_apply_page.dart';
import 'details/society_details_page.dart';

class SocietyPage extends StatefulWidget {
  final Map data;

  SocietyPage(this.data);

  @override
  _SocietyPageState createState() => _SocietyPageState();
}

class _SocietyPageState extends State<SocietyPage> {
  bool isShowBlackTitle = false;
  GlobalKey menuKey = GlobalKey();

//  var api = Api.Family.userFamily();
  Map data = {};
  bool haveSociety = false;

  ///已加入公会
  bool isInSociety = true;

  ///在当前公会
  bool isApply = false;

  ///申请加入
  bool isApplyOut = false;

  ///申请退出

  @override
  void initState() {
    super.initState();
    data.addAll(widget.data);
    refreshSociety();
  }

  doRefresh() {
    SocietyCtrl.obj.doRefresh();
    refreshSociety();
  }

  refreshSociety() {
    if (SocietyCtrl.obj.isAdmin) {
      ///成员管理提示
      Api.Family.applyList(familyId: data['id'].toString(), pageNum: 1, pageSize: 10, type: '0').then((value) {
        setState(() {
          isApply = value.length > 0;
        });
      });
      Api.Family.applyList(familyId: data['id'].toString(), pageNum: 1, pageSize: 10, type: '1').then((value) {
        setState(() {
          isApplyOut = value.length > 0;
        });
      });
    }
    SocietyCtrl.obj.fetchInfo();
    Bus.send(BUS_SOCIETY_ROOM_LIST_REFRESH);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SocietyCtrl.society(
        builder: (info, type) {
          haveSociety = SocietyCtrl.obj.isInSociety;
          final currentFamilyId = data['familyId'];
          bool isApplyJoin = SocietyCtrl.obj.isApplyJoinSociety(currentFamilyId);
          isInSociety = SocietyCtrl.obj.isInCurrentSociety(currentFamilyId);
          if (isInSociety) {
            data.clear();
            data.addAll(info);
          }
          print("isInSociety==$isInSociety");
          Color color = isShowBlackTitle ? Colors.black : Colors.white;
          String title = isInSociety ? '我的公会' : '公会名片';

          Widget action = SizedBox();
          List item = [];
          TextStyle style = TextStyle(color: Colors.white, fontSize: 14);
          if (!haveSociety) {
            item.add(isApplyJoin ? '取消申请' : '申请加入公会');
            item.add(() {
              simpleSub(
                  isApplyJoin
                      ? Api.Family.cancelApplyJoinFamilyTeam(familyId: currentFamilyId.toString())
                      : Api.Family.applyJoinFamilyTeam(familyId: currentFamilyId.toString()),
                  msg: isApplyJoin ? '取消成功' : '申请成功',
                  callback: doRefresh);
            });
            action = Text(item[0], style: style)
                .toBtn(40, Color(0xff7C66FF), margin: EdgeInsets.symmetric(horizontal: 50), onTap: item[1]);
          } else if (type == UserSocietyType.applyOutSociety || type == UserSocietyType.forceOutSociety) {
            action = Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(type == UserSocietyType.applyOutSociety ? '申请退会倒计时' : '强制退会倒计时', style: style),
                TimerOutLine(
                  time: info['exitFamilyTime'],
                ),
                Text('，点击取消', style: style),
              ],
            ).toBtn(40, Color(0xff7C66FF), margin: EdgeInsets.symmetric(horizontal: 50), onTap: () {
              simpleSub(Api.Family.cancelApplyOutFamilyTeam(familyId: currentFamilyId.toString()),
                  msg: '取消成功', callback: doRefresh);
            });
          }

          return NotificationListener(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollUpdateNotification && scrollNotification.depth == 0) {
                  //滚动并且是列表滚动的时候
                  _onScroll(scrollNotification.metrics.pixels);
                }
                return true;
              },
              child: Stack(
                children: <Widget>[
                  NestedScrollView(
                    headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                      return [
                        SliverAppBar(
                          brightness: isShowBlackTitle ? Brightness.light : Brightness.dark,
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
                          title: Text(
                            title,
                            style: TextStyle(color: color),
                          ),
                          centerTitle: true,
                          pinned: true,
                          floating: false,
                          snap: false,
                          primary: true,
                          expandedHeight: Screen.topSafeHeight + (isInSociety ? 350.0 : 190),
                          backgroundColor: AppPalette.background,
                          elevation: 0,
                          //是否显示阴影，直接取值innerBoxIsScrolled，展开不显示阴影，合并后会显示
                          forceElevated: innerBoxIsScrolled,
                          actions: <Widget>[
                            if (isInSociety)
                              'mine/society/奖杯白'.toSvgActionBtn(
                                color: color,
                                onPressed: () => Get.to(SocietyRankPage()).then((value) => refreshSociety()),
                              ),
                            if (isInSociety)
                              'mine/society/展开更多'.toSvgActionBtn(
                                key: menuKey,
                                color: color,
                                onPressed: () => showMenu(),
                              ),
                          ],

                          flexibleSpace: FlexibleSpaceBar(
                            collapseMode: CollapseMode.pin,
                            background: _buildTopView(),
                          ),
                        ),
                        SliverPersistentHeader(
                            delegate: TabBarPersistentHeaderDelegate(societyRoom(), 35), pinned: true),
                      ];
                    },
                    body: IgnorePointer(
                      ignoring: !isInSociety,
                      child: SocietyRoomList(data),
                    ),
                  ),
                  Positioned(left: 0, right: 0, bottom: 32, child: action),
                ],
              ));
        },
      ),
    );
  }

  _buildTopView() {
    var photo = xMapStr(
      data,
      'familyLogo',
    );

    return Stack(
      children: [
        Container(
          width: double.infinity,
          child: NetImage(photo, fit: BoxFit.cover),
        ),
        ClipRect(
          //裁切长方形
          child: BackdropFilter(
            //背景滤镜器
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), //图片模糊过滤，横向竖向都设置5.0
            child: Opacity(
              //透明控件
              opacity: 0.5,
              child: Container(
                // 容器组件
                width: double.infinity,
                height: 500.0,
                decoration: BoxDecoration(color: Color(0x80000000)), //盒子装饰器，进行装饰，设置颜色为灰色
              ),
            ),
          ),
        ),
        Positioned(
          top: Screen.topSafeHeight + 80,
          left: 0,
          right: 0,
          child: societyData(),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: isInSociety ? 168 : 12,
            padding: EdgeInsets.fromLTRB(16, 15, 16, 10),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                )),
            child: mySocietyData(),
          ),
        ),
      ],
    );
  }

  societyData() {
    return InkWell(
        onTap: () => Get.to(SocietyDetailsPage(data)).then((value) => refreshSociety()),
        child: Row(children: [
          Spacing.w16,
          Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12)), color: Colors.white),
            child: AppNetImage(
              defaultImageWidth: 60,
              defaultImageHeight: 60,
              radius: 12.0,
              netImageUrl: data['familyLogo'],
              isHead: false,
              fit: BoxFit.cover,
            ),
          ),
          Spacing.w16,
          Expanded(
              child: Container(
            constraints: BoxConstraints(
              minHeight: 60,
            ),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(data['familyName'],
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: fw$SemiBold)),
                    Spacing.w6,
                    societyLevel(),
                  ]),
                  Text(data['familySynopsis'] ?? '', style: TextStyle(color: Colors.white, fontSize: 12)),
                  Row(children: [
                    SvgPicture.asset(SVG.$('mine/society/id白')),
                    Text(data['familyId'].toString(), style: TextStyle(color: Colors.white, fontSize: 10)),
                    SizedBox(width: 10),
                    SvgPicture.asset(SVG.$('mine/society/人灰')),
                    Text(data['member'].toString(), style: TextStyle(color: Colors.white, fontSize: 10))
                  ])
                ]),
          )),
          Spacing.w4,
          Icon(Icons.arrow_forward_ios, size: 16, color: AppPalette.hint),
          Spacing.w16,
        ]));
  }

  societyLevel() {
    return data['familyLevel'] != null
        ? Positioned(
                right: 4,
                child: Text(data['familyLevel']['levelName'],
                    style: TextStyle(color: Colors.white, fontSize: 7, height: 1)))
            .toAssImg(16, 'mine/society/工会', boxFit: BoxFit.fill)
        : SizedBox();
  }

  mySocietyData() {
    return isInSociety
        ? Column(
            children: [
              Row(children: [
                Text('公会等级', style: TextStyle(color: AppPalette.dark, fontSize: 16, fontWeight: fw$SemiBold)),
                Spacing.w6,
                societyLevel(),
                Spacing.w16,
                Expanded(
                    child: Container(
                        height: 11,
                        child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            child: CircularLinearProgressIndicator(
                                backgroundColor: Color(0xffE0DDF0),
                                value: data['familyLevel']['levelPercent'],
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xff645BFF)))))),
                Spacing.w16,
                Text('${NumUtils.getDouble(data['familyLevel']['levelPercent'] * 100, 2)}%',
                    style: TextStyle(color: AppPalette.tips, fontSize: 10))
              ]),
              Expanded(
                child: Container(
                    width: double.infinity,
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.symmetric(vertical: 15),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12)), color: AppPalette.divider),
                    child: Text.rich(TextSpan(children: [
                      TextSpan(
                          text: '公告  ',
                          style: TextStyle(color: AppPalette.dark, fontSize: 14, fontWeight: fw$SemiBold)),
                      TextSpan(text: '${data['familyNotice']}', style: TextStyle(color: AppPalette.tips, fontSize: 14))
                    ]))),
              ),
              Row(children: [
                Text.rich(TextSpan(children: [
                  TextSpan(
                      text: '今日贡献',
                      style: TextStyle(color: AppPalette.dark, fontSize: 16, fontWeight: FontWeight.w600)),
                  TextSpan(
                      text: '  ${xMapStr(data, 'dayIntegral')}',
                      style: TextStyle(color: AppPalette.primary, fontSize: 16, fontWeight: FontWeight.w600)),
                ])),
                Spacing.w16,
                Expanded(
                  child: moreHeadPhoto([
                    if (data['familyUsersDTOS'] != null) ...data['familyUsersDTOS'].map((e) => e['avatar']).toList()
                  ]),
                ),
                Spacing.w16,
                Text('贡献', style: TextStyle(color: Colors.white, fontSize: 10, height: 1))
                    .toBtn(24, AppPalette.primary, width: 57, onTap: () {
                  context.showDownDialog(ContributionDialog(data: data)).then((value) => refreshSociety());
                })
              ]),
            ],
          )
        : SizedBox();
  }

  moreHeadPhoto(List<String> imgs) {
    return xFlatButton(
      48,
      Colors.white,
      onTap: () {
        Get.to(ContributionPage(data)).then((value) => refreshSociety());
      },
      child: Container(
        alignment: Alignment.centerRight,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Stack(children: [
            for (int i = 0, j = imgs.length; i < j; i++)
              Container(
                  margin: EdgeInsets.only(left: i * 20.0),
                  padding: EdgeInsets.all(1),
                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(100)), color: Colors.white),
                  child: ClipOval(
                      child: NetImage(
                    imgs[i],
                    width: 30,
                    height: 30,
                    fit: BoxFit.cover,
                  )))
          ]),
        ),
      ),
    );
  }

  societyRoom() {
    return Container(
      height: 35,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        Text('公会房间', style: TextStyle(color: AppPalette.dark, fontSize: 16)),
        Spacing(),
        Text((data['roomCount'] ?? 0).toString(), style: TextStyle(color: AppPalette.hint, fontSize: 16)),
        SizedBox(width: 10),
        // if (haveAdmin)
        //   Text('房间管理', style: TextStyle(color: AppPalette.primary, fontSize: 10)).toBtn(24, AppPalette.txtWhite,
        //       onTap: () {
        //     Get.to(SocietyRoomManagementPage(widget.data)).then((value) => refreshSociety());
        //   })
      ]),
    );
  }

  showMenu() {
    bool canApplyOutSociety = SocietyCtrl.obj.canApplyOutSociety();
    bool canForceOutSociety = SocietyCtrl.obj.canForceOutSociety();
    bool haveAdmin = SocietyCtrl.obj.haveAdmin;
    bool isShaikh = SocietyCtrl.obj.isShaikh;

    RenderBox renderBox = menuKey.currentContext.findRenderObject();
    var offset = renderBox.localToGlobal(Offset.zero);
    Navigator.push(
        context,
        PopRoute(
            child: TipPop(
                child: Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    width: 116,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      if (haveAdmin)
                        InkWell(
                            onTap: () {
                              Get.back();
                              Get.to(SocietyApplyPage(data)).then((value) => refreshSociety());
                            },
                            child: Padding(
                                padding: const EdgeInsets.only(left: 30, top: 15, bottom: 15),
                                child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                                  Text('成员申请', style: TextStyle(fontSize: 14, color: AppPalette.dark)),
                                  if (isApply || isApplyOut)
                                    Container(
                                        width: 7,
                                        height: 7,
                                        margin: EdgeInsets.only(left: 10),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(100), color: AppPalette.pink))
                                ]))),
                      InkWell(
                          onTap: () {
                            String str =
                                '公会名称：${data['familyName']} 公会简介：${data['familySynopsis']}  公会ID：${data['familyId']}';
                            CommonUtils.copyToClipboard(str);
                            showToast('复制成功');
                            Get.back();
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 30, top: 15, bottom: 15),
                            child: Text('分享公会', style: TextStyle(fontSize: 14, color: AppPalette.dark)),
                          )),
                      if (isShaikh)
                        InkWell(
                            onTap: () {
                              context.showDownDialog(DissolveDialog(onTap: () {
                                simpleSub(Api.Family.delFamily(), msg: '解散成功', callback: () {
                                  Get.back();
                                  Get.back();
                                });
                              }));
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 30, top: 15, bottom: 15),
                              child: Text('解散公会', style: TextStyle(fontSize: 14, color: AppPalette.dark)),
                            )),
                      if (canApplyOutSociety)
                        InkWell(
                            onTap: () {
                              context.showDownDialog(QuitDialog(onTap: () {
                                simpleSub(Api.Family.applyExitTeam(familyId: data['familyId'].toString()),
                                    msg: '申请退出成功', callback: () {
                                  Get.back();
                                  doRefresh();
                                });
                              }));
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 30, top: 15, bottom: 15),
                              child: Text('退出公会', style: TextStyle(fontSize: 14, color: AppPalette.dark)),
                            )),
                      if (canForceOutSociety)
                        InkWell(
                            onTap: () {
                              context.showDownDialog(QuitDialog(
                                  force: true,
                                  onTap: () {
                                    simpleSub(Api.Family.forceExitTeam(familyId: data['familyId'].toString()),
                                        msg: '申请退出成功', callback: () {
                                      Get.back();
                                      doRefresh();
                                    });
                                  }));
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 30, top: 15, bottom: 15),
                              child: Text('强制退会', style: TextStyle(fontSize: 14, color: AppPalette.dark)),
                            )),
                    ])),
                left: offset.dx - 85,
                top: offset.dy + 40)));
  }
}

class SocietyRoomList extends StatefulWidget {
  final Map data;

  SocietyRoomList(this.data);

  @override
  _SocietyRoomListState createState() => _SocietyRoomListState();
}

class _SocietyRoomListState extends NetPageList<Map, SocietyRoomList> {
  @override
  void initState() {
    super.initState();
    Bus.sub(BUS_SOCIETY_ROOM_LIST_REFRESH, (data) {
      doRefresh();
    });
  }

  @override
  void dispose() {
    super.dispose();
    Bus.fire(BUS_SOCIETY_ROOM_LIST_REFRESH);
  }

  @override
  Future fetchPage(PageNum page) {
    return Api.Family.getRoomInfo(familyId: widget.data['familyId'], pageNum: page.index, pageSize: 1000);
  }

  @override
  Widget itemBuilder(BuildContext context, dynamic item, int index) {
    return RoomCard(item);
  }

  @override
  initListConfig() {
    return GridConfig(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: RoomCard.gridDelegate,
    );
  }
}
