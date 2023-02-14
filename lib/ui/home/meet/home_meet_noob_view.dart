import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools/time.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/mine/page/user_page.dart';
import 'package:app/ui/room/room_page.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../tools.dart';

///萌新
class HomeMeetNoobView extends StatefulWidget {
  @override
  _HomeMeetNoobViewState createState() => _HomeMeetNoobViewState();
}

class _HomeMeetNoobViewState extends NetPageList<Map, HomeMeetNoobView> {
  @override
  Future fetchPage(PageNum page) => Api.Home.newUsers(page);

  @override
  Widget itemBuilder(BuildContext context, Map item, int index) => _ItemView(item);
}

class _ItemView extends StatelessWidget {
  final Map data;

  _ItemView(this.data);

  @override
  Widget build(BuildContext context) {
    var time = TimeUtils.getDateStrByMs(xMapStr(data, 'signTime'));
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => RoomPage.to(data['uid']),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => Get.to(UserPage(uid: data['uid'])),
                  child: AvatarView(
                    size: 62,
                    url: data['avatar'],
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(
                          data['nick'],
                          style: TextStyle(color: AppPalette.dark, fontSize: 15, fontWeight: fw$SemiBold),
                        ),
                        SizedBox(width: 10),
                        SvgPicture.asset(SVG.$('mine/性别_${data['gender']}')),
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
                      Text(xMapStr(data, 'userDescription', defaultStr: '小萌新来报道啦！欢迎来撩～'),
                          style: TextStyle(color: AppPalette.tips, fontSize: 15),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
