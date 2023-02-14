import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/net/file_api.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/store/society_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/common/uid_box.dart';
import 'package:app/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../avatar_view.dart';

class SocietyEditDetailsPage extends StatefulWidget {
  bool isAdd;

  SocietyEditDetailsPage({this.isAdd = false});

  @override
  _SocietyEditDetailsPageState createState() => _SocietyEditDetailsPageState();
}

class _SocietyEditDetailsPageState extends State<SocietyEditDetailsPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController noticeController = TextEditingController();
  TextEditingController synopsisController = TextEditingController();
  Map user;
  RxString familyAvatar = ''.obs;

  @override
  void initState() {
    super.initState();
    user = OAuthCtrl.obj.info;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: xAppBar(widget.isAdd ? '创建公会信息' : '编辑公会信息', action: [
          Center(
              child: Text(widget.isAdd ? '创建' : '保存', style: TextStyle(color: Color(0xff7C66FF), fontSize: 12))
                  .toBtn(24, Color(0xffF1EEFF), width: 57, margin: EdgeInsets.only(right: 15), onTap: doCreationorEdit))
        ]),
        body: SingleChildScrollView(
            child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: [societyData(), societyEditData()]),
        )));
  }

  societyData() {
    return Padding(
      padding: const EdgeInsets.only(left: 36, top: 20, right: 20, bottom: 30),
      child: Row(
        children: [
          RectAvatarView(url: user['avatar'], size: 60, radius: 12),
          Spacing.w10,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user['nick'], style: TextStyle(color: AppPalette.dark, fontSize: 16)),
              Spacing.h4,
              UidBox(data: user, hasBG: false, color: AppPalette.tips),
            ],
          ),
        ],
      ),
    );
  }

  societyEditData() {
    if (widget.isAdd == false) {
      familyAvatar.value = SocietyCtrl.obj.info['familyLogo'];
      nameController.text = SocietyCtrl.obj.info['familyName'];
      noticeController.text = SocietyCtrl.obj.info['familyNotice'];
      synopsisController.text = SocietyCtrl.obj.info['familySynopsis'];
    } else {
      familyAvatar.value = user['avatar'];
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Obx(() => Container(
              height: 122,
              alignment: Alignment.center,
              child: InkResponse(
                  onTap: () => imagePicker(
                      (file) =>
                          simpleSub(() async => familyAvatar.value = await FileApi.upLoadFile(file, 'familyAvatar/')),
                      max: 512),
                  child: AvatarView(url: familyAvatar.value)))),
          getInput('公会名称:', nameController, '请输入公会名称'),
          getInput('公会公告:', noticeController, '请输入公会公告'),
          getInput('公会简介:', synopsisController, '请输入公会简介', maxLines: 5),
        ].separator(Spacing.h10));
  }

  getInput(label, controller, hintText, {maxLines: 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14)),
        Spacing.h10,
        TextField(
            maxLines: maxLines,
            controller: controller,
            onChanged: (str) {},
            inputFormatters: [],
            style: TextStyle(color: Color(0xff121834), fontSize: 14, height: 1),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Color(0xff121834).withAlpha(30), fontSize: 14),
              border: InputBorder.none,
            )).toWarp(color: AppPalette.divider, padding: EdgeInsets.symmetric(horizontal: 20)),
      ],
    );
  }

  doCreationorEdit() {
    String name = nameController.text.trim();
    String notice = noticeController.text.trim();
    String synopsis = synopsisController.text.trim();
    if (name == '') {
      showToast('请输入公会名称');
      return;
    }
    if (notice == '') {
      showToast('请输入公会公告');
      return;
    }
    if (synopsis == '') {
      showToast('请输入公会简介');
      return;
    }
    if (widget.isAdd) {
      simpleSub(Api.Family.createFamily(name: name, notice: notice, synopsis: synopsis, logo: familyAvatar.value),
          msg: '申请创建成功，请等待审批！', callback: () {
        Get.back();
        Get.back();
        Get.back();
      });
    } else {
      simpleSub(
          Api.Family.editFamilyTeam(
              familyId: SocietyCtrl.obj.info['familyId'],
              name: name,
              notice: notice,
              synopsis: synopsis,
              logo: familyAvatar.value),
          msg: '修改公会信息成功', callback: () {
        SocietyCtrl.obj.fetchInfo();
        Get.back();
      });
    }
  }
}
