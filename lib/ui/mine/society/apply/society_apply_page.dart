import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/level_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide kToolbarHeight;
import 'package:flutter_svg/flutter_svg.dart';

class SocietyApplyPage extends StatefulWidget {
  Map data;

  SocietyApplyPage(this.data);

  @override
  _SocietyApplyPageState createState() => _SocietyApplyPageState();
}

class _SocietyApplyPageState extends State<SocietyApplyPage> {
  final tabs = ['加入公会', '退出公会'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: xAppBar(
          xAppBar$TabBar(tabs.map((e) => Text(e)).toList(growable: false)),
        ),
        body: TabBarView(children: [AddMemberList(widget.data), WxitMemberList(widget.data)]),
      ),
    );
  }
}

class AddMemberList extends StatefulWidget {
  Map data;

  AddMemberList(this.data);

  @override
  _AddMemberListState createState() => _AddMemberListState();
}

class _AddMemberListState extends NetPageList<Map, AddMemberList> {
  @override
  Future fetchPage(PageNum page) {
    return Api.Family.applyList(
        familyId: widget.data['id'].toString(), pageNum: page.index, pageSize: page.size, type: '0');
  }

  @override
  Widget itemBuilder(BuildContext context, Map item, int index) {
    return Container(
        height: 85,
        padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          RectAvatarView(
            url: item['avatar'],
            size: 50,
            uid: item['uid'],
          ),
          SizedBox(width: 10),
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item['nike'], style: TextStyle(color: AppPalette.dark, fontSize: 14)),
                SizedBox(height: 7),
                Row(children: [
                  SvgPicture.asset(SVG.$('mine/性别_${item['gender'] == 0 ? '2' : '1'}')),
                  SizedBox(width: 5),
                  Container(
                      width: 15,
                      height: 15,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xffFFCB2F), Color(0xffFF982F)])),
                      child: Text((item['level'] ?? 1).toString(), style: TextStyle(color: Colors.white, fontSize: 6))),
                  SizedBox(width: 5),
                  CharmIcon(data: item, height: 16),
                  SizedBox(width: 6),
                  WealthIcon(data: item, height: 16)
                ])
              ]),
              Spacer(),
              Text('拒绝', style: TextStyle(color: AppPalette.pink, fontSize: 10)).toBtn(24, Color(0xffFFECEF), width: 50,
                  onTap: () {
                simpleSub(
                    Api.Family.applyFamily(
                        userId: item['uid'].toString(),
                        familyId: widget.data['familyId'].toString(),
                        status: '2',
                        type: '1'),
                    msg: '拒绝成功', callback: () {
                  doRefresh();
                });
              }),
              SizedBox(width: 10),
              Text('同意', style: TextStyle(color: Colors.white, fontSize: 10)).toBtn(24, AppPalette.primary, width: 50,
                  onTap: () {
                simpleSub(
                    Api.Family.applyFamily(
                        userId: item['uid'].toString(),
                        familyId: widget.data['familyId'].toString(),
                        status: '1',
                        type: '1'),
                    msg: '同意成功', callback: () {
                  doRefresh();
                });
              })
            ]),
            Spacer(),
            Divider(height: 1, color: AppPalette.divider)
          ]))
        ]));
  }
}

class WxitMemberList extends StatefulWidget {
  Map data;

  WxitMemberList(this.data);

  @override
  _WxitMemberListState createState() => _WxitMemberListState();
}

class _WxitMemberListState extends NetPageList<Map, WxitMemberList> {
  @override
  Future fetchPage(PageNum page) {
    return Api.Family.applyList(
        familyId: widget.data['id'].toString(), pageNum: page.index, pageSize: page.size, type: '1');
  }

  @override
  Widget itemBuilder(BuildContext context, Map item, int index) {
    return Container(
        height: 85,
        padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          RectAvatarView(
            url: item['avatar'],
            size: 50,
            uid: item['uid'],
          ),
          SizedBox(width: 10),
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(item['nike'], style: TextStyle(color: AppPalette.dark, fontSize: 14)),
                  SizedBox(width: 5),
                  SvgPicture.asset(SVG.$('mine/性别_${item['gender'] == 0 ? '2' : '1'}')),
                  SizedBox(width: 5),
                  Container(
                      width: 15,
                      height: 15,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xffFFCB2F), Color(0xffFF982F)])),
                      child: Text((item['avatar'] ?? 0).toString(), style: TextStyle(color: Colors.white, fontSize: 6)))
                ]),
                SizedBox(height: 7),
                Row(children: [
                  CharmIcon(data: item, height: 16),
                  SizedBox(width: 6),
                  WealthIcon(data: item, height: 16),
                  SizedBox(width: 6),
                  Text('贡献值：${item['familyIntegral'] ?? 0}', style: TextStyle(color: AppPalette.tips, fontSize: 12))
                ])
              ]),
              Spacer(),
              Text('拒绝', style: TextStyle(color: AppPalette.pink, fontSize: 10)).toBtn(24, Color(0xffFFECEF), width: 50,
                  onTap: () {
                simpleSub(
                    Api.Family.applyFamily(
                        userId: item['uid'].toString(),
                        familyId: widget.data['familyId'].toString(),
                        status: '2',
                        type: '2'),
                    msg: '拒绝成功', callback: () {
                  doRefresh();
                });
              }),
              SizedBox(width: 10),
              Text('同意', style: TextStyle(color: Colors.white, fontSize: 10)).toBtn(24, AppPalette.primary, width: 50,
                  onTap: () {
                simpleSub(
                    Api.Family.applyFamily(
                        userId: item['uid'].toString(),
                        familyId: widget.data['familyId'].toString(),
                        status: '1',
                        type: '2'),
                    msg: '同意成功', callback: () {
                  doRefresh();
                });
              })
            ]),
            Spacer(),
            Divider(height: 1, color: AppPalette.divider)
          ]))
        ]));
  }
}
