import 'dart:async';

import 'package:app/common/asset_pre_cache.dart';
import 'package:app/common/theme.dart';
import 'package:app/net/host.dart';
import 'package:app/net/ws_help.dart';
import 'package:app/nim/nim_help.dart';
import 'package:app/store/audit_ctrl.dart';
import 'package:app/store/broadcast_queue_ctrl.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/store/red_envelope_ctrl.dart';
import 'package:app/store/room_overlay_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/common/music_dialog.dart';
import 'package:app/ui/home/common/banner_view.dart';
import 'package:app/ui/login/login_page.dart';
import 'package:app/ui/main/main_page.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver, WidgetsBindingObserverMixin, BusStateMixin {
  @override
  void initState() {
    super.initState();

    bus(CMD.login, (_) async {
      WsHelp.init();

      final ctrl = OAuthCtrl.obj;

      if (!await NimHelp.login(ctrl.uid, ctrl.imToken)) {
        if (isRelease) Bus.send(CMD.no_auth, 'NIM');
      }
    });

    bus(CMD.logout, (_) {
      WsHelp.close();
      NimHelp.logout();
    });

    bus(CMD.no_auth, (msg) {
      xlog('$msg');

      showToast('账号需要重新登录');

      OAuthCtrl.obj.logout();
    });

    if (isRelease) {
      final b = host.host.startsWith('test.');

      if (b) {
        onFrameEnd((_) => Get.alertDialog('当前连接为测试环境'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Locale('zh', 'CN');

    return GetMaterialApp(
      defaultTransition: Transition.cupertino,
      initialBinding: _AppBindings(),
      theme: $theme,
      locale: locale,
      supportedLocales: [locale],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      onInit: SvgPreCache.$({'main/more'}),
      home: Root(),
      builder: (ctx, child) {
        final data = MediaQuery.of(ctx).copyWith(textScaleFactor: 1);

        return MediaQuery(
          data: data,
          child: GestureDetector(onTap: hideKeyboard, child: child),
        );
      },
    );
  }

  @override
  Future<bool> didPopRoute() async => WaitingCtrl.obj.isShow;
}

class Root extends StatefulWidget {
  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root> {
  @override
  void initState() {
    super.initState();

    if (isRelease) onFrameEnd((_) => checkVersion(context, alert: false));
    // onFrameEnd((_) => checkVersion(context, alert: false));
  }

  @override
  Widget build(BuildContext context) => OAuthCtrl.obj.isLogin ? MainPage() : LoginPage();
}

class _AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(const AppWaiting());
    Get.lazyPut<WaitingCtrl>(() => WaitingCtrl());
    Get.lazyPut<GiftEffectCtrl>(() => GiftEffectCtrl());
    // Get.lazyPut<MusicCtrl>(() => MusicCtrl());

    Get.lazyPut<BannerCtrl>(() => BannerCtrl(), fenix: true);

    Get.put(OAuthCtrl());

    Get.put(RoomOverlayCtrl());
    Get.put(RoomDrawBroadcastCtrl());
    Get.put(BigGiftBroadcastCtrl());

    Get.put(RedEnvelopeCtrl());

    if (GetPlatform.isIOS) Get.put(AuditCtrl());
  }
}
