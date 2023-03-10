import 'dart:convert';

import 'package:app/exception.dart';
import 'package:app/model/user_society_info.dart';
import 'package:app/net/api_help.dart';
import 'package:app/net/host.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/tools/time.dart';
import 'package:app/widgets.dart';

dynamic _doGet(Uri uri, [Map<String, dynamic> query]) async {
  return _onResponse(
    uri,
    await request(uri.toString(), query: query, method: 'GET'),
  );
}

dynamic _doPost(Uri uri, [Map<String, dynamic> query]) async {
  return _onResponse(
    uri,
    await request(uri.toString(), query: query, method: 'POST'),
  );
}

dynamic _onResponse(Uri uri, dynamic data) {
  if (data is Map) {
    return _onResMap(uri, data);
  } else if (data is String) {
    return _onResStr(uri, data);
  }

  return data;
}

dynamic _onResStr(Uri uri, String data) {
  try {
    return _onResponse(uri, jsonDecode(data));
  } on LogicException catch (_) {
    rethrow;
  } catch (e, s) {
    errLog(e, s: s, name: 'API');

    return data;
  }
}

dynamic _onResMap(Uri uri, Map data) {
  if (data.containsKey('errno')) {
    final code = data['errno'];

    switch (code) {
      case 0:
        return data['data'];
      default:
        throw LogicException(code, data['errmsg']);
    }
  } else {
    final code = data['code'];

    switch (code) {
      case 200:
        return data['data'];
      case 401:
        Bus.send(CMD.no_auth, 'API $uri -> 401');
        continue err;
      err:
      default:
        throw LogicException(code, data['message']);
    }
  }
}

class Api {
  final ApiHost _host;
  final String _basePath;

  const Api._(this._host, this._basePath);

  Uri $uri(String path) => _host.$new('$_basePath/$path');

  static const Home = _Home(host, 'home');
  static const Rank = _Rank(host, 'rank');
  static const Room = _Room(host, 'room');
  static const Gift = _Gift(host, 'gift');
  static const User = _User(host, 'user');
  static const OAuth = _OAuth(host, 'oauth');
  static const Moment = _Moment(host, 'user'); //??????
  static const Family = _Family(host, 'family'); //??????
  static const Task = _Task(host, 'mcoin'); //??????
  static const Draw = _Draw(host, 'draw');
  static const Wx = _Wx(host, 'wx');
  static const Packet = _Packet(host, 'packet');
  static const Auction = _Auction(host, 'auctionhouse');
}

class _Home extends Api {
  const _Home(ApiHost _host, String _basePath) : super._(_host, _basePath);

  ///????????????
  Future<List> homeTag() async => await _doGet($uri('getRoomTag'));

  Future<List> tagIndex(int id, PageNum page) async {
    final args = page + {'tagId': id};

    return await _doGet($uri('v2/tagindex'), args);
  }

  /// ??????????????????
  Future<Map> getConfig() async {
    var uid = OAuthCtrl.obj.uid ?? '';
    final args = {
      'uid': uid,
    };
    return await _doGet($uri('config'), args);
  }

  ///??????banner
  Future<List> getIndexTopBanner() async {
    return await _doGet($uri('getIndexTopBanner'), {});
  }

  ///??????uid????????????????????????
  Future<List> getRoomAttentionByUid(PageNum page) async {
    final args = page + {};

    return await _doGet(
        _host.$new('room/attention/getRoomAttentionByUid'), args);
  }

  ///?????????????????????????????????
  Future<List> getRecommendUsers(PageNum page) async {
    final args = page + {};

    return await _doGet(_host.$new('user/getRecommendUsers'), args);
  }

  ///??????uid??????????????????
  Future<List> getRoomRecommendList(PageNum page) async {
    final args = page + {};

    return await _doGet(_host.$new('room/getRoomRecommendList'), args);
  }

  ///????????????
  Future<List> historyList() async {
    final Map<String, dynamic> args = {};
    var data = await _doGet(_host.$new('userroom/in/history'), args);
    return data ?? [];
  }

  ///????????????
  Future clearRoomHistory() async {
    final Map<String, dynamic> args = {};

    return await _doGet(_host.$new("userroom/in/history/clean"), args);
  }

  ///????????????
  Future followRoom({var roomId, bool isFollow = true}) async {
    final args = {
      'roomId': roomId,
    };

    return await _doPost(
        _host.$new(isFollow
            ? 'room/attention/delAttentions'
            : 'room/attention/attentions'),
        args);
  }

  ///????????????
  Future followUser({var likedUid, bool isFollow = true}) async {
    final args = {
      'likedUid': likedUid,
      'type': isFollow ? 2 : 1,
    };

    return await _doPost(_host.$new('/fans/like'), args);
  }

  Future<List> recommendRoom(int type) async {
    final args = {
      'type': type,
    };

    return await _doGet($uri('recommendRoom'), args);
  }

  ///??????(?????????)
  Future<List> getHomeChitchat() async {
    return await _doGet(_host.$new('room/rcmd/linkmic'));
  }

  ///(?????????)
  Future<List> dynamicList(PageNum page) async {
    final args = page + {};

    return await _doGet($uri('room/dynamic/page'), args);
  }

  ///(??????)
  Future<List> bestCompanies(PageNum page) async {
    final args = page + {};

    return await _doGet($uri('bestCompanies'), args);
  }

  ///(??????)
  Future<List> newUsers(PageNum page) async {
    final args = page + {};

    return await _doGet($uri('newUsers'), args);
  }

  ///????????????
  Future<List> search(String key, PageNum page, int type) async {
    final args = page + {'key': key, 'type': type};

    return await _doGet(_host.$new('search/room'), args);
  }

  Future<List> greetingList() async => await _doGet($uri('getGreetingList'));

  Future<Map> clickGreeting(List ids) async {
    final args = {
      'uids': ids.join(','),
    };

    return await _doPost($uri('clickGreeting'), args);
  }

  Future<List> sendPublicChat(String content) async {
    final args = {'content': content};

    return await _doPost(_host.$new('publicchat/sendPublicChat'), args);
  }

  Future<List> pubChatHistory() async {
    return await _doPost(_host.$new('publicchat/getPublicChat'));
  }

  // iOS ???????????? 0???????????????
  Future<int> iooooos() async {
    return await _doGet(_host.$new('publicchat/getUserInfo'));
  }

  Future<Map> sendFlashChat(int targetUid) async {
    final args = {
      if (targetUid != null) 'targetUid': targetUid,
    };

    return await _doPost(_host.$new('publicchat/sendFlashChat'), args);
  }

  Future<Map> acceptFlashChat(String room) async {
    final args = {'roomId': room};

    return await _doPost(_host.$new('publicchat/acceptFlashChat'), args);
  }

  Future<Map> activationFlashChat(String room) async {
    final args = {'roomId': room};

    return await _doPost(_host.$new('publicchat/activationFlashChat'), args);
  }

