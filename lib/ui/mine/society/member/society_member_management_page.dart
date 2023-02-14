import 'dart:ui';

import 'package:app/common/bus_key.dart';
import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/store/society_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/customer/app_text_button.dart';
import 'package:app/widgets/level_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocietyMemberManagementPage extends StatefulWidget {
  Map data;

  SocietyMemberManagementPage(this.data);

  @override
  _SocietyMemberManagementPageState createState() => _SocietyMemberManagementPageState();
}

class _SocietyMemberManagementPageState extends State<SocietyMemberManagementPage> {
  List list = [];
  bool allCheck = false;

  @override
  void initState() {
    super.initState();
    Bus.sub(BUS_SOCIETY_MEMBER_MANAGEMENT_DATA, (data) {
      setState(() {
        list = data;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    Bus.fire(BUS_SOCIETY_MEMBER_MANAGEMENT_DATA);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: xAppBar('成员管理', action: [
          AppTextButton(
            title: Text('全选', style: TextStyle(color: AppPalette.hint, fontSize: 14)),
            width: 50,
            onPress: () {
              allCheck = !allCheck;
              Bus.send(BUS_SOCIETY_MEMBER_MANAGEMENT_ALL, allCheck);
            },
          ),
          AppTextButton(
              title: Text('踢出', style: TextStyle(color: AppPalette.pink, fontSize: 14)),
              width: 50,
              onPress: () {
                if (list == null || list.length == 0) return;
                List userIds = List();
                for (dynamic data in list) {
                  if (data['app_check'] ?? false) userIds.add(data['uid']);
                }
                simpleSub(Api.Family.kickOutTeam(familyId: widget.data['familyId'].toString(), userIds: userIds),
                    callback: () {
                  SocietyCtrl.obj.doRefresh();
                  Bus.send(BUS_SOCIETY_MEMBER_MANAGEMENT_REFRESH);
                  Bus.send(BUS_SOCIETY_MEMBER_LIST_REFRESH);
                });
              }),
          AppTextButton(
              title: Text('完成', style: TextStyle(color: AppPalette.primary, fontSize: 14)),
              width: 50,
              margin: EdgeInsets.only(right: 16),
              onPress: () {
                Get.back();
              })
        ]),
        body: societyMember());
  }

  societyMember() {
    List list = List();
    for (dynamic data in this.list) {
      if (data['app_check'] ?? false) list.add(data);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.only(left: 16, top: 20, right: 16),
          child: Text('已选择${list.length}位成员',
              style: TextStyle(color: AppPalette.primary, fontSize: 14, fontWeight: FontWeight.w600))),
      Expanded(child: SocietyMemberList(widget.data))
    ]);
  }
}

class SocietyMemberList extends StatefulWidget {
  Map data;

  SocietyMemberList(this.data);

  @override
  _SocietyMemberListState createState() => _SocietyMemberListState();
}

class _SocietyMemberListState extends NetPageList<dynamic, SocietyMemberList> {
  @override
  void initState() {
    super.initState();
    Bus.sub(BUS_SOCIETY_MEMBER_MANAGEMENT_ALL, (data) {
      listData.forEach((element) {
        element['app_check'] = data;
      });
      setState(() {});
    });
    Bus.sub(BUS_SOCIETY_MEMBER_MANAGEMENT_REFRESH, (data) {
      doRefresh();
    });
  }

  @override
  void dispose() {
    super.dispose();
    Bus.fire(BUS_SOCIETY_MEMBER_MANAGEMENT_ALL);
  }

  @override
  Future fetchPage(PageNum page) {
    return Api.Family.getFamilyTeamJoin(
        familyId: widget.data['familyId'].toString(),
        current: page.index.toString(),
        pageSize: page.size.toString(),
        type: 2);
  }

  @override
  List<dynamic> transform(data) => super.transform(data['familyTeamJoinDTOS']);

  @override
  Widget itemBuilder(BuildContext context, dynamic item, int index) {
    return InkWell(
      onTap: () {
        item['app_check'] = !(item['app_check'] ?? false);
        Bus.send(BUS_SOCIETY_MEMBER_MANAGEMENT_DATA, listData);
        setState(() {});
      },
      child: Container(
          height: 85,
          padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(top: 14, right: 15),
              child: SvgPicture.asset(SVG.$('mine/society/${item['app_check'] ?? false ? '选中' : '未选中'}')),
            ),
            RectAvatarView(
              url: item['avatar'],
              size: 50,
              uid: item['uid'],
            ),
            SizedBox(width: 10),
            Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(item['nike'], style: TextStyle(color: AppPalette.dark, fontSize: 14)),
                SizedBox(width: 10),
                SvgPicture.asset(SVG.$('mine/性别_${item['gender'] == 0 ? '2' : '1'}')),
                SizedBox(width: 10),
                CharmIcon(data: item, height: 16),
                SizedBox(width: 6),
                WealthIcon(data: item, height: 16)
              ]),
              SizedBox(height: 7),
              Text('贡献值：${item['familyIntegral']}', style: TextStyle(color: AppPalette.tips, fontSize: 12)),
              Spacer(),
              Divider(height: 1, color: AppPalette.divider)
            ]))
          ])),
    );
  }
}
