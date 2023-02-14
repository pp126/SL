import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/ui/common/money_icon.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RankBottomSheet extends StatelessWidget {
  final int drawType;

  RankBottomSheet(this.drawType);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 460,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 20, left: 20, bottom: 15),
            child: Text('每日榜单', style: TextStyle(fontSize: 16, color: AppPalette.txtWhite, fontWeight: fw$SemiBold)),
          ),
          Expanded(child: RankBottomView(drawType))
        ],
      ),
    );
  }
}

class RankBottomView extends StatefulWidget {
  final int drawType;

  RankBottomView(this.drawType);

  @override
  _RankBottomViewState createState() => _RankBottomViewState();
}

class _RankBottomViewState extends NetPageList<Map, RankBottomView> {
  @override
  Widget itemBuilder(BuildContext context, Map item, int index) => xItme(item, index);

  @override
  Future fetchPage(PageNum page) {
    return Api.User.getTopRank(widget.drawType, page.index, page.size);
  }

  xItme(Map item, int index) {
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            child: Center(
              child: crown != null
                  ? crown
                  : Text(index.toString(), style: TextStyle(color: AppPalette.tips, fontSize: 16)),
            ),
          ),
          Material(
            color: Colors.white,
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.all(Radius.circular(100)),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: AvatarView(
                size: 38,
                url: item['avatar'],
              ),
            ),
          ),
          SizedBox(width: 14),
          Expanded(child: Text(xMapStr(item, 'nick'), style: TextStyle(color: AppPalette.txtWhite, fontSize: 14))),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MoneyIcon(size: 22),
              Text(
                '${xMapStr(item, 'goldCost')}',
                style: TextStyle(fontSize: 14, color: Color(0xff7C66FF)),
              ),
            ],
          )
        ],
      ),
    );
  }
}