  Future<Map> activationFlashChatOnLine(String room) async {
    final args = {'roomId': room};

    return await _doPost(
        _host.$new('publicchat/activationFlashChatOnLine'), args);
  }

  Future<Map> refuseFlashChat(String room) async {
    final args = {'roomId': room};

    return await _doPost(_host.$new('publicchat/refuseFlashChat'), args);
  }

  Future<List> getRandomAvatar() async {
    final result = await _doPost(_host.$new('publicchat/getRandomAvatar'));

    return result['list'];
  }

  Future<Map> privateChat({String content, int targetUid}) async {
    final args = {
      'content': content,
      'targetUid': targetUid,
    };

    return await _doPost(_host.$new('publicchat/privateChat'), args);
  }

  Future<Map> getUserIsPrivateChat() async {
    return await _doPost(_host.$new('publicchat/getUserIsPrivateChat'));
  }

  Future<Map> savePopup() async {
    return await _doPost(_host.$new('publicchat/savePopup'));
  }
}

class _Rank extends Api {
  const _Rank(ApiHost _host, String _basePath) : super._(_host, _basePath);

  ///???????????????
  ///type??????????????? 1????????????2????????????3?????????
  ///datetype?????????????????? 0?????????1?????????2??????
  ///????????????type???1??????
  Future<List> getRankingList(String type, String datetype) async {
    final args = {'type': type, 'datetype': datetype};
    var data = await _doGet(_host.$new('allrank/geth5'), args);
    return data['rankVoList'] ?? [];
  }

  ///?????????????????????
  ///dateType?????????????????? 0?????????1?????????2??????
  Future<List> getRankGiftList(String dateType) async {
    final args = {'dateType': dateType};
    var data = await _doGet(_host.$new('allrank/getGiftRank'), args);
    return data ?? [];
  }

  ///??????????????????
  Future<List> getRankGiftDetailList(String dateType, String giftId) async {
    final args = {
      'dateType': dateType,
      'giftId': giftId,
    };
    var data = await _doGet(_host.$new('allrank/getGiftRankDetail'), args);
    return data ?? [];
  }
}

class _User extends Api {
  const _User(ApiHost _host, String _basePath) : super._(_host, _basePath);

  Future<Map> info(int uid) async {
    final args = {'queryUid': uid};

    return await _doGet($uri('v3/get'), args);
  }

  //APP??????
  Future<Map> versionInfo() async {
    return await _doGet(_host.$new('version/get'));
  }

  /// ??????????????????
  Future<Map> updateUserInfo(Map<String, dynamic> args) async {
    return await _doPost(_host.$new('user/update'), args);
  }

  /// ????????????????????????
  Future<Map> addPhoto(String photoStr) async {
    final args = {
      'photoStr': photoStr,
    };
    return await _doPost(_host.$new('photo/upload'), args);
  }

  /// ????????????????????????
  Future<Map> deletePhoto(String pid) async {
    final args = {'pid': pid};

    return await _doPost(_host.$new('photo/delPhoto'), args);
  }

  /// ??????????????????
  Future<Map> getWalletInfos() async {
    final args = {
      'Cache-Control': 'no-cache',
    };
    return await _doGet(_host.$new('purse/query'), args);
  }

  /// ????????????
  Future<dynamic> exchangeGold(int exchangeNum) async {
    final args = {
      'exchangeNum': exchangeNum,
    };
    return await _doPost(_host.$new('purse/exchangeGold'), args);
  }

  /// ????????????????????????
  Future<List> getChargeList() async {
    final args = {
      'channelType': '1',
    };
    return await _doGet(_host.$new('chargeprod/list'), args);
  }

  /// ????????????????????????
  Future<List> getFindList() async =>
      await _doGet(_host.$new('withDraw/findList'));

  /// ????????????
  Future<Map> orderInApp(String chargeProdId) async {
    final args = {
      'chargeProdId': chargeProdId,
    };
    return await _doPost(_host.$new('order/place'), args);
  }

  /// ????????????????????????
  Future<Map> checkOrder({
    String receiptData,
    String trancid,
    String chargeRecordId,
  }) async {
    final args = {
      'receipt': receiptData,
      'chooseEnv': isTestInApp,
      'trancid': trancid,
      'chargeRecordId': chargeRecordId,
    };
    return await _doPost(_host.$new('verify/setiap'), args);
  }

  ///??????
  Future payMoney({
    var chargeProdId,
  }) async {
    final args = {
      'chargeProdId': chargeProdId,
      'payChannel': 'wx',
      'successUrl': '',
    };

    return await _doPost(_host.$new('/charge/apply'), args);
  }

  /// ??????????????????
  Future<dynamic> getLevelCharm() => _doGet(_host.$new('level/charm/get'), {});

  /// ??????????????????
  Future<dynamic> getLevelWealth() =>
      _doGet(_host.$new('level/wealth/get'), {});

  /// ??????????????????
  Future<dynamic> getLevelExperience() =>
      _doGet(_host.$new('level/experience/get'), {});

  /// ????????????????????????
  Future<List> billrecordGet(int type, String pageNo) async {
    final args = {
      'pageNo': pageNo,
      'pageSize': '10',
      'date': TimeUtils.getNowDateMs(),
      'type': type,

      ///1????????????,2????????????,3????????????,4????????????,
    };
    return await _doGet(_host.$new('billrecord/get'), args);
  }

  /// ??????????????????
  Future<List> coralRecord(String pageNo) async {
    final args = {
      'pageNum': pageNo,
      'pageSize': '10',
    };
    return await _doGet(_host.$new('mcoin/getMcoinList'), args);
  }

  /// ?????????????????????
  Future<Map> getDianDianCoinInfos() async {
    return await _doPost(_host.$new('mcoin/v1/getMcoinNum'));
  }

  /// ??????????????????
  Future<Map> commitFeedback(String feedbackDesc, String contact) async {
    final args = {
      'contact': contact,
      'feedbackDesc': feedbackDesc,
    };
    return await _doPost(_host.$new('feedback'), args);
  }

  /// ??????????????????????????????????????????????????????????????????
  Future<Map> getBillRecord(String date, String type, PageNum page) async {
    final args = page + {'date': date, 'type': type};

    return await _doGet(_host.$new('billrecord/get'), args);
  }

  /// ????????????
  Future<List> activityQuery() async {
    final args = {
      'type': '1',
    };
    return await _doGet(_host.$new('activity/query'), args);
  }

  /// ????????????
  Future<List> activityAll() async =>
      await _doGet(_host.$new('activity/queryAll'), {});

  /// ????????????
  Future<List> fansList(PageNum page) async {
    final args = page + {};

    return (await _doGet(_host.$new('fans/fanslist'), args))['fansList'];
  }

  /// ????????????
  Future<List> following(PageNum page) async {
    final args = page + {};

    // ?????????
    args['pageNo'] = args.remove('pageNum');

    return await _doGet(_host.$new('fans/following'), args);
  }

