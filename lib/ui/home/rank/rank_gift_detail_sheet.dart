import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/customer/app_icon_button.dart';
import 'package:app/widgets/level_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RankGiftDetailSheet extends StatelessWidget {
  final giftData;
  final int index;
  final String type;

  RankGiftDetailSheet({
    this.giftData,
    this.index,
    this.type,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 458,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('礼物详情', style: TextStyle(fontSize: 16, color: AppPalette.dark, fontWeight: fw$SemiBold)),
                AppIconButton(
                    icon: Icon(
                      Icons.close,
                      size: 24,
                      color: AppPalette.dark,
                    ),
                    onPress: () {
                      Navigator.pop(context);
                    }),
              ],
            ),
          ),
          Expanded(
              child: RankBottomView(
            giftData: giftData,
            index: index,
            type: type,
          ))
        ],
      ),
    );
  }
}

class RankBottomView extends StatefulWidget {
  final giftData;
  final int index;
  final String type;

  RankBottomView({
    this.giftData,
    this.index,
    this.type,
  });

  @override
  _RankBottomViewState createState() => _RankBottomViewState();
}

class _RankBottomViewState extends NetList<Map, RankBottomView> {
  @override
  Widget itemBuilder(BuildContext context, Map item, int index) => xItem(item, index);

  @override
  Future fetch() {
    return Api.Rank.getRankGiftDetailList(widget.type, '${widget.giftData['giftId']}');
  }

  @override
  BaseConfig initListConfig() {
    return ListConfig(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
    );
  }

  @override
  Widget transformWidget(BuildContext context, Widget child) => SingleChildScrollView(
        child: Column(
          children: [_buildHeaderItem(), child],
        ),
      );

  _buildHeaderItem() {
    var data = widget.giftData;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RectAvatarView(
          size: 47,
          url: data['picUrl'],
          radius: 12.0,
        ),
        Spacing.w8,
        Container(
          height: 47,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(xMapStr(data, 'giftName'), style: TextStyle(color: AppPalette.dark, fontSize: 14)),
              Text('礼物榜第 ${(widget.index ?? 0) + 1} 名', style: TextStyle(color: AppPalette.tips, fontSize: 12)),
            ],
          ),
        ),
        Spacing.exp,
        Row(children: [
          // MoneyIcon(size: 20),
          Text('${xMapStr(data, 'giftNum', defaultStr: 0)}个',
              style: TextStyle(color: AppPalette.primary, fontSize: 14)),
        ]),
      ],
    ).toTagView(
      80,
      AppPalette.background,
      radius: 12,
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.symmetric(
        horizontal: 16,
      ),
    );
  }

  xItem(Map item, int index) {
    SvgPicture crown;
    switch (index) {
      case 0:
      case 1:
      case 2:
        crown = SvgPicture.asset(
          SVG.$('home/rank/crown_${index + 1}'),
          width: 26,
          height: 26,
        );
        break;
    }
    bool isMan = xMapStr(item, 'gender') == 1;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            constraints: BoxConstraints(minWidth: 26),
            child: Center(
              child: crown != null
                  ? crown
                  : Text(index.toString(), style: TextStyle(color: AppPalette.tips, fontSize: 16)),
            ),
          ),
          Spacing.w8,
          RectAvatarView(
            size: 47,
            url: item['avatar'],
            uid: xMapStr(item, 'uid', defaultStr: null),
            radius: 12.0,
          ),
          Spacing.w8,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(xMapStr(item, 'nick'), style: TextStyle(color: AppPalette.dark, fontSize: 14)),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                SvgPicture.asset(SVG.$('mine/性别_${isMan ? 1 : 2}')),
                Spacing.w4,
                WealthIcon(data: item),
              ]),
            ],
          ),
          Spacing.exp,
          Row(children: [
            // MoneyIcon(size: 20),
            Text('${xMapStr(item, 'giftNum', defaultStr: 0)}个',
                style: TextStyle(color: AppPalette.primary, fontSize: 14)),
          ]),
        ],
      ),
    );
  }
}
