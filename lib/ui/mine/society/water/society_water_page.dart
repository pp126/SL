import 'package:app/common/bus_key.dart';
import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/store/society_ctrl.dart';
import 'package:app/tools/time.dart';
import 'package:app/ui/mine/society/water/water_list.dart';
import 'package:app/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../tools.dart';

class SocietyWaterPage extends StatelessWidget {
  RxMap timers = {
    'start': TimeUtils.getDateStrByDateTime(TimeUtils.dateDayBegin(DateTime.now())),
    'end': TimeUtils.getDateStrByDateTime(DateTime.now()),
  }.obs;
  DateTime newDate;
  RxList datas = [].obs;
  TabController controller;

  doRefresh() {
    SocietyCtrl.obj.doRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar('公会流水'),
      backgroundColor: AppPalette.background,
      endDrawer: $Drawer(_tabsSelect()),
      body: SocietyCtrl.society(builder: (data, type) {
        return Column(
          children: [
            _timerCheck(),
            Expanded(
              child: XFutureBuilder<List>(
                futureBuilder: () {
                  return Api.Family.getRoomInfo(familyId: data['familyId'], pageNum: 1, pageSize: 1000);
                },
                onData: (data) {
                  datas.value = data;
                  return DefaultTabController(
                      length: data.length,
                      child: Builder(
                        builder: (context) {
                          controller = DefaultTabController.of(context);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TabBar(
                                isScrollable: true,
                                tabs: data.map((it) => Tab(text: '${it['title']}')).toList(growable: false),
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: data.map((e) => WaterList(timers, e['uid'], '总流水')).toList(growable: false),
                                ),
                              ),
                            ],
                          );
                        },
                      ));
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  _tabsSelect() {
    // DefaultTabController.of(context)
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '选择房间',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Spacing.h20,
              Expanded(
                child: ListView.builder(
                    itemCount: datas.value.length,
                    itemBuilder: (context, item) {
                      bool check = item == controller.index;
                      return Text(
                        '${datas.value[item]['title']}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: check ? Colors.white : Color(0xff908DA8), fontSize: 14),
                      ).toBtn(40, check ? Color(0xff7C66FF) : Color(0xffFAF9FE),
                          radius: 4, margin: EdgeInsets.symmetric(vertical: 5), onTap: () {
                        controller.index = item;
                        Get.back();
                      });
                    }),
              )
            ],
          ),
        ));
  }

  Widget $Drawer(Widget child) {
    return FractionallySizedBox(
      heightFactor: 1,
      widthFactor: 0.5,
      child: Material(
        color: Colors.white,
        child: SafeArea(child: child),
      ),
    );
  }

  _timerCheck() {
    return Builder(builder: (context) {
      return Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => showDatePicker(context, 'start'),
                  child: Text(timers.value['start'],
                      textAlign: TextAlign.end, style: TextStyle(color: Color(0xff7C66FF), fontSize: 14)),
                ),
              ),
              Spacing.w6,
              Text('至', style: TextStyle(color: Color(0xffCBC8DC), fontSize: 14)),
              Spacing.w6,
              Expanded(
                child: InkWell(
                  onTap: () => showDatePicker(context, 'end'),
                  child: Text(timers.value['end'], style: TextStyle(color: Color(0xff7C66FF), fontSize: 14)),
                ),
              )
            ],
          ).toTagView(30, Color(0xffF1EEFF), radius: 4, margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10)));
    });
  }

  showDatePicker(BuildContext context, String key) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        return _BottomPicker(
            context,
            CupertinoDatePicker(
              backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
              mode: CupertinoDatePickerMode.dateAndTime,
              initialDateTime: TimeUtils.getDateTime(timers.value[key]),
              use24hFormat: true,
              onDateTimeChanged: (newDate) {
                this.newDate = newDate;
              },
            ), (selectDate) {
          timers[key] = TimeUtils.getDateStrByDateTime(selectDate);
          Bus.send(BUS_SOCIETY_WATER_LIST_REFRESH);
        });
      },
    );
  }

  Widget _BottomPicker(BuildContext context, CupertinoDatePicker child, ValueChanged<DateTime> changed) {
    return DefaultTextStyle(
      style: TextStyle(
        color: CupertinoColors.label.resolveFrom(context),
        fontSize: 16,
      ),
      child: Container(
        height: 300,
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                    onTap: () {
                      newDate = null;
                      Get.back();
                    },
                    child: Text('取消')),
                GestureDetector(
                    onTap: () {
                      if (newDate != null) {
                        changed(newDate);
                      }
                      Get.back();
                    },
                    child: Text('确定')),
              ],
            ),
            Spacing.h10,
            Expanded(
              child: GestureDetector(
                onTap: () {},
                child: SafeArea(
                  top: false,
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
