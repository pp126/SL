library tools;

import 'package:app/tools/bus.dart';
import 'package:app/tools/local_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/utils.dart';
import 'package:package_info/package_info.dart';
import 'package:uni_links/uni_links.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:wakelock/wakelock.dart';
import 'package:webview_flutter/webview_flutter.dart';

export 'package:get/get_core/get_core.dart';
export 'package:get/get_instance/get_instance.dart';
export 'package:get/get_navigation/get_navigation.dart';
export 'package:get/get_rx/get_rx.dart';
export 'package:get/get_state_manager/get_state_manager.dart';
export 'package:get/get_utils/get_utils.dart';

export 'net/http_help.dart';
export 'tools/analytics.dart';
export 'tools/bus.dart';
export 'tools/get_extension.dart';
export 'tools/help.dart';
export 'tools/keyboard.dart';
export 'tools/local_storage.dart';
export 'tools/log.dart';
export 'tools/scheduler.dart';
export 'tools/toast.dart';
export 'tools/view.dart';

const isRelease = kReleaseMode;
const isDebug = kDebugMode;
const xAppId = '1531291067'; //苹果商店ID
const isTestInApp = false; //true沙盒,false线上

const channelCode = String.fromEnvironment("channelCode", defaultValue: 'app'); //渠道号

PackageInfo appInfo;

toolsInit() async {
  if (isRelease) {
    ErrorWidget.builder = (_) => SizedBox.shrink();
  }

  // if (GetPlatform.isAndroid) {
  //   WebView.platform = SurfaceAndroidWebView();
  // }

  VisibilityDetectorController //
      .instance
      .updateInterval = Duration.zero;

  appInfo = await PackageInfo.fromPlatform();

  await storageInit();

  await Wakelock.enable();

  getUriLinksStream().listen((event) => Bus.send(CMD.uniLink, event));
}

class IMG {
  IMG._();

  static String $(String img, [String type = 'webp']) => 'img/$img.$type';
}

class SVG {
  SVG._();

  static String $(String img) => 'assets/svg/$img.svg';
}

class SVGA {
  SVGA._();

  static String $(String img) => 'assets/svga/$img.svga';
}

class CMD {
  CMD._();

  static const lifecycle = 'AppLifecycleState';

  static const login = '登录成功';
  static const logout = '退出登录';
  static const no_auth = '重新登录';
  static const at_user_room = '房间@ta';
  static const at_user_chat = '公聊@ta';
  static const gold_change = '钱包消费';
  static const package_gift_change = '背包礼物消费';
  static const gold_pay = '钱包充值';
  static const diamond_change = '钱包珍珠消费';
  static const conch_change = '钥匙消费';
  static const uniLink = '外部链接';
  static const refreshMic = '刷新麦位';
  static const micState = '用户开关麦状态';
  static const societyListreRresh = '公会列表刷新';
  static const societyListNext = '公会列表下一页';
  static const close_overlay = '关闭Overlay';
  static const call_finish = '闪聊结束';

  static String speak(int uid) => '用户说话#$uid';
}

class PrefKey {
  PrefKey._();

  static const KeyboardHeight = 'KeyboardHeight';
  static const UserToken = 'UserToken';
  static const UserTicket = 'UserTicket';
  static const UserInfo = 'UserInfo';
  static const UserPhone = 'UserPhone';
  static const GiftData = '礼物数据v2';
  static const SearchHistory = 'SearchHistory';
  static const InAppRecords = 'InAppRecords';
  static const SocietySearchHistory = 'SocietySearchHistory';
  static const BannerData = '首页轮播数据';
  static const HomeIndexTab = '首页Tab';
  static const AgreementConfirm = '是否同意过协议';
  static const RedEnvelope = '红包状态';
  static const RoomSticker = '房间表情';
  static const RdAvatar = '随机头像';

  static String tips(String type) => '提示信息#$type';

  static String chatTips(String tips) => '聊天提示信息#${tips.hashCode}';

  static String msgCount(int uid) => '消息记数#$uid';

  static String usedCall(int uid) => '试用闪聊#$uid';
}

dynamic xMapStr(var data, String key, {var defaultStr = ''}) {
  var value;
  if (data != null && data is Map) {
    value = data[key];
  }
  if (value == 0 || value == '') {
    value = defaultStr;
  }
  return value ?? defaultStr;
}

dynamic xListStr(var data, int index, {var defaultStr = ''}) {
  var value;
  if (data != null && data is List && data.length > index) {
    value = data[index];
  }
  if (value == 0 || value == '') {
    value = defaultStr;
  }
  return value ?? defaultStr;
}

String xPhoneStr(String data, {String replace = '****'}) {
  var phoneStr = data;
  if (data != null && data is String && data.length > 4) {
    phoneStr = data.substring(0, 3) + replace + data.substring(data.length - 4, data.length);
  }
  return phoneStr;
}

///密码限制
List<TextInputFormatter> xPasswordFormatter() {
  return [
    //只允许输入字母数字*
    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]|[0-9.]")),
    LengthLimitingTextInputFormatter(18)
  ];
}
