import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/ui/mine/activity/activity_detail_page.dart';
import 'package:app/ui/web/web_page.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

import '../../../tools.dart';

class HomeActPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar('活动'),
      backgroundColor: AppPalette.background,
      body: HomeActView(),
    );
  }
}

class HomeActView extends StatefulWidget {
  @override
  _HomeActViewState createState() => _HomeActViewState();
}

class _HomeActViewState extends State<HomeActView> {
  Future<List> getData() => Api.User.activityQuery();

  @override
  Widget build(BuildContext context) {
    return XFutureBuilder<List>(
      futureBuilder: getData,
      emptyType: TipsType.none,
      onData: (data) {
        return ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: data.length,
            itemBuilder: (_, i) => _ActItemView(data[i]),
            separatorBuilder: (_, __) => Spacing.h16);
      },
    );
  }
}

class _ActItemView extends StatelessWidget {
  final dynamic data;

  _ActItemView(this.data);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.to(AppWebPage(
          title: '活动详情',
          url: data['skipUrl'] + '?uid=${OAuthCtrl.obj.uid}&client=1')),
      child: Card(
        color: Colors.white,
        child: AspectRatio(
          aspectRatio: 343 / 100,
          child: NetImage(data['alertWinPic'], fit: BoxFit.fill),
        ),
      ),
    );
  }

  goToDetail(var data) => ActivityDetailPage.to(data);
}
