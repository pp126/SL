import 'package:app/store/oauth_ctrl.dart';
import 'package:app/store/room_overlay_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/tools/bus.dart';
import 'package:app/ui/mine/certify/certify_page.dart';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';

mixin UniLinkStateMixin<T extends StatefulWidget> on State<T>, BusStateMixin<T> {
  @override
  void initState() {
    super.initState();

    getInitialUri().then((it) {
      if (it != null) Bus.send(CMD.uniLink, it);
    });

    bus<Uri>(
      CMD.uniLink,
      (it) {
        final args = it.queryParameters;

        if (args.isNullOrBlank) return;

        final arg = args['roomUid'];
        if (arg == null) return;

        final roomUid = int.tryParse(arg);
        if (roomUid == null) return;

        RoomOverlayCtrl.obj.to(roomUid, OAuthCtrl.obj.uid == roomUid);
      },
      test: (it) => it.pathSegments.contains('openRoom'),
    );

    bus<Uri>(
      CMD.uniLink,
      (it) {
        Get.to(CertifyPage());
      },
      test: (it) {
        return it.host == 'zfb_certify';
      },
    );
  }
}
