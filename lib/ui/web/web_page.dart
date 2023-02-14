import 'dart:async';
import 'dart:convert';

import 'package:app/tools.dart';
import 'package:app/tools/ws_help.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AppWebPage extends StatelessWidget {
  final String title;
  final String url;

  AppWebPage({@required this.title, @required this.url});

  final _ctrl = Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar(title),
      body: WebView(
        debuggingEnabled: isDebug,
        javascriptMode: JavascriptMode.unrestricted,
        initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
        javascriptChannels: {JavascriptChannel(name: 'openMiniProgram', onMessageReceived: openMiniProgram)},
        onWebResourceError: (e) => xlog('$e', name: 'WEB_VIEW'),
        onWebViewCreated: (it) {
          xlog('初始化成功', name: 'WEB_VIEW');

          _ctrl.complete(it);

          it
            // ..clearCache()
            ..loadUrl(url);
        },
        navigationDelegate: (it) async {
          final url = it.url;
          xlog('导航 => $url', name: 'WEB_VIEW');

          final uri = Uri.parse(url);

          if (uri.isScheme('HTTP') || uri.isScheme('HTTPS')) {
            return NavigationDecision.navigate;
          } else if ('about:blank' == url) {
            Timer.run(Get.back);

            return NavigationDecision.navigate;
          } else {
            xlog('打开 => $url', name: 'WEB_VIEW');

            await launchUrlString(url);

            if (uri.isScheme('WEIXIN')) Timer.run(Get.back);

            return NavigationDecision.prevent;
          }
        },
      ),
    );
  }

  void openMiniProgram(JavascriptMessage data) async {
    final _data = jsonDecode(data.message);

    await WxHelp.openMiniProgram(_data['name'], path: _data['path']);

    Timer.run(Get.back);
  }
}
