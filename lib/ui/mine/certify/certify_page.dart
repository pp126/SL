import 'package:app/ui/mine/certify/fast_certify.dart';
import 'package:app/ui/mine/certify/zfb_certify.dart';
import 'package:app/ui/mine/service/servic_page.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart' hide kToolbarHeight;
import 'package:get/get.dart';

class CertifyPage extends StatefulWidget {
  @override
  _CertifyPageState createState() => _CertifyPageState();
}

class _CertifyPageState extends State<CertifyPage> {
  final tabs = [
    //todo 隐藏快捷认证
    // {'title': Tab(text: '快捷认证'), 'page': ZFBCertifyPage()},
    {'title': Tab(text: '普通认证'), 'page': FastCertifyPage()},
  ];

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   appBar: xAppBar('身份认证',
    //       action: '客服'.toTxtActionBtn(
    //         onPressed: () {
    //           Get.to(ServicPage());
    //         },
    //       ),
    //       marginRight: Spacing.w16),
    //   body: FastCertifyPage(),
    // );
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: xAppBar(
          xAppBar$TabBar(tabs.map((e) => e['title']).toList(growable: false)),
          action: '客服'.toTxtActionBtn(
            onPressed: () {
              Get.to(ServicPage());
            },
          ),
        ),
        body: TabBarView(
          children: tabs.map((e) => e['page']).toList(growable: false),
        ),
      ),
    );
  }
}