  /// ????????????
  Future<List> friend() async {
    return await _doGet(_host.$new('fans/friend'));
  }

  /// ????????????
  Future<List> dd(PageNum page) async {
    final args = page + {};

    return await _doGet($uri('getVisitorRecord'), args);
  }

  Future<bool> isLike(int uid) async {
    final args = {
      'isLikeUid': uid,
    };

    return await _doGet(_host.$new('fans/islike'), args);
  }

  Future<bool> like(int uid, bool isAdd) async {
    final args = {
      'likedUid': uid,
      'type': isAdd ? 1 : 2,
    };

    return await _doPost(_host.$new('fans/like'), args);
  }

  /// ???????????????????????????
  Future<Map> getUsersTeensMode() async {
    return await _doGet(_host.$new('users/teens/mode/getUsersTeensMode'));
  }

  /// ?????????????????????
  Future<Map> saveTeensMode(String cipherCode) async {
    final args = {
      'cipherCode': cipherCode,
    };
    return await _doPost(_host.$new('users/teens/mode/save'), args);
  }

  /// ?????????????????????
  Future closeTeensMode() async {
    return await _doPost(_host.$new('/users/teens/mode/closeTeensMode'));
  }

  /// ???????????????????????????
  Future<bool> checkCipherCode(String cipherCode) async {
    final args = {
      'cipherCode': cipherCode,
    };

    return await _doGet(_host.$new('/users/teens/mode/checkCipherCode'), args);
  }

  /// ??????????????????
  Future<Map> getCertifyInfo() async {
    return await _doGet($uri('realname/v1/get'));
  }

  /// ????????????
  Future<Map> certify({
    String idcardFront,

    ///??????????????????
    String idcardHandheld,

    ///??????????????????
    String idcardNo,

    ///???????????????
    String idcardOpposite,

    ///??????????????????
    String phone,

    ///???????????????
    String realName,

    ///??????????????????
    String smsCode,

    ///?????????????????????
  }) async {
    final args = {
      'ticket': OAuthCtrl.obj.ticket ?? '',
      'idcardFront': idcardFront,
      'idcardHandheld': idcardHandheld,
      'idcardNo': idcardNo,
      'idcardOpposite': idcardOpposite,
      'phone': phone,
      'realName': realName,
      'smsCode': smsCode,
    };
    return await _doPost($uri('realname/v1/save'), args);
  }

  /// ???????????????
  Future bindPhone({
    String phone,
    String code,
  }) async {
    final args = {
      'phone': phone,
      'smsCode': code,
    };
    return await _doPost($uri('replace'), args);
  }

  /// ????????????
  Future resetPassword({
    String phone,
    String code,
    String password,
  }) async {
    final args = {
      'phone': phone,
      'smsCode': code,
      'newPwd': await ApiHelp.pwd(password),
    };
    return await _doPost(_host.$new('acc/pwd/reset'), args);
  }

  /// ????????????
  Future changePassword({
    String phone,
    String oldPassword,
    String newPassword,
  }) async {
    final args = {
      'phone': phone,
      'oldPwd': oldPassword,
      'password': newPassword,
      'confirmPwd': newPassword,
    };
    return await _doPost($uri('modifyPwd'), args);
  }

  /// ????????????????????????
  Future<Map> bindPhoneSMS({
    String phone,
  }) async {
    final args = {
      'phone': phone,
    };
    return await _doPost($uri('getSendSms'), args);
  }

  /// ???????????????????????????
  Future<Map> userGiftList({
    bool isNormal = true,

    ///true,???????????????false????????????
    String userId,
    int orderType = 2,
    int type = 1,

    ///??????0??????1?????????2?????????
  }) async {
    final args = isNormal
        ? {
            'uid': userId,
            'orderType': orderType,
            'type': type,
          }
        : {
            'queryUid': userId,
            'orderType': orderType,
          };

    return await _doGet(
        _host.$new(isNormal ? 'giftwall/get' : 'giftwall/listMystic'), args);
  }

  /// ??????????????????
  Future<Map> userHeadList({
    String userId,
    PageNum page,
    int type = 1,

    ///??????0??????1?????????2?????????
  }) async {
    final args = {
      'queryUid': userId,
      "type": type,
    };

    return await _doPost(_host.$new('headwear/user/list'), args);
  }

  /// ??????????????????
  Future<Map> userCarList({
    String userId,
    PageNum page,
    int type = 1,

    ///??????0??????1?????????2?????????
  }) async {
    final args = {
      'queryUid': userId,
      "type": type,
    };

    return await _doPost(_host.$new('giftCar/user/list'), args);
  }

  /// ????????????????????????
  Future<List> shopHeadList({
    String userId,
    PageNum page,
  }) async {
    final args = {
      'queryUid': userId,
      "pageNum": page?.index ?? 1,
      "pageSize": page?.size ?? 10,
    };

    return await _doPost(_host.$new('headwear/listMall'), args);
  }

  /// ????????????????????????
  Future<List> shopCarList({
    String userId,
    PageNum page,
  }) async {
    final args = {
      'queryUid': userId,
      "pageNum": page?.index ?? 1,
      "pageSize": page?.size ?? 10,
    };

    return await _doPost(_host.$new('giftCar/listMall'), args);
  }

  /// ????????????
  Future sendCar({
    String targetUid,
    String carId,
  }) async {
    final args = {
      'carId': carId,
      "targetUid": targetUid,
    };

    return await _doPost(_host.$new('giftCar/give'), args);
  }

  /// ????????????
  Future buyCar({
    String carId,
  }) async {
    final args = {
      'carId': carId,
    };

    return await _doPost(_host.$new('giftCar/purse'), args);
  }

  /// ????????????
  Future setCar({
    String carId,
  }) async {
    final args = {
      'carId': carId,
    };

    return await _doPost(_host.$new('giftCar/use'), args);
  }

  /// ????????????
  Future sendHead({
    String targetUid,
    String headwearId,
  }) async {
    final args = {
      'headwearId': headwearId,
      "targetUid": targetUid,
    };

    return await _doPost(_host.$new('headwear/give'), args);
  }

  /// ????????????
  Future buyHead({
    String headwearId,
  }) async {
    final args = {
      'headwearId': headwearId,
    };

    return await _doPost(_host.$new('headwear/purse'), args);
  }

  /// ????????????
  Future setHead({
    String headwearId,
  }) async {
    final args = {
      'headwearId': headwearId,
    };

    return await _doPost(_host.$new('headwear/use'), args);
  }

  Future<Map> roomInfo(int uid) async {
    final args = {'queryUid': uid};

    return await _doGet(_host.$new('userroom/get'), args);
  }

  ///????????????
  Future<String> onLine() async {
    return await _doPost(_host.$new('mcoin/v1/online'));
  }

  /// ??????????????????
  Future<Map> getCustomer() async {
    return await _doGet(_host.$new('customer/get'));
  }

