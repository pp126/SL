import 'package:app/nim/nim_help.dart';
import 'package:app/rtc/rtc_help.dart';
import 'package:app/tools/analytics.dart';
import 'package:app/tools/ws_help.dart';
import 'package:app/ui/app.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

import 'tools.dart';

void main() async {
  xlog('app init start');

  WidgetsFlutterBinding.ensureInitialized();
  xlog('WidgetsFlutterBinding init ok');

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  xlog('SystemChrome init ok');

  await toolsInit();
  xlog('tools init ok');

  await _imeiInit();
  xlog('imei init ok');

  await RtcHelp.init();
  xlog('rtc init ok');

  NimHelp.init();
  xlog('nim init ok');

  WxHelp.init();
  xlog('wx init ok');

  analyticsInit();
  xlog('analytics init ok');

  runApp(
    MultiProvider(
      providers: [...ViewState.providers],
      child: ExcludeSemantics(
        child: OKToast(
          child: App(),
        ),
      ),
    ),
  );
  xlog('start app');
}

_imeiInit() async {
  final imei = await ImeiPlugin.getImei(shouldShowRequestPermissionRationale: false);

  Get.put(imei, tag: 'imei', permanent: true);
}
