import 'package:app/ui/message/follow_list_view.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

///我的关注
class MyFollowPage extends StatefulWidget {
  MyFollowPage({Key key}) : super(key: key);

  @override
  _MyFollowPageState createState() => _MyFollowPageState();
}

class _MyFollowPageState extends State<MyFollowPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar('关注'),
      body: FollowListView(
        showFans: true,
        showLike: true,
      ),
    );
  }
}