  /// ??????????????????
  Future<List> getPrizePoolGift() async {
    return await _doGet($uri('giftPurse/getPrizePoolGift'));
  }

  Future<List> getMaxPrizePoolGift() async {
    return await _doGet($uri('giftPurse/getMaxPrizePoolGift'));
  }

  Future<List> getMaxPrizeSeniority() async {
    return await _doGet($uri('giftPurse/getMaxPrizeSeniority'));
  }

  /// ??????????????????
  Future<List> giftPurseRecord(int drawType, int pageNum, int pageSize) async {
    final args = {
      'drawType': drawType,
      'pageNum': pageNum,
      'pageSize': pageSize,
    };
    return await _doGet($uri('giftPurse/record'), args);
  }

  /// ??????????????????
  Future<List> getTopRank(int drawType, int pageNum, int pageSize) async {
    final args = {
      'drawType': drawType,
      'pageNum': pageNum,
      'pageSize': pageSize,
    };
    return await _doGet($uri('giftPurse/getTopRank'), args);
  }

  /// ??????????????????
  Future<Map> getInvestAndReturn(int type) async {
    var uid = OAuthCtrl.obj.uid ?? '';
    final args = {
      'uid': uid,
      'drawType':type
    };
    return await _doGet($uri('giftPurse/todayTreasure'), args);
  }

  /// ??????????????????
  Future<dynamic> bindWithdrawAccount({
    String account,
    String accountName,
    String accountType,
    String accountUrl,
    String bankName,
  }) async {
    final args = {
      'account': account,
      'accountName': accountName,
      'accountType': accountType,
      'accountUrl': accountUrl,
      'bankName': bankName,
    };
    return await _doPost(_host.$new('withDraw/bindWithdrawAccount'), args);
  }

  /// ????????????????????????
  Future<Map> getFinancialAccount() async {
    return await _doGet(_host.$new('withDraw/getFinancialAccount'));
  }

  /// ????????????V2
  Future<dynamic> withDrawCashv2(String pid, String type, String code) async {
    final args = {
      'pid': pid,
      'type': type,
      'code': code,
    };
    return await _doPost(_host.$new('withDraw/v2/withDrawCash'), args);
  }

  /// ???????????????
  Future<Map> getInviteCode() async {
    return await _doGet($uri('v2/getInviteCode'));
  }

  /// ?????????????????????
  Future<List> getInviteCodeRecord() async {
    return await _doGet($uri('getInviteCodeRecord'));
  }

  /// ???????????????????????????????????????????????????
  Future<dynamic> aliCertify(String idcardNo, String realName) async {
    final args = {
      'idcardNo': idcardNo,
      'realName': realName,
    };
    return await _doPost($uri('realname/ali/certify'), args);
  }

  Future decActivation() async {
    final args = {
      'decId': ApiHelp.imei(),
      'channel': channelCode,
    };

    return await _doGet($uri('decActivation'), args);
  }
}

class _OAuth extends Api {
  const _OAuth(ApiHost _host, String _basePath) : super._(_host, _basePath);

  Future<Map> pwdLogin(String phone, String pwd) async {
    final args = {
      'phone': phone,
      'username': phone,
      'grant_type': 'password',
      'password': await ApiHelp.pwd(pwd),
      'client_id': ApiHelp.clientID(),
      'client_secret': ApiHelp.clientSecret(),
      'IMEI': ApiHelp.imei(),
    };

    return await _doGet($uri('token'), args);
  }

  Future<Map> ticket(String token) async {
    final args = {
      'issue_type': 'once',
      'access_token': token,
    };

    return await _doGet($uri('ticket'), args);
  }

  Future<Map> signup(String phone, String smsCode, String password) async {
    final args = {
      'phone': phone,
      'smsCode': smsCode,
      'password': await ApiHelp.pwd(password),
      'deviceInfo': {
        'imei': ApiHelp.imei(),
        'deviceId': ApiHelp.imei(),
      },
    };

    return await _doPost(_host.$new('acc/signup'), args);
  }

  ///type,1?????????2?????????3????????????
  Future<Map> registerSms(String phone, {int type}) async {
    final args = {'phone': phone, "type": type ?? '1'};
    return await _doGet(_host.$new('acc/sms'), args);
  }

  Future<Map> certifySms(String phone) async {
    final args = {
      'phone': phone,
      "uid": OAuthCtrl.obj.uid ?? '',
      'deviceId': ApiHelp.imei(),
    };

    return await _doGet(_host.$new('/user/realname/v1/getSmsCode'), args);
  }
}

class _Room extends Api {
  const _Room(ApiHost _host, String _basePath) : super._(_host, _basePath);

  Future<Map> info(int roomUid) async {
    final args = {
      'uid': roomUid,
      'visitorUid': OAuthCtrl.obj.uid,
    };

    return await _doGet($uri('get'), args);
  }

  Future<Map> randomIn() async {
    return await _doPost(_host.$new('userroom/randomIn'));
  }

  Future<void> lockMic(int roomUid, int position, bool state) async {
    final args = {
      'position': position,
      'state': state ? 0 : 1,
      'roomUid': roomUid,
    };

    await _doGet($uri('mic/lockmic'), args);
  }

  Future<void> lockPos(int roomUid, int position, bool state) async {
    final args = {
      'position': position,
      'state': state ? 0 : 1,
      'roomUid': roomUid,
    };

    await _doGet($uri('mic/lockpos'), args);
  }

  Future<void> setMicType(int roomUid, int position, int type) async {
    final args = {
      'position': position,
      'roomUid': roomUid,
      'type': type,
    };

    await _doGet($uri('mic/setMicType'), args);
  }

  Future<List> members(int roomID, PageNum page) async {
    final args = {
      'room_id': roomID,
      'start': page.start,
      'limit': page.limit,
    };

    return await _doPost(_host.$new('imroom/v1/fetchRoomMembers'), args);
  }

  Future<List> roomBlackList(int roomID, PageNum page) async {
    final args = {
      'room_id': roomID,
      'start': page.start,
      'limit': page.limit,
    };

    return await _doPost(_host.$new('imroom/v1/fetchRoomBlackList'), args);
  }

  Future<List> roomManagers(int roomID, PageNum page) async {
    final args = {
      'room_id': roomID,
      'start': page.start,
      'limit': page.limit,
    };

    return await _doPost(_host.$new('imroom/v1/fetchRoomManagers'), args);
  }

  Future<String> agoraKey(int roomID) async {
    final args = {'roomId': roomID};

    return await _doPost(_host.$new('agora/getKey'), args);
  }

  Future<Map> join(int roomUid) async {
    final args = {'roomUid': roomUid};

    return await _doPost(_host.$new('userroom/in'), args);
  }

