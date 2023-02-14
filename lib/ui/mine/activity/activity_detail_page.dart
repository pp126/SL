import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/web/web_page.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class ActivityDetailPage extends StatefulWidget {
  final Map data;

  ActivityDetailPage._({this.data});

  ///活动跳转
  static to(Map data) {
    if (data != null) {
      int skipType = xMapStr(data, 'skipType', defaultStr: 0);
      switch (skipType) {
        case 2: //富文本展示
          Get.to(ActivityDetailPage._(data: data));

          return;
        case 1: //跳H5链接
          Get.to(
            AppWebPage(
              title: data['actName'] ?? data['bannerName'],
              url: data['skipUrl']+'?uid=${OAuthCtrl.obj.uid}&client=1',
            ),
          );

          return;
        default:
          if (isDebug) {
            showToast('参数有误，无法跳转！');
          }
      }
    }
  }

  @override
  _ActivityDetailPageState createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar('活动详情'),
      body: SingleChildScrollView(
        child: getDetailWebViewWidget(),
      ),
    );
  }

  Widget getDetailWebViewWidget() {
    final info = widget.data['skipUrl'] ?? widget.data['skipUri'];

    if (info == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Html(data: info),
    );
  }
}
