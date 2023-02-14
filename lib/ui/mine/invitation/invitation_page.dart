import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/tools/common_utils.dart';
import 'package:app/tools/time.dart';
import 'package:app/ui/mine/invitation/invitation_dialog.dart';
import 'package:app/ui/mine/page/user_page.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/customer/app_text_button.dart';
import 'package:flutter/material.dart';

import '../avatar_view.dart';

class InvitationPage extends StatefulWidget {
  @override
  _InvitationPageState createState() => _InvitationPageState();
}

class _InvitationPageState extends State<InvitationPage> {
  String inviteCode;
  final _codekey = GlobalKey<XFutureBuilderState>();
  final _listkey = GlobalKey<XFutureBuilderState>();

  @override
  void initState() {
    super.initState();
  }

  Future<Map> getInviteCode() {
    return Api.User.getInviteCode();
  }

  Future<List> getInviteCodeRecord() {
    return Api.User.getInviteCodeRecord();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar(
        '我的邀请码',
        action: 'room/ic_share'.toSvgActionBtn(
          color: AppPalette.dark,
          onPressed: () async {
            final data = await getInviteCode();

            Get.dialog(InvitationDialog(data['url']));
          },
        ),
      ),
      backgroundColor: AppPalette.background,
      body: RefreshIndicator(
        onRefresh: () async {
          _codekey.currentState.doRefresh();
          _listkey.currentState.doRefresh();
          await Future.delayed(Duration(seconds: 1));
        },
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                XFutureBuilder(
                    key: _codekey,
                    futureBuilder: getInviteCode,
                    onData: (data) {
                      inviteCode = data['code'];
                      return Text(
                        inviteCode,
                        style: TextStyle(color: Color(0xff7C66FF), fontSize: 30, fontWeight: FontWeight.w600),
                      );
                    }),
                SizedBox(height: 6),
                Text(
                  '我的邀请码',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: Get.width,
                    child: Material(
                      color: Colors.white,
                      clipBehavior: Clip.antiAlias,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  '邀请记录',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                              ),
                              Spacing.h10,
                              XFutureBuilder<List>(
                                key: _listkey,
                                futureBuilder: getInviteCodeRecord,
                                onData: (data) {
                                  return ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (con, index) {
                                      return InkWell(
                                        onTap: () {
                                          var uid = data[index]['uid'];
                                          if (uid != null) Get.to(UserPage(uid: uid));
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                                          child: Row(
                                            children: [
                                              AvatarView(url: data[index]['avatar'], size: 50),
                                              Spacing.w10,
                                              Expanded(
                                                child: Text(
                                                  '${data[index]['nick']}',
                                                  style: TextStyle(fontSize: 16),
                                                ),
                                              ),
                                              Text(
                                                '${TimeUtils.getDateStrByDateTime(DateTime.fromMillisecondsSinceEpoch(data[index]['createTime']))}',
                                                style: TextStyle(fontSize: 14, color: Color(0xffCBC8DC)),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    itemCount: data.length,
                                  );
                                },
                                tipsSize: 250,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 36)
              ],
            ),
            _bottom()
          ],
        ),
      ),
    );
  }

  Widget _bottom() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 44,
      child: AppTextButton(
        width: double.infinity,
        height: 40,
        bgColor: AppPalette.primary,
        margin: EdgeInsets.symmetric(horizontal: 50),
        borderRadius: BorderRadius.all(Radius.circular(20)),
        title: Text(
          '复制我的邀请码',
          style: TextStyle(fontSize: 14, color: Colors.white),
        ),
        onPress: () {
          if (inviteCode != null) CommonUtils.copyToClipboard('$inviteCode');
        },
      ),
    );
  }
}
