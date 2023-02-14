import 'dart:ui';

import 'package:app/common/theme.dart';
import 'package:app/exception.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/level_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:qr_flutter/qr_flutter.dart';

class InvitationDialog extends GetWidget<OAuthCtrl> {
  final String url;

  InvitationDialog(this.url);

  final _gk = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final info = controller.info;

    return FittedBox(
      fit: BoxFit.fitWidth,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            Container(
              width: 303,
              height: 550,
              margin: EdgeInsets.symmetric(horizontal: 36),
              child: RepaintBoundary(
                key: _gk,
                child: Material(
                  color: Colors.white,
                  clipBehavior: Clip.antiAlias,
                  borderRadius: BorderRadius.circular(12),
                  textStyle: TextStyle(fontWeight: fw$SemiBold),
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 132,
                        child: Image.asset(IMG.$('推荐主播背景'), fit: BoxFit.fill, scale: 2),
                      ),
                      Positioned(
                        top: 32,
                        child: Text(
                          '${appInfo.appName}邀请函',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                      Positioned(
                        top: 80,
                        child: RectAvatarView(url: info['avatar'], size: 76),
                      ),
                      Positioned(
                        top: 165,
                        child: Text(
                          info['nick'],
                          style: TextStyle(fontSize: 16, color: AppPalette.txtDark),
                        ),
                      ),
                      Positioned(
                        top: 200,
                        child: Row(
                          children: [CharmIcon(data: info), Spacing.w4, WealthIcon(data: info)],
                        ),
                      ),
                      Positioned(
                        top: 225,
                        child: QrImage(size: 205, data: url),
                      ),
                      Positioned(
                        top: 440,
                        child: Text(
                          '声音盛宴，想你所想',
                          style: TextStyle(fontSize: 14, color: AppPalette.primary),
                        ),
                      ),
                      Positioned(
                        top: 480,
                        width: 110,
                        height: 40,
                        child: Material(
                          color: AppPalette.txtWhite,
                          clipBehavior: Clip.antiAlias,
                          shape: StadiumBorder(),
                          child: InkWell(
                            child: Center(
                              child: Text(
                                '保存分享',
                                style: TextStyle(fontSize: 14, color: AppPalette.primary),
                              ),
                            ),
                            onTap: () {
                              onFrameEnd((_) {
                                simpleSub(() async {
                                  final RenderRepaintBoundary boundary = _gk.currentContext.findRenderObject();

                                  final img = await boundary
                                      .toImage(pixelRatio: Get.pixelRatio)
                                      .then((it) => it.toByteData(format: ImageByteFormat.png))
                                      .then((it) => it.buffer.asUint8List());

                                  final result = await ImageGallerySaver.saveImage(img);

                                  if (result == null || result['isSuccess'] != true) {
                                    throw LogicException(-1, '保存失败');
                                  }
                                });
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Spacing.h8,
            CloseButton(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
