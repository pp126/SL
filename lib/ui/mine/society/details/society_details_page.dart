import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/store/society_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/tools/common_utils.dart';
import 'package:app/tools/time.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/mine/page/user_page.dart';
import 'package:app/ui/mine/society/admin/society_admin_page.dart';
import 'package:app/ui/mine/society/edit/society_edit_page.dart';
import 'package:app/ui/mine/society/member/society_member_page.dart';
import 'package:app/ui/mine/society/water/society_water_page.dart';
import 'package:app/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocietyDetailsPage extends StatefulWidget {
  Map data;

  SocietyDetailsPage(this.data);

  @override
  _SocietyDetailsPageState createState() => _SocietyDetailsPageState();
}

class _SocietyDetailsPageState extends State<SocietyDetailsPage> {
  Map data = {};
  bool isInSociety = false;
  bool isShaikh;
  bool haveAdmin;

  @override
  void initState() {
    super.initState();
    data.addAll(widget.data);
  }

  doRefresh() {
    SocietyCtrl.obj.doRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return SocietyCtrl.society(builder: (info, type) {
      isShaikh = SocietyCtrl.obj.isShaikh;
      haveAdmin = SocietyCtrl.obj.haveAdmin;
      final currentFamilyId = data['familyId'];
      isInSociety = SocietyCtrl.obj.isInCurrentSociety(currentFamilyId);
      bool isApplyCreateSociety = SocietyCtrl.obj.isApplyCreateSociety;
      if (isInSociety) {
        data.clear();
        data.addAll(info);
      }
      return Scaffold(
        appBar: xAppBar('公会信息',
            action: haveAdmin
                ? '编辑'.toTxtActionBtn(onPressed: () => Get.to(SocietyEditDetailsPage(isAdd: false)))
                : SizedBox()),
        backgroundColor: AppPalette.background,
        body: Stack(children: <Widget>[
          Column(
            children: [
              societyData(),
              societyFromData(),
            ],
          ),
          isApplyCreateSociety
              ? Positioned(
                  bottom: 44,
                  left: 50,
                  right: 50,
                  child: Text(
                    '正在申请创建公会，点击取消',
                    style: TextStyle(color: AppPalette.primary, fontSize: 14),
                  ).toBtn(40, AppPalette.txtWhite, radius: 100, onTap: onCancelApplyTap))
              : Container()
        ]),
      );
    });
  }

  societyData() {
    return Padding(
        padding: const EdgeInsets.only(left: 36, top: 20, right: 20, bottom: 30),
        child: Row(children: [
          RectAvatarView(size: 60, url: data['familyLogo']),
          SizedBox(width: 15),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(data['familyName'], style: TextStyle(color: AppPalette.dark, fontSize: 16)),
              SizedBox(height: 4),
              Row(children: [
                SvgPicture.asset(SVG.$('mine/society/id灰'), color: AppPalette.tips),
                SizedBox(width: 3),
                Text('${data['familyId']}', style: TextStyle(color: AppPalette.tips, fontSize: 10)),
                SizedBox(width: 10),
                Text('复制', style: TextStyle(color: AppPalette.primary, fontSize: 10, height: 1))
                    .toBtn(15, AppPalette.txtWhite, onTap: () {
                  CommonUtils.copyToClipboard(data['familyId']);
                  showToast('复制成功');
                })
              ]),
              SizedBox(height: 4),
              Text('创建时间：${TimeUtils.getDateStrByMs(data['createTime'])}',
                  style: TextStyle(color: AppPalette.tips, fontSize: 10))
            ]),
          )
        ]));
  }

  societyFromData() {
    isShaikh = SocietyCtrl.obj.isShaikh;
    return Container(
        padding: EdgeInsets.fromLTRB(36, 0, 24, 0),
        color: Colors.white,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              padding: EdgeInsets.only(top: 16, bottom: 16),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: AppPalette.divider))),
              child: Row(children: [
                Text('公会会长', style: TextStyle(color: AppPalette.dark, fontSize: 14)),
                Spacer(),
                InkWell(
                  onTap: () => Get.to(UserPage(uid: data['uid'])),
                  child: AvatarView(
                    size: 30,
                    url: data['avatar'],
                  ),
                ),
                SizedBox(width: 8),
                Text(data['nick'] ?? '', style: TextStyle(color: AppPalette.dark, fontSize: 14)),
                SizedBox(width: 10),
                Icon(Icons.arrow_forward_ios, size: 16, color: AppPalette.hint)
                // Icon(Icons.arrow_forward_ios, size: 16, color: AppPalette.hint)
              ])),
          if (isShaikh)
            InkWell(
              onTap: () {
                Get.to(SocietyAdminPage(data)).then((value) => doRefresh());
              },
              child: Container(
                  padding: EdgeInsets.only(top: 16, bottom: 16),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: AppPalette.divider))),
                  child: Row(children: [
                    Text('管理员', style: TextStyle(color: AppPalette.dark, fontSize: 14)),
                    Spacer(),
                    SvgPicture.asset(SVG.$('mine/society/人深灰')),
                    SizedBox(width: 4),
                    Text((data['adminCount'] ?? 0).toString(), style: TextStyle(color: AppPalette.tips, fontSize: 14)),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward_ios, size: 16, color: AppPalette.hint)
                  ])),
            ),
          if (isInSociety)
            InkWell(
              onTap: () {
                Get.to(SocietyMemberPage(data)).then((value) => doRefresh());
              },
              child: Container(
                  padding: EdgeInsets.only(top: 16, bottom: 16),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: AppPalette.divider))),
                  child: Row(children: [
                    Text('公会成员', style: TextStyle(color: AppPalette.dark, fontSize: 14)),
                    Spacer(),
                    SvgPicture.asset(SVG.$('mine/society/人深灰')),
                    SizedBox(width: 4),
                    Text(data['member'].toString(), style: TextStyle(color: AppPalette.tips, fontSize: 14)),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward_ios, size: 16, color: AppPalette.hint)
                  ])),
            ),
          if (isShaikh)
            InkWell(
              onTap: () => Get.to(SocietyWaterPage()),
              child: Container(
                  padding: EdgeInsets.only(top: 16, bottom: 16),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: AppPalette.divider))),
                  child: Row(children: [
                    Text('公会流水', style: TextStyle(color: AppPalette.dark, fontSize: 14)),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios, size: 16, color: AppPalette.hint)
                  ])),
            ),
          Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 36),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('公会简介', style: TextStyle(color: AppPalette.dark, fontSize: 14)),
                SizedBox(
                  height: 10,
                ),
                Text(data['familySynopsis'] ?? '', style: TextStyle(color: AppPalette.tips, fontSize: 14))
              ]))
        ]));
  }

  onCancelApplyTap() {
    simpleSub(Api.Family.cancelApplyCreateFamily(familyId: data['familyId'].toString()), msg: '取消成功', callback: () {
      Get.back();
    });
  }
}
