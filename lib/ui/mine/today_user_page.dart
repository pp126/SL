import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/tools/time.dart';
import 'package:app/ui/common/uid_box.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/mine/page/user_page.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

class TodayUserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar('今日访客'),
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
  Future fetchPage(PageNum page) => Api.User.dd(page);

  @override
  Widget itemBuilder(BuildContext context, Map item, int index) {
    return InkWell(
      child: Container(
        height: 80,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            AvatarView(
              url: item['avatar'],
              size: 48,
              side: BorderSide(width: 2, color: Colors.white),
            ),
            Spacing.w8,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item['nick'], style: TextStyle(fontSize: 14, color: AppPalette.txtDark)),
                  Spacing.h6,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      UidBox(data: item, hasBG: false),
                      Text(
                        TimeUtils.getNewsTimeStr(item['createTime']),
                        style: TextStyle(fontSize: 12, color: AppPalette.tips),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      onTap: () => Get.to(UserPage(uid: item['uid'])),
    );
  }

  @override
  BaseConfig initListConfig() {
    return ListConfig(
      divider: Divider(height: 1, indent: 73, endIndent: 15),
    );
  }
}
