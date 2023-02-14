import 'dart:math';

import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/widgets/future_builder.dart';
import 'package:app/widgets/level_view.dart';
import 'package:app/widgets/num_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../widgets/custom_percentage_widget.dart';
import '../avatar_view.dart';

class LevelCharmPage extends StatefulWidget {
  @override
  _LevelCharmPageState createState() => _LevelCharmPageState();
}

class _LevelCharmPageState extends State<LevelCharmPage> {
  Future getData() {
    return Api.User.getLevelCharm();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: XFutureBuilder<dynamic>(
            futureBuilder: getData,
            onData: (data) {
              return Column(children: [
                userIofo(data),
                SizedBox(height: 2),
                titleView('等级特权'),
                SizedBox(height: 5),
                privilegeData(data),
                SizedBox(height: 41),
                titleView('等级说明'),
                SizedBox(height: 15),
                tipText('魅力等级象征用户在社区的魅力值，可通过收取礼物获得经验值，获得1海星=1经验值，累计足够的经验值后获得才美丽等级会自动升级'),
                SizedBox(height: 20),
                DefaultTextStyle(
                    style: TextStyle(color: AppPalette.dark, fontSize: 12),
                    child: xItem([Text('等级勋章'), Text('等级区间'), Text('所需经验')], bottom: 20)),
                ...[
                  [01, '崭露头角1', '1000'],
                  [09, '崭露头角9', '9000'],
                  [10, '小有名气1', '10000'],
                  [18, '小有名气9', '90000'],
                  [19, '声名远播1', '100000'],
                  [27, '声名远播9', '900000'],
                  [28, '风姿卓绝1', '1000000'],
                  [36, '风姿卓绝9', '9000000'],
                  [37, '艳压群芳1', '10000000'],
                  [45, '艳压群芳9', '90000000'],
                  [46, '风华绝代1', '100000000'],
                  [54, '风华绝代9', '900000000'],
                  [55, '魅者无疆', '1000000000'],
                ].map((e) {
                  return xItem([
                    LevelView(num: e[0], type: LevelType.charm),
                    Text(
                      '${e[1]}',
                      style: TextStyle(color: AppPalette.tips, fontSize: 12),
                    ),
                    Text(
                      '${e[2]}',
                      style: TextStyle(color: AppPalette.tips, fontSize: 12),
                    ),
                  ]);
                }).toList(growable: false),
                SizedBox(height: 75),
              ]);
            }));
  }

  userIofo(dynamic data) {
    int currentGoldNum = xMapStr(data, 'currentGoldNum', defaultStr: 0);
    int leftGoldNum = xMapStr(data, 'leftGoldNum', defaultStr: 0);
    int total = currentGoldNum + leftGoldNum;
    return Row(
      children: [
        Spacer(
          flex: 48,
        ),
        Text(
          '当前：$currentGoldNum',
          style: TextStyle(color: AppPalette.pink, fontSize: 10, height: 1),
        ).toAssImg(24, 'mine/level/魅力标签'),
        Spacer(
          flex: 20,
        ),
        Container(
            height: 97,
            width: 82,
            child: Stack(alignment: Alignment.center, children: [
              CustomCircularLoader(
                coveredPercent: 100 * data['levelPercent'],
                circleWidth: 4.0,
                circleSize: 82,
                circleStart: "bottom",
                circleColor: AppPalette.hint,
                coveredCircleColor: Color(0xffFF5BEA),
              ),
              AvatarView(
                url: data['avatar'],
                size: 74,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: NumView(
                  num: data['level'],
                  prefix: 'num/white/',
                  height: 12,
                  mainAxisAlignment: MainAxisAlignment.center,
                ).toAssImg(24, 'mine/level/魅力标题'),
              )
            ])),
        Spacer(
          flex: 20,
        ),
        Text(
          '升级：$total',
          style: TextStyle(color: AppPalette.pink, fontSize: 10, height: 1),
        ).toAssImg(24, 'mine/level/魅力标签', quarterTurns: 90),
        Spacer(
          flex: 48,
        ),
      ],
    );
  }

  ///标题
  titleView(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          SVG.$('mine/level/魅力翅膀'),
        ),
        SizedBox(
          width: 5,
        ),
        Text(
          '$title',
          style: TextStyle(color: AppPalette.pink, fontSize: 16),
        ),
        SizedBox(
          width: 5,
        ),
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(pi),
          child: SvgPicture.asset(SVG.$('mine/level/魅力翅膀')),
        )
      ],
    );
  }

  ///特权
  privilegeData(dynamic data) {
    return Row(
      children: [
        Spacer(
          flex: 39,
        ),
        Column(
          children: [
            CharmIcon(data: data, height: 24).toAssImg(100, 'mine/level/魅力背景'),
            SizedBox(
              height: 5,
            ),
            Text(
              '等级勋章',
              style: TextStyle(color: AppPalette.hint, fontSize: 12),
            ),
          ],
        ),
        Spacer(
          flex: 39,
        ),
      ],
    );
  }

  ///提示
  tipText(String tip) {
    return Row(
      children: [
        SizedBox(
          width: 16,
        ),
        Expanded(
          child: Text(
            '$tip',
            style: TextStyle(
              color: AppPalette.tips,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget xItem(List data, {double bottom = 17}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Center(
              child: data[0],
            ),
          ),
          Expanded(
            child: Center(
              child: data[1],
            ),
          ),
          Expanded(
            child: Center(
              child: data[2],
            ),
          ),
        ],
      ),
    );
  }
}
