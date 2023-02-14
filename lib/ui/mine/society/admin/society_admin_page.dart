import 'dart:ui';

import 'package:app/common/bus_key.dart';
import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/store/society_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/mine/society/admin/society_add_admin_management_page.dart';
import 'package:app/ui/mine/society/admin/society_admin_management_page.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/level_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocietyAdminPage extends StatefulWidget {
  Map data;

  SocietyAdminPage(this.data);

  @override
  _SocietyAdminPageState createState() => _SocietyAdminPageState();
}

class _SocietyAdminPageState extends State<SocietyAdminPage> {
  Map data = {};
  bool isInSociety = false;

  @override
  void initState() {
    super.initState();
    data.addAll(widget.data);
  }

  refresh() {
    Bus.send(BUS_SOCIETY_ADMIN_PAGE);
    SocietyCtrl.obj.doRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return SocietyCtrl.society(
      builder: (info, type) {
        final currentFamilyId = data['familyId'];
        isInSociety = SocietyCtrl.obj.isInCurrentSociety(currentFamilyId);
        bool isShaikh = SocietyCtrl.obj.isShaikh;
        data = info;
        return Scaffold(
            backgroundColor: Colors.white,
            appBar: xAppBar('管理员', action: [
              if (isShaikh)
                Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Center(
                        child: InkResponse(
                            onTap: () => Get.to(SocietyAdminManagementPage(widget.data)).then((value) => refresh()),
                            child: Text('编辑', style: TextStyle(color: Color(0xff7C66FF), fontSize: 14)))))
            ]),
            body: Stack(children: [
              societyMember(),
              Positioned(
                  left: 50,
                  right: 50,
                  bottom: 44,
                  child: Text('新增管理员', style: TextStyle(color: Colors.white, fontSize: 14)).toBtn(40, Color(0xff7C66FF),
                      onTap: () {
                    Get.to(SocietyAddAdminManagementPage(widget.data)).then((value) => refresh());
                  }))
            ]));
      },
    );
  }

  societyMember() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.only(left: 16, top: 20, bottom: 20, right: 16),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('公会管理员', style: TextStyle(color: AppPalette.dark, fontSize: 16, fontWeight: FontWeight.w600)),
            Text((data['adminCount'] ?? 0).toString(),
                style: TextStyle(color: AppPalette.hint, fontSize: 16, fontWeight: FontWeight.w600))
          ])),
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
    Bus.sub(BUS_SOCIETY_ADMIN_PAGE, (data) {
      doRefresh();
    });
  }

  @override
  void dispose() {
    super.dispose();
    Bus.fire(BUS_SOCIETY_ADMIN_PAGE);
  }

  @override
  Future fetchPage(PageNum page) {
    return Api.Family.getAdminList(current: page.index.toString(), pageSize: page.size.toString());
  }

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
              WealthIcon(data: item, height: 16)
            ]),
            SizedBox(height: 7),
            Text('贡献值：${item['familyIntegral']}', style: TextStyle(color: AppPalette.tips, fontSize: 12)),
            Spacer(),
            Divider(height: 1, color: AppPalette.divider)
          ]))
        ]));
  }
}
