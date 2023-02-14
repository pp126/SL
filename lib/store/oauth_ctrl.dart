import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/ui/login/login_page.dart';
import 'package:app/ui/main/main_page.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class OAuthCtrl extends GetxService {
  final info = RxMap();
  final gender = RxInt(-1);

  Map _token;
  Map _ticket;

  @override
  void onInit() {
    super.onInit();

    ever(info, (it) {
      final _gender = it['gender'];

      gender.value = (_gender == null || _gender == 0) ? -1 : _gender;
    });

    _token = Storage.read(PrefKey.UserToken);
    _ticket = Storage.read(PrefKey.UserTicket);

    info.assignAll(Storage.read(PrefKey.UserInfo) ?? {});

    if (isLogin) {
      fetchInfo();

      Bus.send(CMD.login);
    }
  }

  bool get isMale => gender.value == 1;

  bool get isLogin => _ticket?.containsKey('uid') ?? false;

  int get uid => _ticket != null ? _ticket['uid'] : null;

  String get ticket => _ticket != null ? _ticket['tickets'][0]['ticket'] : null;

  String get imToken => _token != null ? _token['netEaseToken'] : null;

  String get phone => Storage.read(PrefKey.UserPhone) ?? '';

  doPwdLogin(String phone, String pwd) async {
    _token = await Api.OAuth.pwdLogin(phone, pwd);
    _ticket = await Api.OAuth.ticket(_token['access_token']);

    Storage.write(PrefKey.UserToken, _token);
    Storage.write(PrefKey.UserTicket, _ticket);

    Bus.send(CMD.login);

    await fetchInfo();

    Get.offAll(MainPage());
  }

  fetchInfo() async {
    final data = await Api.User.info(_ticket['uid']);

    info.assignAll(data);

    Storage.write(PrefKey.UserInfo, data);
    Storage.write(PrefKey.UserPhone, info['phone']);
  }

  logout() {
    Storage.remove(PrefKey.UserToken);
    Storage.remove(PrefKey.UserTicket);
    Storage.remove(PrefKey.UserInfo);

    _token = null;
    _ticket = null;

    info.clear();

    Bus.send(CMD.logout);

    LoginPage.to();
  }

  updateUserInfo(Map<String, dynamic> args) async {
    info.assignAll(await Api.User.updateUserInfo(args));

    _saveInfo();
  }

  updateLocalInfo(String k, dynamic v) {
    info[k] = v;

    _saveInfo();
  }

  void _saveInfo() => Storage.write(PrefKey.UserInfo, info);

  ///刷新用户数据
  doRefresh() async {
    await updateUserInfo({'random': 1});
  }

  static Widget use({@required final Widget Function(Map) builder}) {
    return GetX<OAuthCtrl>(builder: (it) {
      final info = it.info;

      try {
        return info.isNullOrBlank ? SizedBox.shrink() : builder(info);
      } catch (e) {
        errLog(e);

        return SizedBox.shrink();
      }
    });
  }

  static OAuthCtrl get obj => Get.find();
}
