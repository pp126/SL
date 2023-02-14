import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/store/red_envelope_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/tools/time.dart';
import 'package:app/ui/common/money_icon.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

class RedEnvelopeDetailPage extends StatelessWidget {
  final int id;
  final bool isOut;

  RedEnvelopeDetailPage(this.id, this.isOut);

  @override
  Widget build(BuildContext context) {
    final statusBarH = Get.statusBarHeight / Get.pixelRatio;
    final intW = Get.width;
    final imgH = intW * 181 / 374;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        alignment: Alignment.topLeft,
        children: [
          Positioned(
            width: intW,
            height: imgH,
            child: Image.asset(IMG.$('packet/顶部'), fit: BoxFit.fill, scale: 2),
          ),
          Positioned(
            top: statusBarH,
            child: xBackBtn(color: Colors.white),
          ),
          Positioned.fill(
            top: imgH - 72 / 2,
            child: XFutureBuilder(
              futureBuilder: () => Api.Packet.info(id),
              onData: (data) {
                final status =
                    RedEnvelopeCtrl.statusToName(data['packetStatus']);

                return Column(
                  children: [
                    AvatarView(url: data['avatar'], size: 72),
                    Spacing.h20,
                    Text(
                      '${data['nick']}的红包',
                      style: TextStyle(
                          fontSize: 16,
                          color: AppPalette.txtDark,
                          fontWeight: fw$SemiBold),
                    ),
                    Spacing.h8,
                    Text(
                      data['remark'],
                      style: TextStyle(fontSize: 12, color: AppPalette.tips),
                    ),
                    Spacing.h20,
                    ...status == '已领取' ? oo(data) : xx(data, status),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> xx(Map data, String status) {
    return [
      DefaultTextStyle(
        style: TextStyle(fontSize: 14, color: AppPalette.txtDark),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Spacing.w16,
            Text('红包金额'),
            Spacing.w16,
            Text(
              '${data['packetNum']}',
              style: TextStyle(color: Color(0xFFFF4A4A)),
            ),
            Spacing.h4,
            MoneyIcon(size: 20),
            Spacing.exp,
            Text(status),
            Spacing.w16,
          ],
        ),
      ),
      Spacing.h16,
      Divider(),
    ];
  }

  List<Widget> oo(Map data) {
    return [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${data['packetNum']}',
            style: TextStyle(
                fontSize: 36,
                color: Color(0xFFFF4A4A),
                fontWeight: fw$SemiBold),
          ),
          Spacing.h4,
          MoneyIcon(size: 32),
        ],
      ),
      Spacing.h20,
      Row(
        children: [
          Spacing.w16,
          Text(
            '1个红包，红包已被领取',
            style: TextStyle(fontSize: 14, color: AppPalette.txtDark),
          ),
        ],
      ),
      Spacing.h16,
      Divider(),
      Expanded(
        child: _ListView(
          [
            {
              'nick': data['targetNick'],
              'avatar': data['targetAvatar'],
              'time': data['updateTime'],
              'num': data['packetNum'],
            },
          ],
        ),
      ),
    ];
  }
}

class _ListView extends StatelessWidget {
  final List<Map> data;

  _ListView(this.data);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: data.length,
      itemBuilder: (_, i) => itemBuilder(data[i]),
      separatorBuilder: (_, __) => Divider(indent: 16, endIndent: 16),
    );
  }

  Widget itemBuilder(Map data) {
    return Container(
      height: 78,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          AvatarView(url: data['avatar'], size: 48),
          Spacing.w16,
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['nick'] ?? '',
                  style: TextStyle(fontSize: 14, color: AppPalette.txtDark),
                ),
                Spacing.h4,
                Text(
                  '${TimeUtils.getNewsTimeStr(data['time'])}',
                  style: TextStyle(fontSize: 12, color: AppPalette.tips),
                ),
              ],
            ),
          ),
          Text(
            '${data['num']}',
            style: TextStyle(
                fontSize: 16,
                color: Color(0xFFFF4A4A),
                fontWeight: fw$SemiBold),
          ),
          Spacing.h4,
          MoneyIcon(size: 20),
        ],
      ),
    );
  }
}
