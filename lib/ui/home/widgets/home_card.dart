import 'package:app/common/theme.dart';
import 'package:app/tools.dart';
import 'package:app/ui/common/tag_icon.dart';
import 'package:app/ui/home/widgets/hot_tag.dart';
import 'package:app/ui/room/room_page.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeCard extends StatelessWidget {
  final Map data;
  final List<Widget> children;

  HomeCard(this.data, {this.children});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      color: Colors.white,
      shadowColor: AppPalette.primary.withAlpha(0x33),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkResponse(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(children: children),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Spacing.w10,
                    ...data['operatorStatus'] == 1
                        ? [
                            TagIcon(tag: data['tagPict'] ?? data['roomTagPic']),
                            Spacing.w4,
                            Expanded(
                              child: Text(
                                data['title'] ?? '',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12, color: Colors.black),
                              ),
                            ),
                          ]
                        : [
                            Center(
                              child: Text(
                                '房间休息中...',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12, color: Colors.black),
                              ),
                            )
                          ]
                  ],
                ),
              ),
            )
          ],
        ),
        onTap: () => RoomPage.to(data['uid']),
      ),
    );
  }
}

class RoomCard extends StatelessWidget {
  final Map data;

  static final gridDelegate = XGridDelegate(
    fixedHeight: 40,
    crossAxisCount: 2,
    childAspectRatio: 1,
    mainAxisSpacing: 16,
    crossAxisSpacing: 16,
  );

  RoomCard(this.data);

  @override
  Widget build(BuildContext context) {
    final String roomPwd = data['roomPwd'];

    Widget tag;

    switch (data['viewType']) {
      case -1:
        tag = Image.asset(IMG.$('日冠'), scale: 4);
        break;
      case 1:
        tag = Image.asset(IMG.$('活动'), scale: 4);
        break;
      case 2:
        tag = Image.asset(IMG.$('新厅'), scale: 4);
        break;
    }

    return HomeCard(
      data,
      children: <Widget>[
        Positioned.fill(child: NetImage(data['avatar'], fit: BoxFit.cover)),
        Positioned(
          left: 10,
          bottom: 0,
          child: Row(
            children: [
              HotTag(data['onlineNum']),
              Spacing.w8,
              Text(
                'ID: ${data['roomId'] ?? ''}',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 10, color: Colors.white),
              ).toWarp(
                color: Colors.black.withOpacity(0.2),
                radius: 2,
                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 6),
              ),
            ],
          ),
        ),
        if (tag != null) Positioned(top: 0, child: tag),
        if (!roomPwd.isBlank)
          Positioned(
            top: 13,
            right: 10,
            child: icon(
              SvgPicture.asset(SVG.$('home/房间上锁'), height: 10, width: 10),
              Colors.black,
            ),
          ),
      ],
    );
  }

  icon(child, bg) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      color: bg,
      child: Padding(padding: EdgeInsets.all(2.5), child: child),
    );
  }
}
