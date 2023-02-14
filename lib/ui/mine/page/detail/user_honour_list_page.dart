import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/list/list_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum HonourType {
  gift, //礼物墙
  car, //座驾
  head, //头饰
}

class UserHonourListPage extends StatefulWidget {
  final int uid;
  final HonourType type;
  final int dataType;

  UserHonourListPage({
    this.uid,
    this.type = HonourType.gift,
    this.dataType,
  });

  @override
  _UserHonourListPageState createState() => _UserHonourListPageState();
}

class _UserHonourListPageState extends NetList<Map, UserHonourListPage> {
  @override
  Future fetch() {
    String userId = widget.uid.toString();
    int type = widget.dataType;
    switch (widget.type) {
      case HonourType.gift:
        return Api.User.userGiftList(
          userId: userId,
          type: type,
        );
        break;
      case HonourType.head:
        return Api.User.userHeadList(
          userId: userId,
          type: type,
        );
        break;
      case HonourType.car:
        return Api.User.userCarList(
          userId: userId,
          type: type,
        );
        break;
    }
  }

  @override
  List<Map> transform(data) {
    return super.transform(data['list']);
  }

  @override
  Widget itemBuilder(BuildContext context, Map item, int index) {
    return xItem(
      item,
    );
  }

  @override
  BaseConfig initListConfig() {
    return GridConfig(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 108 / 150,
        mainAxisSpacing: 15,
        crossAxisSpacing: 10,
      ),
    );
  }

  Widget xItem(Map data) {
    final item = {
      HonourType.gift: [
        'picUrl',
        'giftName',
      ],
      HonourType.car: [
        'picUrl',
        'giftName',
      ],
      HonourType.head: [
        'picUrl',
        'giftName',
      ],
    }[widget.type];

    bool isHave = xMapStr(data, 'isHave', defaultStr: false);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
          isHave ? Color(0xffC69FFF) : Color(0xffF1EEFF),
          isHave ? Color(0xff7C66FF) : Color(0xffF1EEFF),
        ]),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
                  isHave ? Color(0xffA183FF) : Color(0xffFAF9FE),
                  isHave ? Color(0xff7C66FF) : Color(0xffFAF9FE),
                ]),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              width: double.infinity,
              height: double.infinity,
              child: NetImage(
                xMapStr(
                  data,
                  item[0],
                ),
                fit: BoxFit.cover,
                color: isHave ? null : Color(0xCCFAF9FE),
                colorBlendMode: isHave ? null : BlendMode.hardLight,
              ),
            ),
          ),
          Spacing.h4,
          Text(
            xMapStr(data, item[1]),
            style: TextStyle(fontSize: 14, color: isHave ? Colors.white : Color(0xffCBC8DC)),
          ),
        ],
      ),
    );
  }
}
