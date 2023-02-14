import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/ui/common/svga_icon.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/room/room_page.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

///连麦聊
class HomeMeetChitchatView extends StatelessWidget {
  Future<List> getData() => Api.Home.getHomeChitchat();
  final _key = GlobalKey<XFutureBuilderState>();

  @override
  Widget build(BuildContext context) {
    return XFutureBuilder<List>(
      key: _key,
      futureBuilder: getData,
      onData: (data) {
        return RefreshIndicator(
          onRefresh: () async => _key.currentState.doRefresh(),
          child: ListView.builder(
            itemBuilder: (cont, index) {
              return _ItemView(data[index]);
            },
            itemCount: data.length,
          ),
        );
      },
    );
  }
}

class _ItemView extends StatelessWidget {
  final Map data;

  _ItemView(this.data);

  @override
  Widget build(BuildContext context) {
    var roomInfo = xMapStr(data, 'roomDTO');
    double w = 75;
    double h = 24;
    List useList = xMapStr(data, 'usersDTOS', defaultStr: []);
    if (useList != null && useList.length > 6) {
      useList = useList.sublist(0, 6);
    }
    return GestureDetector(
      onTap: joinRoom,
      child: Container(
        margin: EdgeInsets.only(left: 16, right: 16, bottom: 10),
        padding: EdgeInsets.all(20),
        decoration: new BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                RectAvatarView(
                  borderRadius: BorderRadius.circular(6),
                  url: roomInfo['avatar'],
                  size: 62,
                ),
                Expanded(
                    child: Column(children: [
                  Row(children: [
                    SizedBox(width: 10),
                    NetImage(xMapStr(roomInfo, 'tagPict'), width: 30, height: 15, fit: BoxFit.fill),
                    SizedBox(width: 8),
                    Text('ID:${roomInfo['roomId']}', style: TextStyle(color: AppPalette.primary, fontSize: 10))
                        .toTagView(15, AppPalette.txtWhite, padding: EdgeInsets.fromLTRB(8, 2, 8, 0)),
                    Spacing(),
                    SvgPicture.asset(SVG.$('home/热度')),
                    Text(xMapStr(roomInfo, 'onlineNum', defaultStr: 99).toString(),
                        style: TextStyle(color: AppPalette.pink, fontSize: 10))
                  ]),
                  Container(
                    width: double.infinity,
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 16, left: 10),
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                        color: AppPalette.background,
                        borderRadius: BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4))),
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(text: '快来加入 ', style: TextStyle(color: AppPalette.tips, fontSize: 15)),
                        TextSpan(
                            text: '${xMapStr(roomInfo, 'title', defaultStr: '房间')}',
                            style: TextStyle(color: AppPalette.dark, fontSize: 15)),
                        TextSpan(text: ' 吧！', style: TextStyle(color: AppPalette.tips, fontSize: 15)),
                      ]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ]))
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Row(
                      children: [
                        ...useList
                            .map(
                              (it) => Padding(
                                padding: EdgeInsets.only(right: 6),
                                child: AvatarView(url: it['avatar'], size: 24),
                              ),
                            )
                            ?.toList(),
                        SvgPicture.asset(SVG.$('home/加入房间')),
                      ],
                    ),
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(SVG.$('home/商城地板'), height: h, width: w, fit: BoxFit.fill),
                    Positioned(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 14,
                            child: AspectRatio(
                              aspectRatio: 160 / 100,
                              child: SVGAIcon(icon: 'wave'),
                            ),
                          ),
                          Text('进房间', style: TextStyle(color: Colors.white, fontSize: 10)),
                        ],
                      ).toBtn(
                        h,
                        Colors.transparent,
                        width: w,
                        onTap: joinRoom,
                      ),
                    )
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  joinRoom() {
    var roomInfo = xMapStr(data, 'roomDTO');
    RoomPage.to(roomInfo['uid']);
  }
}