  ///??????????????????
  Future<Map> createRoom(
      int familyID, String title, String avatar, int tag, String bg) async {
    final args = {
      'type': 3, //???????????????3
      'roomPwd': '',
      'roomDesc': '',
      'title': title,
      'tagId': tag,
      'backPic': bg,
      'avatar': avatar,
    };

    String path;

    if (familyID == null) {
      path = 'open';
    } else {
      args['familyId'] = familyID;

      path = 'openFamilyRoom';
    }

    return await _doPost($uri(path), args);
  }

  ///??????????????????
  Future<Map> updateRoom(int roomID, {Map info, String bg}) async {
    final args = <String, dynamic>{
      'roomId': roomID,
      if (info != null) ...info,
      if (bg != null) 'backPic': bg,
    };

    return await _doPost($uri('update'), args);
  }

  Future<Map> roomSwitch(int roomID, String key, bool value) =>
      updateRoom(roomID, info: {key: value ? 0 : 1});

  Future<List> bgList() async => await _doGet($uri('bg/list'));

  Future<List> tagList() async => await _doGet($uri('tag/all'));

  Future<String> leave() async {
    return await _doPost(_host.$new('userroom/out'));
  }

  Future<Map> addAttention() async {
    return await _doPost($uri('attention/attentions'));
  }

  Future<Map> delAttention() async {
    return await _doPost($uri('attention/delAttentions'));
  }

  Future<Map> setRoomAdmin(int myUid, int roomID, int uid, bool isAdd) async {
    final args = {
      'uid': myUid,
      'room_id': roomID,
      'account': uid,
      'is_add': isAdd ? '1' : '0',
    };

    return await _doPost(host.$new('imroom/v1/markChatRoomManager'), args);
  }

  Future<Map> setRoomBlack(int roomID, int uid, bool isAdd) async {
    final args = {
      'room_id': roomID,
      'account': uid,
      'is_add': isAdd ? '1' : '0',
    };

    return await _doPost(host.$new('imroom/v1/markChatRoomBlackList'), args);
  }

  Future<void> kickMember(int myUid, int roomID, int uid) async {
    // ???????????????
    _doPost(
        host.$new('userroom/kickMember'), {'roomId': roomID, 'kickUid': uid});

    final args = {
      'uid': myUid,
      'room_id': roomID,
      'account': uid,
    };

    return await _doPost(host.$new('imroom/v1/kickMember'), args);
  }

  // ??????????????????
  Future<Map> delFamilyRoom(
      {String roomId, String familyId, String userId}) async {
    final args = {
      'roomId': roomId,
      'familyId': familyId,
      'uid': userId ?? OAuthCtrl.obj.uid,
    };
    return await _doPost($uri('delFamilyRoom'), args);
  }

  Future<List> rank(int roomUid, int type, int dataType) async {
    final args = {
      'uid': roomUid,
      'type': type,
      'dataType': dataType,
    };

    return await _doGet(host.$new('roomctrb/queryByType'), args);
  }

  ///???????????????????????????
  Future<dynamic> receiveRoomMicMsg(int roomUid, {int userid = -1}) async {
    final args = {
      'roomUid': roomUid,
      'userid': userid,
    };
    return await _doGet($uri('receiveRoomMicMsg'), args);
  }

  // deleteRoomCharm
  ///???????????????????????????
  Future<dynamic> deleteRoomCharm(int roomUid) async {
    final args = {
      'roomUid': roomUid,
    };
    return await _doGet($uri('deleteRoomCharm'), args);
  }

  ///??????????????????
  Future<dynamic> like(int roomId, bool isAdd) async {
    final args = {
      'roomId': roomId,
    };
    return await _doPost(
        $uri(isAdd ? 'attention/attentions' : 'attention/delAttentions'), args);
  }

  Future<bool> isLike(int roomId) async {
    final args = {
      'roomId': roomId,
    };
    return await _doPost($uri('attention/checkAttentions'), args);
  }

  ///????????????
  Future<dynamic> close(int userId) async {
    final args = {
      'userId': userId,
    };
    return await _doPost($uri('close'), args);
  }

  ///??????????????????
  Future<Map> getRoomAndFamilyInfo(int roomId) async {
    final args = {
      'roomId': roomId,
    };
    return await _doGet($uri('getRoomAndFamilyInfo'), args);
  }

  ///??????????????????
  Future<Map> getRoomFlowDetail(
      {String beginDate,
      String endDate,
      int roomUid,
      int pageNum,
      int pageSize}) async {
    final args = {
      if (beginDate != null) 'beginDate': beginDate,
      if (endDate != null) 'endDate': endDate,
      'pageNum': pageNum,
      'pageSize': pageSize,
      'roomUid': roomUid,
    };
    return await _doGet($uri('getRoomFlowDetail'), args);
  }

  ///??????????????????
  Future<List> listAllRoomFlowDetail() async {
    return await _doGet($uri('listAllRoomFlowDetail'));
  }

  ///????????????
  Future<List> getRoomExpression(int roomID) async {
    final args = {
      'roomId': roomID,
    };

    return await _doGet($uri('getRoomExpression'), args);
  }

  ///??????????????????
  Future<List> getRoomExpressionConfig() async =>
      await _doGet($uri('getRoomExpressionConfig'));

  Future<Map> getHomeRecommendRoom() async =>
      await _doGet($uri('getHomeRecommendRoom'));
}

class _Gift extends Api {
  const _Gift(ApiHost _host, String _basePath) : super._(_host, _basePath);

  Future<List> list() async => (await _doGet($uri('listV3')))['gift'];

  Future<Map> sendGift(int roomUid, int uid, int giftID, int giftNum) async {
    final args = {
      'roomUid': roomUid,
      'giftId': giftID,
      'giftNum': giftNum,
      'targetUid': uid,
      'type': roomUid == uid ? 1 : 3,
    };

    return await _doPost($uri('sendV3'), args);
  }

  // ?????????
  Future<Map> sendWholeMicro(
      int roomUid, Set<int> users, int giftID, int giftNum) async {
    final args = {
      'roomUid': roomUid,
      'giftId': giftID,
      'giftNum': giftNum,
      'targetUids': users.join(','),
    };

    return await _doPost($uri('sendWholeMicroV3'), args);
  }

  // ??????????????????
  Future<Map> sendTypeMonment(
      int uid, int giftID, int giftNum, int dynamicMsgId) async {
    final args = {
      'giftId': giftID,
      'giftNum': giftNum,
      'targetUid': uid,
      'dynamicId': dynamicMsgId,
      'type': 5,
    };

    return await _doPost($uri('sendV3'), args);
  }

  // ??????????????????
  Future<Map> send(int uid, int giftID, int giftNum) async {
    final args = {
      'giftId': giftID,
      'giftNum': giftNum,
      'targetUid': uid,
      'type': 2,
    };

    return await _doPost($uri('sendV3'), args);
  }

  /// ????????????????????????
  Future<List> freeGiftList({
    PageNum page,
  }) async {
    final args = {
      "pageNum": page?.index ?? 1,
      "pageSize": page?.size ?? 10,
    };

    return await _doGet(_host.$new('gift/getFreeGift'), args);
  }

