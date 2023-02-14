import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/store/red_envelope_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/red_envelope/red_envelope_detail_page.dart';
import 'package:flutter/material.dart';

class RedEnvelopeDialog extends StatelessWidget {
  final Map data;

  RedEnvelopeDialog._(this.data);

  static to(int id, bool isOut) {
    final api = Api.Packet.info(id);

    simpleSub(
      api,
      msg: null,
      callback: () async {
        final info = await api;
        final status = info['packetStatus'];

        RedEnvelopeCtrl.updateStatus(info['id'], status);

        switch (RedEnvelopeCtrl.statusToName(status)) {
          case '待领取':
            if (isOut) {
              Get.to(RedEnvelopeDetailPage(id, isOut));
            } else {
              Get.dialog(RedEnvelopeDialog._(info));
            }
            break;
          case '已领取':
            Get.to(RedEnvelopeDetailPage(id, isOut));
            break;
          case '红包已退回':
            showToast('红包已退回');
            break;
          case '红包已过期':
            showToast('红包已过期');
            break;
          case '红包被领取':
            if (isOut) {
              Get.to(RedEnvelopeDetailPage(id, isOut));
            } else {
              showToast('红包已撤回');
            }
            break;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final openView = Material(
      clipBehavior: Clip.antiAlias,
      color: Color(0xFFFFF04A),
      shape: CircleBorder(
        side: BorderSide(color: Color(0xFFF13333), width: 3),
      ),
      child: InkResponse(
        child: Center(
          child: Text(
            '开',
            style: TextStyle(fontSize: 30, color: Color(0xFFF13333)),
          ),
        ),
        onTap: () => onItemClick('领取'),
      ),
    );

    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 285,
              height: 351,
              decoration: BoxDecoration(
                image: DecorationImage(
                  scale: 2,
                  image: AssetImage(IMG.$('packet/背景')),
                ),
              ),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    top: 28,
                    child: AvatarView(
                      url: data['avatar'],
                      size: 48,
                      side: BorderSide(color: Color(0xFFF13333), width: 3),
                    ),
                  ),
                  Positioned(
                    top: 88,
                    child: Text(
                      data['nick'] ?? '',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: fw$SemiBold),
                    ),
                  ),
                  Positioned(
                    top: 112,
                    child: Text(
                      '24小时内未领取，将自动退还给对方。',
                      style: TextStyle(
                          fontSize: 11, color: Colors.white.withOpacity(0.8)),
                    ),
                  ),
                  Positioned(
                    top: 138,
                    width: 80,
                    height: 28,
                    child: OutlinedButton(
                      child: Text('立即退还', style: TextStyle(fontSize: 11)),
                      onPressed: () => onItemClick('退回'),
                    ),
                  ),
                  Positioned(
                    bottom: 144,
                    child: Text(
                      data['remark'] ?? '',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: fw$SemiBold),
                    ),
                  ),
                  Positioned(
                      width: 64, height: 64, bottom: 28, child: openView),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 18, bottom: 32),
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: Get.back,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onItemClick(String item) {
    final id = data['id'];

    switch (item) {
      case '退回':
        simpleSub(
          Api.Packet.withdraw(id),
          callback: () {
            RedEnvelopeCtrl.updateStatus(id, 3);

            Get.back();
          },
        );
        break;
      case '领取':
        simpleSub(
          Api.Packet.receive(id),
          callback: () {
            RedEnvelopeCtrl.updateStatus(id, 2);

            Get.off(RedEnvelopeDetailPage(id, false));
          },
        );
        break;
    }
  }
}
