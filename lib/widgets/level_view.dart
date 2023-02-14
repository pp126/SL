import 'package:app/tools.dart';
import 'package:flutter/material.dart';

enum LevelType { wealth, charm }

class LevelView extends StatelessWidget {
  final int num;
  final double height;
  final String type;

  LevelView({this.num, LevelType type, this.height = 24}) : type = type.toString().split('.').last;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: AspectRatio(
        aspectRatio: 154 / 49,
        child: Image.asset(IMG.$('level/$type/$num'), scale: 2),
      ),
    );
  }
}

class WealthIcon extends StatelessWidget {
  final Map data;
  final double height;

  WealthIcon({this.data, this.height = 16});

  @override
  Widget build(BuildContext context) {
    int num;

    try {
      num = int.parse('${data['wealthLevel'] ?? data['wealth'] ?? data['wealth_level'] ?? data['level']}');
    } catch (e) {
      xlog('财富取值失败 -> $data');

      num = 0;
    }

    return LevelView(num: num, height: height, type: LevelType.wealth);
  }
}

class CharmIcon extends StatelessWidget {
  final Map data;
  final double height;

  CharmIcon({this.data, this.height = 16});

  @override
  Widget build(BuildContext context) {
    int num;

    try {
      num = int.parse('${data['charmLevel'] ?? data['charm_level'] ?? data['level']}');
    } catch (e) {
      xlog('魅力取值失败 -> $data');

      num = 0;
    }

    return LevelView(num: num, height: height, type: LevelType.charm);
  }
}
