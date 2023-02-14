import 'dart:ui';

import 'package:app/common/bus_key.dart';
import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/store/society_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/mine/society/member/society_member_management_page.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/level_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocietyMemberPage extends StatefulWidget {
  Map data;

  SocietyMemberPage(this.data);

  @override
  _SocietyMemberPageState createState() => _SocietyMemberPageState();
}

class _SocietyMemberPageState extends State<SocietyMemberPage> {
  Map data;
  bool isInSociety = false;

  @override
  void initState() {
    super.initState();
    data = widget.data;
  }

  @override
  Widget build(BuildContext context) {
    return SocietyCtrl.society(
      builder: (info, type) {
        bool isAdmin = SocietyCtrl.obj.haveAdmin;
        data = info;
        return Scaffold(
            backgroundColor: Colors.white,
            appBar: xAppBar('公会成员', action: [
              if (isAdmin)
                Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Center(
                        child: InkResponse(
                            onTap: () => Get.to(SocietyMemberManagementPage(widget.data)),
                            child: Text('管理成员', style: TextStyle(color: Color(0xff7C66FF), fontSize: 14)))))
            ]),
            body: societyMember());
      },
    );
  }

  societyMember() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.only(left: 16, top: 20, bottom: 20, right: 16),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('公会成员', style: TextStyle(color: AppPalette.dark, fontSize: 16, fontWeight: FontWeight.w600)),
            Text(data['member'].toString(),
                style: TextStyle(color: AppPalette.hint, fontSize: 16, fontWeight: FontWeight.w600))
          ])),
      Expanded(child: SocietyMemberList(data))
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
    Bus.sub(BUS_SOCIETY_MEMBER_LIST_REFRESH, (data) {
      doRefresh();
    });
    super.initState();
  }


  @override
  Future fetchPage(PageNum page) {
    return Api.Family.getFamilyTeamJoin(
        familyId: widget.data['familyId'].toString(), current: page.index.toString(), pageSize: page.size.toString());
  }

  @override
  List<dynamic> transform(data) => super.transform(data['familyTeamJoinDTOS']);

  @override
  Widget itemBuilder(BuildContext context, dynamic item, int index) {
    return Container(
        height: 85,
        padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          RectAvatarView(
            size: 50,
            url: item['avatar'],
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
              WealthIcon(data: item)
            ]),
            SizedBox(height: 7),
            Text('贡献值：${item['familyIntegral']}', style: TextStyle(color: AppPalette.tips, fontSize: 12)),
            Spacer(),
            Divider(height: 1, color: AppPalette.divider)
          ]))
        ]));
  }
}
