import 'package:app/common/theme.dart';
import 'package:app/net/host.dart';
import 'package:app/tools.dart';
import 'package:app/ui/web/web_page.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

class PresentationPage extends StatefulWidget {
  @override
  _PresentationPageState createState() => _PresentationPageState();
}

class _PresentationPageState extends State<PresentationPage> {
  RxString version = '1.0.0'.obs;

  @override
  Widget build(BuildContext context) {
    PackageInfo.fromPlatform().then((value) {
      version.value = value.version;
    });
    return Scaffold(
      appBar: xAppBar(
        '关于我们',
      ),
      backgroundColor: AppPalette.background,
      body: Column(
        children: [
          SizedBox(height: 20),
          Image.asset(IMG.$('logo'), width: 67, height: 67, scale: 3),
          SizedBox(height: 17),
          Text('多肉语音', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          SizedBox(height: 6),
          Obx(() => Text('Version: ${version.value}', style: TextStyle(fontSize: 14, color: Color(0xff908DA8)))),
          SizedBox(height: 40),
          TableView([
            TableGroup(
              [
                '用户协议',
                '隐私协议',
                '直播协议',
                '社区规定',
                '充值协议',
              ].map((e) => TableItem(title: e, onTap: () => onItemClick(e))).toList(),
              margin: EdgeInsets.symmetric(horizontal: 16),
              borderRadius: BorderRadius.all(Radius.circular(12)),
              backgroundColor: Colors.white,
              textStyle: TextStyle(fontSize: 14, color: AppPalette.dark),
              createDivider: () => _divider,
            )
          ], spacing: 10, itemExtent: 64)
        ],
      ),
    );
  }

  void onItemClick(String item) {
    switch (item) {
      case '用户协议':
        Get.to(AppWebPage(
          title: '用户协议',
          url: 'http://${host.host}/agreement/user.html',
        ));
        break;
      case '隐私协议':
        Get.to(AppWebPage(
          title: '隐私协议',
          url: 'http://${host.host}/agreement/userPrivacy.html',
        ));
        break;
      case '直播协议':
        Get.to(AppWebPage(
          title: '直播协议',
          url: 'http://${host.host}/agreement/broadcast.html',
        ));
        break;
      case '社区规定':
        Get.to(AppWebPage(
          title: '社区规定',
          url: 'http://${host.host}/agreement/community.html',
        ));
        break;
      case '充值协议':
        final url = GetPlatform.isIOS
            ? 'http://${host.host}/agreement/iosRecharge.html'
            : 'http://${host.host}/agreement/recharge.html';
        Get.to(AppWebPage(
          title: '充值协议',
          url: url,
        ));
        break;
    }
  }

  final _divider = PreferredSize(
    child: Divider(height: 1, indent: 32, endIndent: 32),
    preferredSize: Size.fromHeight(1),
  );
}
