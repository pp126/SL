import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/ui/mine/activity/activity_detail_page.dart';
import 'package:app/ui/web/web_page.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/future_builder.dart';
import 'package:flutter/material.dart';

class ActivityPage extends StatefulWidget {
  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  Future<List> getHotData(){
    return Api.User.activityQuery();
  }
  Future<List> getAllData(){
    return Api.User.activityAll();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: xAppBar('活动'),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  Text(
                    '热门活动',
                    style: TextStyle(color: AppPalette.dark, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Spacing.h12,
                  XFutureBuilder<List>(
                      futureBuilder: getHotData,
                      emptyType: TipsType.none,
                      onData: (data) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...activitys("热门活动", data),
                      ],
                    );
                  }),
                  Spacing.h12,
                  Text(
                    '全部活动',
                    style: TextStyle(color: AppPalette.dark, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Spacing.h12,
                  XFutureBuilder<List>(
                    futureBuilder: getAllData,
                    emptyType: TipsType.none,
                    onData: (data) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...activitys("全部活动", data),
                      ],
                    );
                  },onEmpty: _onEmpty,)
                ]))));
  }

  static Widget _onEmpty({msg}) {
    return SizedBox.shrink();
  }

  List<Widget> activitys(String title, List<dynamic> list) {
    return [
      ...list
          .map((e) => GestureDetector(
            onTap: (){
              ActivityDetailPage.to(e);
            },
            child: Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: AspectRatio(
                    aspectRatio: 344 / 126,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppPalette.hint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: NetImage('${e['alertWinPic']}', fit: BoxFit.fill),
                      ),
                    ),
                  ),
                ),
          ))
          .toList(growable: false),
    ];
  }
}

class Item {
  String url;
  String img;

  Item(this.url, this.img);
}
