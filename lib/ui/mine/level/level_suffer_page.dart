import 'dart:math';

import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/widgets/future_builder.dart';
import 'package:app/widgets/num_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../widgets/custom_percentage_widget.dart';
import '../avatar_view.dart';

class LevelSufferPage extends StatefulWidget {
  @override
  _LevelSufferPageState createState() => _LevelSufferPageState();
}

class _LevelSufferPageState extends State<LevelSufferPage> {
  Future getData(){
    return Api.User.getLevelExperience();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: XFutureBuilder<dynamic>(
            futureBuilder: getData, onData: (data) {
          return Column(children: [
            userIofo(data),
            SizedBox(height: 31),
            titleView('等级说明'),
            SizedBox(height: 15),
            tipText('经验等级象征用户在线时长，可通过在线获得经验值，在线1分钟=1经验值，累计足够的经验值后获得才经验的等级会自动升级'),
            SizedBox(height: 20),
          ]);
        }));
  }

  userIofo(dynamic data) {
    int currentGoldNum = xMapStr(data, 'currentGoldNum',defaultStr: 0);
    int leftGoldNum = xMapStr(data, 'leftGoldNum',defaultStr: 0);
    int total = currentGoldNum + leftGoldNum;
    return Row(
      children: [
        Spacer(
          flex: 48,
        ),
        Text(
          '当前：$currentGoldNum',
          style: TextStyle(color: Color(0xffFFA100), fontSize: 10,height: 1),
        ).toAssImg(24, 'mine/level/等级标签'),
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
                coveredCircleColor: Color(0xffFFD382),
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
                ).toAssImg(24, 'mine/level/等级标题'),
              )
            ])),
        Spacer(
          flex: 20,
        ),
        Text(
          '升级：$total',
          style: TextStyle(color: Color(0xffFFA100), fontSize: 10,height: 1),
        ).toAssImg(24, 'mine/level/等级标签', quarterTurns: 90),
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
          SVG.$('mine/level/等级翅膀'),
        ),
        SizedBox(
          width: 5,
        ),
        Text(
          '$title',
          style: TextStyle(color: Color(0xffFFA100), fontSize: 16),
        ),
        SizedBox(
          width: 5,
        ),
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(pi),
          child: SvgPicture.asset(SVG.$('mine/level/等级翅膀')),
        )
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
}
