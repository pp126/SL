import 'dart:math';

import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/future_builder.dart';
import 'package:app/widgets/level_view.dart';
import 'package:app/widgets/num_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../widgets/custom_percentage_widget.dart';
import '../avatar_view.dart';

class LevelWealthPage extends StatefulWidget {
  @override
  _LevelWealthPageState createState() => _LevelWealthPageState();
}

class _LevelWealthPageState extends State<LevelWealthPage> {
  Future getData() {
    return Api.User.getLevelWealth();
  }

  @override
  Widget build(BuildContext context) {
    return OAuthCtrl.use(builder: (user) {
      String carUrl = xMapStr(user, 'carUrl');
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
                  tipText('财富等级象征用户尊贵的身份，可通过消费获得经验值，消费1海星=1经验值，累计足够的经验值后获得才财富的等级会自动升级'),
                  SizedBox(height: 20),
                  DefaultTextStyle(
                      style: TextStyle(color: Color(0xff252142), fontSize: 12),
                      child: xItem([Text('等级勋章'), Text('等级区间'), Text('所需经验')], bottom: 20)),
                  ...[
                    [01, '白鲸1', '1000'],
                    [09, '白鲸9', '9000'],
                    [10, '蓝鲸1', '10000'],
                    [18, '蓝鲸9', '90000'],
                    [19, '虎鲸1', '100000'],
                    [27, '虎鲸9', '900000'],
                    [28, '长须鲸1', '1000000'],
                    [36, '长须鲸9', '9000000'],
                    [37, '座头鲸1', '10000000'],
                    [45, '座头鲸9', '90000000'],
                    [46, '抹香鲸1', '100000000'],
                    [54, '抹香鲸9', '900000000'],
                    [55, '领航鲸', '1000000000'],
                  ].map((e) {
                    return xItem([
                      LevelView(
                        num: e[0],
                        type: LevelType.wealth,
                      ),
                      Text(
                        '${e[1]}',
                        style: TextStyle(color: AppPalette.tips, fontSize: 12),
                      ),
                      Text(
                        '${e[2]}',
                        style: TextStyle(color: AppPalette.tips, fontSize: 12),
                      )
                    ]);
                  }).toList(growable: false),
                  SizedBox(height: 75)
                ]);
              }));
    });
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
          style: TextStyle(color: AppPalette.primary, fontSize: 10, height: 1),
        ).toAssImg(24, 'mine/level/财富标签'),
        Spacer(
          flex: 20,
        ),
        Container(
            height: 97,
            width: 82,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomCircularLoader(
                  coveredPercent: 100 * data['levelPercent'],
                  circleWidth: 4.0,
                  circleSize: 82,
                  circleStart: "bottom",
                  circleColor: AppPalette.hint,
                  coveredCircleColor: Color(0xffD782FF),
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
                  ).toAssImg(24, 'mine/level/财富头像标题'),
                )
              ],
            )),
        Spacer(
          flex: 20,
        ),
        Text(
          '升级：$total',
          style: TextStyle(color: AppPalette.primary, fontSize: 10, height: 1),
        ).toAssImg(24, 'mine/level/财富标签', quarterTurns: 90),
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
          SVG.$('mine/level/财富翅膀'),
        ),
        SizedBox(
          width: 5,
        ),
        Text(
          '$title',
          style: TextStyle(color: AppPalette.primary, fontSize: 16),
        ),
        SizedBox(
          width: 5,
        ),
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(pi),
          child: SvgPicture.asset(SVG.$('mine/level/财富翅膀')),
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
            WealthIcon(data: data, height: 24).toAssImg(100, 'mine/level/等级背景'),
            Spacing.h6,
            Text(
              '等级勋章',
              style: TextStyle(color: AppPalette.hint, fontSize: 12),
            ),
          ],
        ),
        Spacer(
          flex: 39,
        ),
//        Column(
//          children: [
//            Padding(
//                    padding: const EdgeInsets.only(left: 15),
//                    child: Text(
//                      '',
//                      style: TextStyle(color: Colors.white, fontSize: 12),
//                    ))
//                .toAssImg(
//                  24,
//                  'mine/level/进场特效',
//                )
//                .toAssImg(100, 'mine/level/魅力背景'),
//            SizedBox(
//              height: 5,
//            ),
//            Text(
//              '进场特效',
//              style: TextStyle(color: AppPalette.hint, fontSize: 12),
//            ),
//          ],
//        ),
//        Spacer(
//          flex: 39,
//        ),
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
      padding: EdgeInsets.only(bottom: bottom),
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