  /// ????????????
  Future exchangeGift({
    String giftId,
  }) async {
    final args = {
      'giftId': giftId,
    };

    return await _doGet(_host.$new('/gift/exchangeGift'), args);
  }

  /// ??????????????????
  Future sendPackageGift({
    String targetUid,
    String giftId,
  }) async {
    final args = {
      'targetUid': targetUid,
      'giftId': giftId,
    };

    return await _doGet(_host.$new('/gift/sendFreeGift'), args);
  }

  /// ??????????????????
  Future<Map> packageGiftList({
    PageNum page,
  }) async {
    final args = {
      "pageNum": page?.index ?? 1,
      "pageSize": page?.size ?? 10,
    };

    return await _doGet(_host.$new('gift/knapsack'), args);
  }

  Future<Map> buyBigHorn(int count, String content) async {
    final args = {
      'count': count,
      'content': content,
    };

    return await _doPost($uri('purchaseBigHorn'), args);
  }

  Future<Map> buyMaxBigHorn(int count, String content) async {
    final args = {
      'count': count,
      'content': content,
    };

    return await _doPost($uri('purchaseMaxBigHorn'), args);
  }
}

class _Moment extends Api {
  const _Moment(ApiHost _host, String _basePath) : super._(_host, _basePath);

  Future<Map> index() async {
//    final Map<String,dynamic> args = {
//      'issue_type': 'once',
//    };

//    return await _doGet($uri('ticket'), args);
    await Future.delayed(Duration(seconds: 1), () => {});
    return {};
  }

  // ????????????
  Future<List> momentList({int type = 1, var subjectId, PageNum page}) async {
    final args = page + {'optType': '$type'};

    if (subjectId != null) {
      args['subjectId'] = subjectId;
    }

    return await _doGet($uri('dynamic/page'), args);
  }

  ///????????????
  Future<bool> postMoment({
    ///??????ID
    int dynamicType = 1,

    ///????????????:1????????????,2????????????
    int attachmentType = 1,

    ///????????????:1??????,2??????,3??????
    String attachmentUrl = '',

    ///????????????,???????????????????????????
    String content = '',

    ///????????????
    int subjectId,

    ///????????????ID
    bool isPass = false,
    var forwardDynamicId,

    ///???????????????ID
  }) async {
    var uid = OAuthCtrl.obj.uid ?? '';
    final args = isPass
        ? {
            'uid': uid,
            'comtent': content,
            'forwardDynamicId': forwardDynamicId,
          }
        : {
            'uid': uid,
            'dynamicType': dynamicType,
            'attachmentType': attachmentType,
            'attachmentUrl': attachmentUrl,
            'comtent': content,
          };
    if (subjectId != null) {
      args['subjectId'] = subjectId;
    }
    return await _doPost(
        $uri(isPass ? 'dynamic/forward' : 'dynamic/add'), args);
  }

  ///????????????
  Future<bool> sendComment({
    ///??????ID
    var dynamicId = 1,

    ///??????????????????ID
    var answerCommentId,

    ///??????????????????ID
    var answerUid,

    ///??????
    String content,
    bool isCommentDynamic = true,

    ///true????????????,false????????????
  }) async {
    var uid = OAuthCtrl.obj.uid ?? '';
    final args = isCommentDynamic
        ? {
            'uid': uid,
            'dynamicId': dynamicId,
            'comment': content,
          }
        : {
            'uid': uid,
            'dynamicId': dynamicId,
            'comment': content,
            'answerCommentId': answerCommentId,
            'answerUid': answerUid,
          };

    return await _doPost($uri('dynamic/comment/add'), args);
  }

  // ????????????
  Future<List> topicList(PageNum page) async {
    final args = page + {};

    return await _doGet($uri('dynamic/subject/page'), args);
  }

  ///????????????
  Future<Map> momentDetail(String dynamicId) async {
    final args = {
      'dynamicId': dynamicId,
    };

    return await _doGet($uri('dynamic/detail'), args);
  }

  ///??????????????????
  Future<List> momentReplyList(var uid, var dynamicId, PageNum page) async {
    final args =
        page + {'dynamicId': dynamicId, 'childPageNum': 1, 'childPageSize': 20};

    return await _doGet($uri('dynamic/comment/page'), args);
  }

  ///????????????
  Future<Map> likeMoment(var dynamicId, {bool isLike = true}) async {
    final args = {
      'dynamicId': dynamicId,
    };

    return await _doGet($uri(isLike ? 'dynamic/unlike' : 'dynamic/like'), args);
  }

  ///??????????????????
  Future<Map> likeMomentComment(var dynamicId, var dynamicCommentId,
      {bool isLike = true}) async {
    final args = {
      'dynamicId': dynamicId,
      'dynamicCommentId': dynamicCommentId,
    };

    return await _doGet(
        $uri(isLike ? 'dynamic/comment/unlike' : 'dynamic/comment/like'), args);
  }

  ///?????????
  Future<bool> black({
    ///???????????????ID
    var blackUid,
  }) async {
    final args = {
      'blackUid': blackUid,
    };

    return await _doPost($uri('dynamic/blacklist/add'), args);
  }

  ///???????????????
  Future<bool> delBlack({
    ///???????????????ID
    var blackId,
  }) async {
    final args = {
      'id': blackId,
    };

    return await _doPost($uri('dynamic/blacklist/del'), args);
  }

  ///???????????????
  Future<List> blackList(PageNum page) async {
    final args = {
      "pageNum": page.index,
      "pageSize": page.size,
    };

    return await _doGet($uri('dynamic/blacklist/page'), args);
  }

  ///????????????
  Future<bool> report({
    ///??????ID
    var dynamicId = 1,

    ///???????????????ID
    var reportUid,

    ///??????????????????
    var reportReasonCode,

    ///????????????
    String reportReason,
  }) async {
    final args = {
      'dynamicId': dynamicId,
      'reportUid': reportUid,
      'reportReasonCode': reportReasonCode,
      'reportReason': reportReason,
    };

    return await _doPost($uri('dynamic/report/reason/add'), args);
  }

  ///????????????
  Future<bool> reportUser({
    ///???????????????ID
    var reportUid,
    bool isRoom,

    ///??????????????????
    var reportType,
  }) async {
    final args = {
      'reportUid': OAuthCtrl.obj.uid ?? '',
      'uid': reportUid,
      'type': isRoom ? 2 : 1,

      ///??????: 1,?????? 2,??????
      'reportType': reportType,
    };

    return await _doPost($uri('report/save'), args);
  }

  ///??????????????????
  Future<List> reportReasonList({bool isDynamic = false}) async {
    final args = {
      'random': '1',
    };

    return await _doGet(
        $uri(isDynamic ? 'dynamic/report/reason/list' : 'report/get/type'),
        args);
  }

