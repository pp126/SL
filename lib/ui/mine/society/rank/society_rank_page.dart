import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/store/society_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/mine/society/edit/society_edit_page.dart';
import 'package:app/ui/mine/society/rank/society_search_page.dart';
import 'package:app/ui/mine/society/ui/society_uis.dart';
import 'package:app/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SocietyRankPage extends StatefulWidget {
  @override
  _SocietyRankPageState createState() => _SocietyRankPageState();
}

class _SocietyRankPageState extends State<SocietyRankPage> {
  Future<Map> getData() {
    return Api.Family.familyList(page: PageNum(index: 1, size: 20));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: xAppBar(
          '公会榜',
          action: [
            '搜索'.toImgActionBtn(onPressed: () => Get.to(SocietySearchPage())),
          ],
        ),
        body: SocietyCtrl.society(
          builder: (info, type) {
            bool canApplySociety = SocietyCtrl.obj.canApplySociety;

            return Stack(children: <Widget>[
              SocietyItem(),
              XFutureBuilder(
                futureBuilder: getData,
                onData: (value) {
                  return canApplySociety
                      ? Positioned(
                          bottom: 44,
                          left: 50,
                          right: 50,
                          child: Text(
                            '申请创办公会',
                            style: TextStyle(color: AppPalette.primary, fontSize: 14),
                          ).toBtn(40, AppPalette.txtWhite, radius: 100, onTap: onApplyTap))
                      : Container();
                },
              )
            ]);
          },
        ));
  }

  onApplyTap() {
    Get.to(SocietyEditDetailsPage(isAdd: true));
  }
}

class SocietyItem extends StatefulWidget {
  final int count;

  SocietyItem({
    this.count = 2,
  });

  @override
  _SocietyItemState createState() => _SocietyItemState();
}

class _SocietyItemState extends NetList<Map, SocietyItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  List<Map> transform(data) {
    return super.transform(data['familyList']);
  }

  @override
  Widget itemBuilder(BuildContext context, Map item, int index) {
    return SocietySubItem(data: item, index: index);
  }

  @override
  Future fetch() {
    return Api.Family.familyList(page: PageNum(index: 1, size: 10));
  }
}
