import 'package:app/common/theme.dart';
import 'package:app/event/moment_event.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/mine/page/user_page.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

class RoomBlackListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar('黑名单管理'),
      body: _ListView(),
    );
  }
}

class _ListView extends StatefulWidget {
  @override
  _ListViewState createState() => _ListViewState();
}

class _ListViewState extends NetPageList<Map, _ListView> {
  @override
  Future fetchPage(PageNum page) {
    return Api.Moment.blackList(page);
  }

  @override
  Widget itemBuilder(BuildContext context, Map item, int index) => _ItemView(item, () {
        doRefresh();
      });

  @override
  BaseConfig initListConfig() {
    return super.initListConfig();
  }
}

class _ItemView extends StatelessWidget {
  final Map data;
  final VoidCallback refreshCallBack;

  _ItemView(this.data, this.refreshCallBack);

  @override
  Widget build(BuildContext context) {
    var dynamicBlacklistId = xMapStr(data, 'dynamicBlacklistId').toString();
    var name = xMapStr(data, 'nick', defaultStr: '');
    var userDesc = xMapStr(data, 'userDesc', defaultStr: "");
    var avatar = xMapStr(data, 'avatar', defaultStr: '');
    var uid = xMapStr(data, 'uid');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 5),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                  onTap: () => Get.to(UserPage(uid: uid)),
                  child: AvatarView(
                    size: 48,
                    url: avatar,
                  )),
              Spacing.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      name,
                      style: TextStyle(fontSize: 14, color: AppPalette.dark, fontWeight: fw$SemiBold),
                    ),
                    Text(
                      userDesc,
                      style: TextStyle(fontSize: 12, color: AppPalette.tips),
                    ),
                  ],
                ),
              ),
              Material(
                color: AppPalette.txtWhite,
                shape: StadiumBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  child: Container(
                    width: 70,
                    height: 26,
                    alignment: Alignment.center,
                    child: Text(
                      '删除黑名单',
                      style: TextStyle(fontSize: 10, color: AppPalette.primary),
                    ),
                  ),
                  onTap: () {
                    simpleSub(() async {
                      final value = await Api.Moment.delBlack(
                        blackId: dynamicBlacklistId,
                      );
                      Bus.fire(MomentEvent());
                      if (refreshCallBack != null) {
                        refreshCallBack();
                      }
                    }, msg: null);
                  },
                ),
              ),
            ],
          ),
          Spacing.h10,
          Divider(
            indent: 60,
            color: AppPalette.hint,
          ),
        ],
      ),
    );
  }
}
