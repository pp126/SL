import 'package:app/event/moment_event.dart';
import 'package:app/net/api.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/tools/dialog.dart';
import 'package:app/ui/moment/moment_item_view.dart';
import 'package:app/ui/moment/post/post_sheet.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/list/list_page.dart';
import 'package:flutter/material.dart';

///我的动态
class MyMomentPage extends StatefulWidget {
  MyMomentPage({Key key}) : super(key: key);

  @override
  _MyMomentPageState createState() => _MyMomentPageState();
}

class _MyMomentPageState extends State<MyMomentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar(
        '我的动态',
        action: 'moment/post'.toSvgActionBtn( onPressed: showPostMomentSheet),
      ),
      body: MyMomentItem(),
    );
  }

  ///发布动态
  showPostMomentSheet() {
    return DialogUtils.showBottomSheet(context, PostTypeSheet());
  }
}

class MyMomentItem extends StatefulWidget {
  final int count;

  MyMomentItem({
    this.count = 2,
  });

  @override
  _MyMomentItemState createState() => _MyMomentItemState();
}

class _MyMomentItemState extends NetPageList<Map, MyMomentItem> {
  @override
  void initState() {
    super.initState();

    Bus.on<MomentEvent>((data) => doRefresh());
  }

  @override
  Future fetchPage(PageNum page) => Api.Moment.myMomentList(OAuthCtrl.obj.uid ?? '', page);

  @override
  Widget itemBuilder(BuildContext context, Map item, int index) {
    return MomentItemView(
      showFollow: false,
      data: item,
    );
  }
}
