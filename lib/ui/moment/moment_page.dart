import 'package:app/common/theme.dart';
import 'package:app/tools/dialog.dart';
import 'package:app/ui/moment/moment_index_view.dart';
import 'package:app/ui/moment/post/post_sheet.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart' hide kToolbarHeight;

///动态首页
class MomentPage extends StatefulWidget {
  MomentPage({Key key}) : super(key: key);

  @override
  _MomentPageState createState() => _MomentPageState();
}

class _MomentPageState extends State<MomentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar(
        "动态",
        style:TextStyle(fontSize: 20,color: AppPalette.dark,fontWeight: fw$SemiBold),
        action: 'moment/post'.toSvgActionBtn( onPressed: showPostMomentSheet),
      ),
      backgroundColor: AppPalette.background,
      body: MomentIndexView(),
    );
  }

  ///发布动态
  showPostMomentSheet() {
    return DialogUtils.showBottomSheet(context, PostTypeSheet());
  }
}
