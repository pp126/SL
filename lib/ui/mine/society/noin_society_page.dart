import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/store/society_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/mine/society/rank/society_rank_page.dart';
import 'package:app/ui/mine/society/ui/society_uis.dart';
import 'package:app/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NoinSocietyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData(
            appBarTheme:
                AppBarTheme(shadowColor: Colors.white, color: Colors.transparent, elevation: 0, centerTitle: false)),
        child: Scaffold(
            backgroundColor: AppPalette.hint,
            appBar: xAppBar(
              '我的公会',
              style: TextStyle(color: Colors.white, fontSize: 16),
              action: 'mine/society/奖杯白'.toSvgActionBtn(onPressed: () => Get.to(SocietyRankPage())),
            ),
            body: SocietyCtrl.society(
              builder: (info, type) {
                String tips = '';
                bool isApply = false;
                switch (type) {
                  case UserSocietyType.noSociety:
                    tips = '您还没有加入公会呢';
                    break;
                  case UserSocietyType.applyJoinSociety:
                    {
                      tips = '正在申请加入 ${info['familyName']} 公会';
                      isApply = true;
                    }
                    break;
                }
                bool canApply = SocietyCtrl.obj.canApplySociety;
                return Container(
                  height: Get.height,
                  color: Colors.white,
                  child: RefreshIndicator(
                    onRefresh: () async {
                      Bus.send(CMD.societyListreRresh);
                      await Future.delayed(Duration(milliseconds: 1000));
                    },
                    child: NotificationListener(
                      onNotification: _onNotification,
                      child: SingleChildScrollView(
                          physics: ClampingScrollPhysics(),
                          child: Stack(children: [
                            Container(
                              color: AppPalette.hint,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.only(top: 30, bottom: 60),
                              child: Column(
                                children: [
                                  Text(tips, style: TextStyle(color: AppPalette.txtWhite, fontSize: 14)),
                                  if (isApply)
                                    Container(
                                      padding: const EdgeInsets.only(top: 5),
                                      width: 80,
                                      child: XCancelApplySociety(
                                          data: info, refreshCallBack: () => SocietyCtrl.obj.doRefresh()),
                                    ),
                                ],
                              ),
                            ),
                            Container(
                                width: Get.width,
                                margin: EdgeInsets.only(top: 100),
                                padding: EdgeInsets.only(top: 20),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(12.0), topRight: Radius.circular(12.0)),
                                    color: Colors.white),
                                child: SocietyList(canApply))
                          ])),
                    ),
                  ),
                );
              },
            )));
  }

  bool _onNotification(ScrollUpdateNotification e) {
    if (e.depth == 0 && e.scrollDelta > 0) {
      final metrics = e.metrics;
      if (metrics is ScrollMetrics) {
        final max = metrics.maxScrollExtent;
        final height = metrics.viewportDimension;
        final curr = metrics.pixels;
        if ((curr + height) > max) onEnd();
      }
    }
    return false;
  }

  void onEnd() => Bus.send(CMD.societyListNext);
}

class SocietyList extends StatefulWidget {
  final bool canApply;

  SocietyList(this.canApply);

  @override
  _SocietyListState createState() => _SocietyListState();
}

class _SocietyListState extends NetPageList<Map, SocietyList> {
  @override
  void initState() {
    super.initState();
    Bus.sub(CMD.societyListreRresh, (data) => doRefresh());
    Bus.sub(CMD.societyListNext, (data) => next());
  }

  @override
  List<Map> transform(data) {
    return super.transform(data['familyList']);
  }

  @override
  Future fetchPage(PageNum page) => Api.Family.familyList(page: page);

  @override
  Widget itemBuilder(BuildContext context, Map item, int index) {
    return SocietySubItem(
        data: item,
        index: index,
        showApply: widget.canApply,
        showCancelApply: false,
        refreshCallBack: () => SocietyCtrl.obj.doRefresh());
  }

  @override
  BaseConfig initListConfig() {
    return ListConfig(shrinkWrap: true, physics: NeverScrollableScrollPhysics());
  }
}
