import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools/time.dart';
import 'package:app/ui/moment/comment/coment_page.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/level_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../tools.dart';

///新鲜事
class HomeMeetFreshView extends StatefulWidget {
  @override
  _HomeMeetFreshViewState createState() => _HomeMeetFreshViewState();
}

class _HomeMeetFreshViewState extends NetPageList<Map, HomeMeetFreshView> {
  @override
  Future fetchPage(PageNum page) => Api.Home.dynamicList(page);

  @override
  Widget itemBuilder(BuildContext context, Map item, int index) => _ItemView(item);
}

class _ItemView extends StatelessWidget {
  final Map data;

  _ItemView(this.data);

  @override
  Widget build(BuildContext context) {
    var userInfo = xMapStr(data, 'usersDTO');
    var dynamicInfo = xMapStr(data, 'userDynamic');
    bool isMan = xMapStr(userInfo, 'gender') == 1;
    var time = TimeUtils.getDateStrByMs(xMapStr(dynamicInfo, 'createTime'));

    return GestureDetector(
      onTap: () {
        Get.to(CommentPage(momentData: data));
      },
      child: Container(
        margin: EdgeInsets.only(left: 16, right: 16, bottom: 10),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(12))),
        child: Row(
          children: [
            ClipOval(
              child: NetImage(
                '${xMapStr(userInfo, 'avatar')}',
                width: 62,
                height: 62,
                fit: BoxFit.fitWidth,
              ),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('${xMapStr(userInfo, 'nick')}',
                      style: TextStyle(color: AppPalette.dark, fontSize: 15, fontWeight: fw$SemiBold)),
                  SizedBox(width: 10),
                  SvgPicture.asset(SVG.$(isMan ? 'mine/性别_1' : 'mine/性别_2')),
                  SizedBox(width: 10),
                  WealthIcon(data: data),
                  SizedBox(width: 6),
                  CharmIcon(data: data),
                ]),
                SizedBox(height: 10),
                Row(
                  children: [
                    SvgPicture.asset(SVG.$('home/定位')),
                    SizedBox(width: 6),
                    Text('在月亮之上  |  $time发布', style: TextStyle(color: AppPalette.hint, fontSize: 10)),
                  ],
                ),
                SizedBox(height: 10),
                Text(xMapStr(dynamicInfo, 'comtent'), style: TextStyle(color: AppPalette.tips, fontSize: 15)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
