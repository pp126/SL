import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/net/file_api.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/tools/dialog.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/inputformatter/TextInputFormatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../avatar_view.dart';
import 'input_item.dart';
import 'name_page.dart';

class LoadSetPage extends StatefulWidget {
  @override
  _LoadSetPageState createState() => _LoadSetPageState();
}

class _LoadSetPageState extends State<LoadSetPage> {
  final _avatarKey = GlobalKey<XFutureBuilderState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController shareCode = TextEditingController();

  String avatar = null;
  String nick = null;
  num gender = null;
  String birth = null;

  Future getData() {
    return Api.Moment.getMaterialAvatar();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: xAppBar(
          '请先设置基本信息',
          leading: SizedBox(),
          action: '退出'.toTxtActionBtn(onPressed: OAuthCtrl.obj.logout),
        ),
        backgroundColor: AppPalette.background,
        body: SingleChildScrollView(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 32),
          child: OAuthCtrl.use(builder: (user) {
            return Column(
              children: <Widget>[
                Container(
                  height: 100,
                  padding: EdgeInsets.only(top: 20),
                  alignment: Alignment.center,
                  child: InkResponse(
                    onTap: () {
                      imagePicker(
                        (file) {
                          simpleSub(
                            () async {
                              final url =
                                  await FileApi.upLoadFile(file, 'avatar/');
                              print('avatar====$avatar');
                              setState(() {
                                avatar = url;
                              });
                            },
                          );
                        },
                        max: 512,
                      );
                    },
                    child: AvatarView(
                        url: avatar ?? '', size: 82, side: BorderSide.none),
                  ),
                ),
                // Text(
                //   '换个头像',
                //   style: TextStyle(color: Colors.white, fontSize: 12),
                // ).toBtn(25, Color(0xff7C66FF),
                //     width: 80,
                //     onTap: () => _avatarKey.currentState.doRefresh()),
                xItem(
                  Item(
                    '昵称',
                    nick ?? '',
                    AppPalette.dark,
                    () => Get.to(NamePage(
                      isReturn: true,
                    )).then((value) => setState(() => nick = value)),
                  ),
                ),
                Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('性别只能设置一次',
                          style: TextStyle(
                              color: AppPalette.primary, fontSize: 14)),
                    )),
                xItem(
                  Item(
                      '性别',
                      gender == null
                          ? '请选择'
                          : gender == 1
                              ? '男'
                              : '女',
                      gender == null ? AppPalette.tips : AppPalette.dark, () {
                    showPickerArray(context);
                  }),
                ),
                xItem(
                  Item(
                    '生日',
                    birth == null ? '请选择' : birth,
                    birth == null ? AppPalette.tips : AppPalette.dark,
                    () => showPickerDateTime(birth, context),
                  ),
                ),
                InputItem(
                  '邀请码(选填)',
                  '请输入邀请码',
                  shareCode,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(10),
                    OnlyInputNumberAndWorkFormatter()
                  ],
                  keyboardType: TextInputType.text,
                ),
                Text(
                  '确认并设置个人信息',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ).toBtn(
                  60,
                  AppPalette.hint,
                  margin: EdgeInsets.only(
                    top: 50,
                    left: 48,
                    right: 48,
                  ),
                  colors: [Color(0xffA882FF), Color(0xff645BFF)],
                  onTap: doSub,
                ),
              ].separator(SizedBox(height: 15)),
            );
          }),
        ),
      ),
    );
  }

  doSub() {
    String shareCodeStr = shareCode.text.trim().toString();
    //todo 隐藏信息设置
    // if (avatar == null) {
    //   showToast('请选择上传头像');
    //   return;
    // }
    // if (nick == null) {
    //   showToast('请输入昵称');
    //   return;
    // }
    // if (gender == null) {
    //   showToast('请选择上性别');
    //   return;
    // }
    // if (birth == null) {
    //   showToast('请选择生日');
    //   return;
    // }
    simpleSub(
      OAuthCtrl.obj.updateUserInfo({
        'avatar': avatar,
        'nick': nick,
        'gender': gender,
        'birth': birth,
        if (shareCodeStr != '') 'inviteCode': shareCodeStr,
      }),
      msg: '设置成功',
      callback: () => Get.back(result: gender),
    );
  }

  dateFormat(num data) => DateFormat("yyyy-MM-dd")
      .format(DateTime.fromMillisecondsSinceEpoch(data));

  showPickerArray(BuildContext context) {
    DialogUtils.showSexDialog(context, callBack: (sex) {
      gender = sex;
      setState(() {});
    });
  }

  showPickerDateTime(String birth, BuildContext context) async {
    if (birth == null) birth = '1998-01-01';

    final _birth = DateTime.parse(birth);

    final last = DateTime.now();
    final first = last.subtract(Duration(days: 100 * 365));

    final date = await showDatePicker(
      context: context,
      firstDate: first,
      lastDate: last,
      initialDate: _birth,
    );

    if (date != null) {
      final newBirth = date.millisecondsSinceEpoch;
      this.birth = dateFormat(newBirth);
      setState(() {});
    }
  }

  Widget xItem(Item item) {
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: item.onTop,
        child: Container(
          height: 60,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(item.label,
                  style: TextStyle(color: AppPalette.tips, fontSize: 14)),
              Expanded(
                child: Text(
                  item.context,
                  textAlign: TextAlign.right,
                  style: TextStyle(color: item.color, fontSize: 14),
                ),
              ),
              Spacing.w10,
              Icon(Icons.arrow_forward_ios, size: 12, color: AppPalette.hint)
            ],
          ),
        ),
      ),
    );
  }
}

class Item {
  String label;
  String context;
  Color color;
  var onTop;

  Item(this.label, this.context, this.color, this.onTop);
}
