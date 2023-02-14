import 'package:app/ui/mine/shop/my_gift_page.dart';
import 'package:app/ui/mine/shop/my_wear_page.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart' hide kToolbarHeight;

class MyPackagePage extends StatefulWidget {
  @override
  _MyPackagePageState createState() => _MyPackagePageState();
}

class _MyPackagePageState extends State<MyPackagePage> {
  final tabs = [
    {'title': Tab(text: '装扮'), 'page': MyWearPage()},
    {'title': Tab(text: '礼物'), 'page': MyGiftPage()},
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: xAppBar(
          xAppBar$TabBar(tabs.map((e) => e['title']).toList(growable: false)),
//          action: AppTextButton(
//            width: 60,
//            height: 40,
//            alignment: Alignment.centerRight,
//            title: Text(
//              '已过期',
//              style: TextStyle(fontSize: 12, color: AppPalette.dark),
//            ),
//            onPress: (){
//              Get.to(OutDateProductPage());
//            },
//          ),
        ),
        body: TabBarView(
          children: tabs.map((e) => e['page']).toList(growable: false),
        ),
      ),
    );
  }
}
