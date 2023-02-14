import 'package:app/ui/message/fans_list_view.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

///我的粉丝
class MyFanPage extends StatefulWidget {
  MyFanPage({Key key}) : super(key: key);

  @override
  _MyFanPageState createState() => _MyFanPageState();
}

class _MyFanPageState extends State<MyFanPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar('粉丝'),
      body: FansListView(
        showFans: true,
        showLike: true,
      ),
    );
  }
}