  ///????????????
  Future delMoment({
    var dynamicId,
  }) async {
    final args = {
      'dynamicId': dynamicId,
    };

    return await _doGet(host.$new('user/dynamic/delete'), args);
  }

  ///????????????
  Future delMomentReply({
    var dynamicCommentId,
  }) async {
    final args = {
      'dynamicCommentId': dynamicCommentId,
    };

    return await _doGet(host.$new('user/dynamic/comment/delete'), args);
  }

  // ??????????????????
  Future<List> myMomentList(int uid, PageNum page) async {
    final args = {
      'uid': uid,
      "pageNum": page.index,
      "pageSize": page.size,
    };

    return await _doGet($uri('dynamic/my/page'), args);
  }

  /// ????????????
  Future<dynamic> getMaterialAvatar() async {
    return await _doGet($uri('getMaterialAvatar'));
  }
}

class _Family extends Api {
  const _Family(ApiHost _host, String _basePath) : super._(_host, _basePath);

  // ????????????uid???????????????????????????
  Future<dynamic> checkFamilyJoin() async {
    final args = {
      'userId': OAuthCtrl.obj.uid,
    };
    var data = await _doGet($uri('checkFamilyJoin'), args);
    return UserSocietyInfo(data).data;
  }

  // ????????????uid??????????????????
  Future<Map> userFamily({int uid}) async {
    final args = {
      'userId': uid ?? OAuthCtrl.obj.uid,
    };

    return await _doGet($uri('getJoinFamilyInfo'), args);
  }

  // ????????????
  Future<Map> familyList({int uid, PageNum page, String searchTest}) async {
    final args = {
      if (uid != null) 'uid': '$uid',
      "current": page.index,
      "pageSize": page.size,
    };
    if (searchTest != null) {
      args['searchTest'] = searchTest;
    }
    return await _doGet($uri('getList'), args);
  }

  ///????????????
  Future<List> searchSociety(String key, PageNum page) async {
    final args = page + {'key': key};

    return await _doGet(_host.$new('search/room'), args);
  }

  // ????????????
  Future<Map> createFamily(
      {int uid,
      String name,
      String notice,
      String synopsis,
      String logo}) async {
    final args = {
      'userId': uid ?? OAuthCtrl.obj.uid,
      'hall': '',
      "name": name,
      "synopsis": synopsis,
      "notice": notice,
      "logo": logo,
    };
    return await _doPost($uri('createFamilyTeam'), args);
  }

  // ????????????
  Future<Map> editFamilyTeam(
      {int familyId,
      String name,
      String notice,
      String synopsis,
      String logo}) async {
    final args = {
      "name": name,
      "synopsis": synopsis,
      "notice": notice,
      "logo": logo,
      "familyId": familyId,
    };
    return await _doPost($uri('editFamilyTeam'), args);
  }

  // ????????????????????????
  Future cancelApplyCreateFamily({String familyId, String userId}) async {
    final args = {
//      'familyId': familyId,
      'uid': userId ?? OAuthCtrl.obj.uid,
    };
    return await _doPost($uri('cancelCreateFamilyTeam'), args);
  }

  // ????????????
  Future<Map> devoteIntegral({int uid, String integral}) async {
    final args = {'integral': integral, 'uid': uid ?? OAuthCtrl.obj.uid};
    return await _doPost($uri('devoteIntegral'), args);
  }

  // ????????????????????????
  Future<List> getContributionList(
      {int familyId, String current, String pageSize}) async {
    final args = {
      'familyId': familyId,
      'pageNum': current,
      'pageSize': pageSize,
    };
    return await _doPost($uri('getUserIntegralList'), args);
  }

  // ????????????????????????v2
  Future<Map> getContributionListV2(
      {int familyId, String current, String pageSize}) async {
    final args = {
      'familyId': familyId,
      'pageNum': current,
      'pageSize': pageSize,
    };
    return await _doPost($uri('v2/getUserIntegralList'), args);
  }

  //  ????????????Id????????????????????????
  Future<List> getRoomInfo({int familyId, int pageNum, int pageSize}) async {
    final args = {
      'familyId': familyId,
      'pageNum': pageNum,
      'pageSize': pageSize,
    };
    return await _doPost($uri('getRoomInfo'), args);
  }

  //????????????????????????
  Future<Map> getFamilyTeamJoin(
      {int uid,
      String current,
      String pageSize,
      String familyId,
      int type}) async {
    final args = {
      'uid': uid ?? OAuthCtrl.obj.uid,
      'current': current,
      'pageSize': pageSize,
      'familyId': familyId,
      'type': type ?? 0,
    };
    return await _doGet($uri('getFamilyTeamJoin'), args);
  }

  // ?????????????????????
  Future<List> getAdminList({int uid, String current, String pageSize}) async {
    final args = {
      'uid': uid ?? OAuthCtrl.obj.uid,
      'pageNum': current,
      'pageSize': pageSize,
    };
    return await _doPost($uri('getAdminList'), args);
  }

  //??????????????????
  Future<List> applyExitTeam({String familyId, String userId}) async {
    final args = {
      'userId': userId ?? OAuthCtrl.obj.uid,
      'familyId': familyId,
    };
    return await _doPost($uri('applyExitTeam'), args);
  }

  //??????????????????
  Future<List> forceExitTeam({String familyId, String userId}) async {
    final args = {
      'userId': userId ?? OAuthCtrl.obj.uid,
      'familyId': familyId,
    };
    return await _doPost($uri('forceExitTeam'), args);
  }

  //??????????????????  ????????????
  Future<List> applyFamily(
      {String familyId, String userId, String status, String type}) async {
    final args = {
      'userId': userId, //????????????ID
      'familyId': familyId,
      'status': status, //??????(1.??????,2.??????)
      'type': type, //??????(1.?????? 2.??????)
    };
    return await _doPost($uri('applyFamily'), args);
  }

  //?????????????????????
  Future<List> applyList(
      {String familyId, int pageNum, int pageSize, String type}) async {
    final args = {
      'familyId': familyId, //????????????ID
      'pageNum': pageNum,
      'pageSize': pageSize, //??????(1.??????,2.??????)
      'type': type, //??????(1.?????? 2.??????)
    };
    return await _doPost($uri('applyList'), args);
  }

  // ????????????
  Future<List> kickOutTeam({String familyId, List userIds}) async {
    final args = {
      'familyId': familyId,
      'userIds': userIds.join(','),
    };
    return await _doPost($uri('kickOutTeam'), args);
  }

  // ??????????????????
  Future applyJoinFamilyTeam({String familyId, String userId}) async {
    final args = {
      'familyId': familyId,
      'userId': userId ?? OAuthCtrl.obj.uid,
    };
    return await _doPost($uri('applyJoinFamilyTeam'), args);
  }

  // ????????????????????????
  Future cancelApplyJoinFamilyTeam({String familyId, String userId}) async {
    final args = {
      'familyId': familyId,
      'userId': userId ?? OAuthCtrl.obj.uid,
    };
    return await _doPost($uri('cancelJoinTeam'), args);
  }

  // ??????????????????
  Future cancelApplyOutFamilyTeam({String familyId, String userId}) async {
    final args = {
      'familyId': familyId,
      'userId': userId ?? OAuthCtrl.obj.uid,
    };
    return await _doPost($uri('cancelExitTeam'), args);
  }

  //????????????????????????
  Future<Map> getIntegral() async => await _doPost($uri('getIntegral'));

  // ?????????????????????
  Future<Map> removeAdmin(
      {String familyId, String userId, List userIds}) async {
    final args = {
      'familyId': familyId,
      'userId': userId ?? OAuthCtrl.obj.uid,
      'userIds': userIds.join(','),
    };
    return await _doPost($uri('removeAdmin'), args);
  }

  // ?????????????????????
  Future<Map> setupAdministrator(
      {String familyId, String userId, List userIds}) async {
    final args = {
      'familyId': familyId,
      'userId': userId ?? OAuthCtrl.obj.uid,
      'userIds': userIds.join(','),
    };
    return await _doPost($uri('setupAdministrator'), args);
  }

  // ??????????????????
  Future<dynamic> getUserIntegral({String userId}) async {
    final args = {
      'uid': userId ?? OAuthCtrl.obj.uid,
    };
    return await _doPost($uri('getUserIntegral'), args);
  }

  // ????????????
  Future<dynamic> delFamily({String userId}) async {
    final args = {
      'uid': userId ?? OAuthCtrl.obj.uid,
    };
    return await _doPost($uri('delFamily'), args);
  }

  // ??????FamilyId??????????????????
  Future<Map> getFamilyInfo({int familyId}) async {
    final args = {
      'familyId': familyId,
    };
    return await _doPost($uri('getFamilyInfo'), args);
  }
}

class _Task extends Api {
  const _Task(ApiHost _host, String _basePath) : super._(_host, _basePath);

  // ??????????????????
  Future<Map> coinInfo() async {
    final args = {
      'uid': OAuthCtrl.obj.uid,
    };
    return await _doPost($uri('v1/getMcoinNum'), args);
  }

  //  ??????????????????,type:??????(1????????????2????????????3????????????)
  Future<List> taskList({
    int type,
  }) async {
    final args = {
      'uid': OAuthCtrl.obj.uid,
      'type': type,
    };
    return await _doGet($uri('v1/getInfo'), args);
  }

  //  ??????
  Future sign() async {
    final args = {
      'uid': OAuthCtrl.obj.uid,
    };
    return await _doGet($uri('v1/weeklyMission'), args);
  }

  //  ??????????????????
  Future checkSign() async {
    final args = {
      'uid': OAuthCtrl.obj.uid,
    };
    return await _doGet(_host.$new('mcoin/v1/isWeeklyMission'), args);
  }

  //  ????????????
  Future gainCoin({String missionId}) async {
    final args = {'uid': OAuthCtrl.obj.uid, 'missionId': missionId};
    return await _doPost($uri('v1/gainMcoin'), args);
  }
}

class _Draw extends Api {
  const _Draw(ApiHost _host, String _basePath) : super._(_host, _basePath);

  Future<List> list() async => await _doGet($uri('list'));

  Future<Map> doDraw() async => await _doGet($uri('do'));

  Future<Map> getWord() async => await _doGet($uri('getWord'));

  Future<Map> roomDraw(int roomID, int type, int drawType) async {
    final args = {
      'roomId': roomID,
      'type': type,
      'drawType': drawType,
    };

    return await _doPost(_host.$new('user/giftPurse/v3/draw'), args);
  }

  Future<List> giftList() async =>
      await _doGet(_host.$new('user/giftPurse/getPrizePoolGift'));

  //????????????????????????
  Future<List> queryUserTransfer(
    int pageNum,
    int pageSize,
  ) async {
    final args = {'pageNum': pageNum, 'pageSize': pageSize};
    return await _doGet(_host.$new('withDraw/queryUserTransfer'), args);
  }

  // ????????????????????????
  Future<dynamic> updateUserTransfer(int id) async {
    final args = {'id': id};
    return await _doGet(_host.$new('withDraw/updateUserTransfer'), args);
  }
}

class _Wx extends Api {
  const _Wx(ApiHost _host, String _basePath) : super._(_host, _basePath);

  //??????????????????url
  Future<dynamic> getWxH5ChargeUrl() async =>
      await _doGet($uri('getWxH5ChargeUrl'));
}

class _Packet extends Api {
  const _Packet(ApiHost _host, String _basePath) : super._(_host, _basePath);

  Future send(int toUid, int amount, String remark) async {
    final args = {
      'targetUid': toUid,
      'packetNum': amount,
      'remark': remark,
    };

    return await _doPost($uri('sendPacket'), args);
  }

  Future<Map> info(int id) async {
    final args = {'id': id};

    return await _doGet($uri('getPacketInfo'), args);
  }

  ///??????
  Future receive(int id) async {
    final args = {'id': id};

    return await _doPost($uri('receivePacket'), args);
  }

  ///??????
  Future withdraw(int id) async {
    final args = {'id': id};

    return await _doPost($uri('withdrawPacket'), args);
  }

  ///????????????
  Future<List> queryPacketInfo(PageNum page) async {
    final args = {
      'pageNum': page.index,
      'pageSize': page.size,
    };
    return await _doGet($uri('queryPacketInfo'), args);
  }
}

class _Auction extends Api {
  const _Auction(ApiHost _host, String _basePath) : super._(_host, _basePath);

  Future<List> list(String search, int orderType, PageNum page) async {
    final args = {
      'orderType': orderType,
      'searchText': search,
      'pageNum': page.index,
      'pageSize': page.size,
    };

    return await _doGet($uri('list'), args);
  }

  Future<List> listMyAuction(int type, int orderType, PageNum page) async {
    final args = {
      'type': type,
      'orderType': orderType,
      'pageNum': page.index,
      'pageSize': page.size,
    };

    return await _doGet($uri('listMyAuction'), args);
  }

  Future<void> shelf(int id, int num, double percent) async {
    final args = {
      'giftId': id,
      'giftNum': num,
      'giftPercentage': percent,
    };

    return await _doPost($uri('shelf'), args);
  }

  Future<void> purchase(int orderID) async {
    final args = {
      'id': orderID,
    };

    return await _doPost($uri('purchase'), args);
  }

  Future<void> onShelf(int orderID) async {
    final args = {
      'id': orderID,
    };

    return await _doPost($uri('onShelf'), args);
  }

  Future<void> offShelf(int orderID) async {
    final args = {
      'id': orderID,
    };

    return await _doPost($uri('OffShelf'), args);
  }

  Future<void> delRecord(int orderID) async {
    final args = {
      'id': orderID,
    };

    return await _doPost($uri('delRecord'), args);
  }
}
