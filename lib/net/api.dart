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
  static const Moment = _Moment(host, 'user'); //动态
  static const Family = _Family(host, 'family'); //公会
  static const Task = _Task(host, 'mcoin'); //公会
  static const Draw = _Draw(host, 'draw');
  static const Wx = _Wx(host, 'wx');
  static const Packet = _Packet(host, 'packet');
  static const Auction = _Auction(host, 'auctionhouse');
}

class _Home extends Api {
  const _Home(ApiHost _host, String _basePath) : super._(_host, _basePath);

  ///首页标签
  Future<List> homeTag() async => await _doGet($uri('getRoomTag'));

  Future<List> tagIndex(int id, PageNum page) async {
    final args = page + {'tagId': id};

    return await _doGet($uri('v2/tagindex'), args);
  }

  /// 获取宝箱参数
  Future<Map> getConfig() async {
    var uid = OAuthCtrl.obj.uid ?? '';
    final args = {
      'uid': uid,
    };
    return await _doGet($uri('config'), args);
  }

  ///首页banner
  Future<List> getIndexTopBanner() async {
    return await _doGet($uri('getIndexTopBanner'), {});
  }

  ///根据uid获取关注房间列表
  Future<List> getRoomAttentionByUid(PageNum page) async {
    final args = page + {};

    return await _doGet(
        _host.$new('room/attention/getRoomAttentionByUid'), args);
  }

  ///关注页面的推荐房间列表
  Future<List> getRecommendUsers(PageNum page) async {
    final args = page + {};

    return await _doGet(_host.$new('user/getRecommendUsers'), args);
  }

  ///根据uid获取关注好友
  Future<List> getRoomRecommendList(PageNum page) async {
    final args = page + {};

    return await _doGet(_host.$new('room/getRoomRecommendList'), args);
  }

  ///我的足迹
  Future<List> historyList() async {
    final Map<String, dynamic> args = {};
    var data = await _doGet(_host.$new('userroom/in/history'), args);
    return data ?? [];
  }

  ///清空足迹
  Future clearRoomHistory() async {
    final Map<String, dynamic> args = {};

    return await _doGet(_host.$new("userroom/in/history/clean"), args);
  }

  ///关注房间
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

  ///关注用户
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

  ///首页(连麦聊)
  Future<List> getHomeChitchat() async {
    return await _doGet(_host.$new('room/rcmd/linkmic'));
  }

  ///(新鲜事)
  Future<List> dynamicList(PageNum page) async {
    final args = page + {};

    return await _doGet($uri('room/dynamic/page'), args);
  }

  ///(陪陪)
  Future<List> bestCompanies(PageNum page) async {
    final args = page + {};

    return await _doGet($uri('bestCompanies'), args);
  }

  ///(萌新)
  Future<List> newUsers(PageNum page) async {
    final args = page + {};

    return await _doGet($uri('newUsers'), args);
  }

  ///搜索房间
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

  // iOS 审核状态 0表示在审核
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

  ///获取排行榜
  ///type排行榜类型 1巨星榜，2贵族榜，3房间榜
  ///datetype榜单周期类型 0日榜，1周榜，2总榜
  ///服务器的type从1开始
  Future<List> getRankingList(String type, String datetype) async {
    final args = {'type': type, 'datetype': datetype};
    var data = await _doGet(_host.$new('allrank/geth5'), args);
    return data['rankVoList'] ?? [];
  }

  ///获取礼物排行榜
  ///dateType榜单周期类型 0日榜，1周榜，2总榜
  Future<List> getRankGiftList(String dateType) async {
    final args = {'dateType': dateType};
    var data = await _doGet(_host.$new('allrank/getGiftRank'), args);
    return data ?? [];
  }

  ///获取礼物详情
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

  //APP信息
  Future<Map> versionInfo() async {
    return await _doGet(_host.$new('version/get'));
  }

  /// 更新用户信息
  Future<Map> updateUserInfo(Map<String, dynamic> args) async {
    return await _doPost(_host.$new('user/update'), args);
  }

  /// 添加个人相册图片
  Future<Map> addPhoto(String photoStr) async {
    final args = {
      'photoStr': photoStr,
    };
    return await _doPost(_host.$new('photo/upload'), args);
  }

  /// 删除个人相册图片
  Future<Map> deletePhoto(String pid) async {
    final args = {'pid': pid};

    return await _doPost(_host.$new('photo/delPhoto'), args);
  }

  /// 获取钱包信息
  Future<Map> getWalletInfos() async {
    final args = {
      'Cache-Control': 'no-cache',
    };
    return await _doGet(_host.$new('purse/query'), args);
  }

  /// 兑换海星
  Future<dynamic> exchangeGold(int exchangeNum) async {
    final args = {
      'exchangeNum': exchangeNum,
    };
    return await _doPost(_host.$new('purse/exchangeGold'), args);
  }

  /// 获取充值产品列表
  Future<List> getChargeList() async {
    final args = {
      'channelType': '1',
    };
    return await _doGet(_host.$new('chargeprod/list'), args);
  }

  /// 获取提现产品列表
  Future<List> getFindList() async =>
      await _doGet(_host.$new('withDraw/findList'));

  /// 内购下单
  Future<Map> orderInApp(String chargeProdId) async {
    final args = {
      'chargeProdId': chargeProdId,
    };
    return await _doPost(_host.$new('order/place'), args);
  }

  /// 校验内购是否成功
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

  ///充值
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

  /// 获取魅力等级
  Future<dynamic> getLevelCharm() => _doGet(_host.$new('level/charm/get'), {});

  /// 获取财富等级
  Future<dynamic> getLevelWealth() =>
      _doGet(_host.$new('level/wealth/get'), {});

  /// 获取经验等级
  Future<dynamic> getLevelExperience() =>
      _doGet(_host.$new('level/experience/get'), {});

  /// 获取充值消费记录
  Future<List> billrecordGet(int type, String pageNo) async {
    final args = {
      'pageNo': pageNo,
      'pageSize': '10',
      'date': TimeUtils.getNowDateMs(),
      'type': type,

      ///1礼物支出,2礼物收入,3密聊记录,4充值记录,
    };
    return await _doGet(_host.$new('billrecord/get'), args);
  }

  /// 获取珊瑚记录
  Future<List> coralRecord(String pageNo) async {
    final args = {
      'pageNum': pageNo,
      'pageSize': '10',
    };
    return await _doGet(_host.$new('mcoin/getMcoinList'), args);
  }

  /// 获取点点币信息
  Future<Map> getDianDianCoinInfos() async {
    return await _doPost(_host.$new('mcoin/v1/getMcoinNum'));
  }

  /// 用户提交反馈
  Future<Map> commitFeedback(String feedbackDesc, String contact) async {
    final args = {
      'contact': contact,
      'feedbackDesc': feedbackDesc,
    };
    return await _doPost(_host.$new('feedback'), args);
  }

  /// 礼物，密聊，充值，提现账单查询（不包括红包）
  Future<Map> getBillRecord(String date, String type, PageNum page) async {
    final args = page + {'date': date, 'type': type};

    return await _doGet(_host.$new('billrecord/get'), args);
  }

  /// 热门活动
  Future<List> activityQuery() async {
    final args = {
      'type': '1',
    };
    return await _doGet(_host.$new('activity/query'), args);
  }

  /// 全部活动
  Future<List> activityAll() async =>
      await _doGet(_host.$new('activity/queryAll'), {});

  /// 粉丝列表
  Future<List> fansList(PageNum page) async {
    final args = page + {};

    return (await _doGet(_host.$new('fans/fanslist'), args))['fansList'];
  }

  /// 关注列表
  Future<List> following(PageNum page) async {
    final args = page + {};

    // ！！！
    args['pageNo'] = args.remove('pageNum');

    return await _doGet(_host.$new('fans/following'), args);
  }

  /// 好友列表
  Future<List> friend() async {
    return await _doGet(_host.$new('fans/friend'));
  }

  /// 今日访客
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

  /// 获取青少年模式信息
  Future<Map> getUsersTeensMode() async {
    return await _doGet(_host.$new('users/teens/mode/getUsersTeensMode'));
  }

  /// 开启青少年模式
  Future<Map> saveTeensMode(String cipherCode) async {
    final args = {
      'cipherCode': cipherCode,
    };
    return await _doPost(_host.$new('users/teens/mode/save'), args);
  }

  /// 关闭青少年模式
  Future closeTeensMode() async {
    return await _doPost(_host.$new('/users/teens/mode/closeTeensMode'));
  }

  /// 校验青少年接口密码
  Future<bool> checkCipherCode(String cipherCode) async {
    final args = {
      'cipherCode': cipherCode,
    };

    return await _doGet(_host.$new('/users/teens/mode/checkCipherCode'), args);
  }

  /// 查询认证信息
  Future<Map> getCertifyInfo() async {
    return await _doGet($uri('realname/v1/get'));
  }

  /// 认证信息
  Future<Map> certify({
    String idcardFront,

    ///身份证正面照
    String idcardHandheld,

    ///手持身份证照
    String idcardNo,

    ///身份证号码
    String idcardOpposite,

    ///身份证反面照
    String phone,

    ///用户手机号
    String realName,

    ///用户真实名字
    String smsCode,

    ///用户手机验证码
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

  /// 绑定手机号
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

  /// 重置密码
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

  /// 修改密码
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

  /// 绑定手机号验证码
  Future<Map> bindPhoneSMS({
    String phone,
  }) async {
    final args = {
      'phone': phone,
    };
    return await _doPost($uri('getSendSms'), args);
  }

  /// 获取收到的礼物列表
  Future<Map> userGiftList({
    bool isNormal = true,

    ///true,普通礼物，false神秘礼物
    String userId,
    int orderType = 2,
    int type = 1,

    ///类型0全部1已获得2未获得
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

  /// 获取头饰列表
  Future<Map> userHeadList({
    String userId,
    PageNum page,
    int type = 1,

    ///类型0全部1已获得2未获得
  }) async {
    final args = {
      'queryUid': userId,
      "type": type,
    };

    return await _doPost(_host.$new('headwear/user/list'), args);
  }

  /// 获取座驾列表
  Future<Map> userCarList({
    String userId,
    PageNum page,
    int type = 1,

    ///类型0全部1已获得2未获得
  }) async {
    final args = {
      'queryUid': userId,
      "type": type,
    };

    return await _doPost(_host.$new('giftCar/user/list'), args);
  }

  /// 获取商成头饰列表
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

  /// 获取商城座驾列表
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

  /// 赠送座驾
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

  /// 购买座驾
  Future buyCar({
    String carId,
  }) async {
    final args = {
      'carId': carId,
    };

    return await _doPost(_host.$new('giftCar/purse'), args);
  }

  /// 设置座驾
  Future setCar({
    String carId,
  }) async {
    final args = {
      'carId': carId,
    };

    return await _doPost(_host.$new('giftCar/use'), args);
  }

  /// 赠送头饰
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

  /// 购买头饰
  Future buyHead({
    String headwearId,
  }) async {
    final args = {
      'headwearId': headwearId,
    };

    return await _doPost(_host.$new('headwear/purse'), args);
  }

  /// 设置头饰
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

  ///在线统计
  Future<String> onLine() async {
    return await _doPost(_host.$new('mcoin/v1/online'));
  }

  /// 获取客服中心
  Future<Map> getCustomer() async {
    return await _doGet(_host.$new('customer/get'));
  }

  /// 获取奖池礼物
  Future<List> getPrizePoolGift() async {
    return await _doGet($uri('giftPurse/getPrizePoolGift'));
  }

  Future<List> getMaxPrizePoolGift() async {
    return await _doGet($uri('giftPurse/getMaxPrizePoolGift'));
  }

  Future<List> getMaxPrizeSeniority() async {
    return await _doGet($uri('giftPurse/getMaxPrizeSeniority'));
  }

  /// 获取礼物记录
  Future<List> giftPurseRecord(int drawType, int pageNum, int pageSize) async {
    final args = {
      'drawType': drawType,
      'pageNum': pageNum,
      'pageSize': pageSize,
    };
    return await _doGet($uri('giftPurse/record'), args);
  }

  /// 获取手气榜单
  Future<List> getTopRank(int drawType, int pageNum, int pageSize) async {
    final args = {
      'drawType': drawType,
      'pageNum': pageNum,
      'pageSize': pageSize,
    };
    return await _doGet($uri('giftPurse/getTopRank'), args);
  }

  /// 获取投入产出
  Future<Map> getInvestAndReturn(int type) async {
    var uid = OAuthCtrl.obj.uid ?? '';
    final args = {
      'uid': uid,
      'drawType':type
    };
    return await _doGet($uri('giftPurse/todayTreasure'), args);
  }

  /// 绑定提现账户
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

  /// 获取所有提现账户
  Future<Map> getFinancialAccount() async {
    return await _doGet(_host.$new('withDraw/getFinancialAccount'));
  }

  /// 珍珠提现V2
  Future<dynamic> withDrawCashv2(String pid, String type, String code) async {
    final args = {
      'pid': pid,
      'type': type,
      'code': code,
    };
    return await _doPost(_host.$new('withDraw/v2/withDrawCash'), args);
  }

  /// 获取邀请码
  Future<Map> getInviteCode() async {
    return await _doGet($uri('v2/getInviteCode'));
  }

  /// 获取邀请码列表
  Future<List> getInviteCodeRecord() async {
    return await _doGet($uri('getInviteCodeRecord'));
  }

  /// 支付宝实名认证生成认证服务请求地址
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

  ///type,1注册，2登录，3重置密码
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

  ///用户创建房间
  Future<Map> createRoom(
      int familyID, String title, String avatar, int tag, String bg) async {
    final args = {
      'type': 3, //目前只支持3
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

  ///用户修改房间
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
    // 通知服务端
    _doPost(
        host.$new('userroom/kickMember'), {'roomId': roomID, 'kickUid': uid});

    final args = {
      'uid': myUid,
      'room_id': roomID,
      'account': uid,
    };

    return await _doPost(host.$new('imroom/v1/kickMember'), args);
  }

  // 删除公会房间
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

  ///清除个人魅力值接口
  Future<dynamic> receiveRoomMicMsg(int roomUid, {int userid = -1}) async {
    final args = {
      'roomUid': roomUid,
      'userid': userid,
    };
    return await _doGet($uri('receiveRoomMicMsg'), args);
  }

  // deleteRoomCharm
  ///清除房间魅力值接口
  Future<dynamic> deleteRoomCharm(int roomUid) async {
    final args = {
      'roomUid': roomUid,
    };
    return await _doGet($uri('deleteRoomCharm'), args);
  }

  ///是否关注房间
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

  ///关闭房间
  Future<dynamic> close(int userId) async {
    final args = {
      'userId': userId,
    };
    return await _doPost($uri('close'), args);
  }

  ///获取房间详情
  Future<Map> getRoomAndFamilyInfo(int roomId) async {
    final args = {
      'roomId': roomId,
    };
    return await _doGet($uri('getRoomAndFamilyInfo'), args);
  }

  ///获取房间流水
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

  ///获取房间流水
  Future<List> listAllRoomFlowDetail() async {
    return await _doGet($uri('listAllRoomFlowDetail'));
  }

  ///房间表情
  Future<List> getRoomExpression(int roomID) async {
    final args = {
      'roomId': roomID,
    };

    return await _doGet($uri('getRoomExpression'), args);
  }

  ///房间表情配置
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

  // 全麦送
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

  // 送给动态个人
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

  // 送给房间个人
  Future<Map> send(int uid, int giftID, int giftNum) async {
    final args = {
      'giftId': giftID,
      'giftNum': giftNum,
      'targetUid': uid,
      'type': 2,
    };

    return await _doPost($uri('sendV3'), args);
  }

  /// 获取兑换礼物列表
  Future<List> freeGiftList({
    PageNum page,
  }) async {
    final args = {
      "pageNum": page?.index ?? 1,
      "pageSize": page?.size ?? 10,
    };

    return await _doGet(_host.$new('gift/getFreeGift'), args);
  }

  /// 兑换礼物
  Future exchangeGift({
    String giftId,
  }) async {
    final args = {
      'giftId': giftId,
    };

    return await _doGet(_host.$new('/gift/exchangeGift'), args);
  }

  /// 赠送背包礼物
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

  /// 背包礼物列表
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

  // 动态列表
  Future<List> momentList({int type = 1, var subjectId, PageNum page}) async {
    final args = page + {'optType': '$type'};

    if (subjectId != null) {
      args['subjectId'] = subjectId;
    }

    return await _doGet($uri('dynamic/page'), args);
  }

  ///发布动态
  Future<bool> postMoment({
    ///用户ID
    int dynamicType = 1,

    ///动态类型:1普通动态,2发布心愿
    int attachmentType = 1,

    ///附件类型:1图片,2语音,3视频
    String attachmentUrl = '',

    ///附件地址,多个地址用逗号间隔
    String content = '',

    ///动态文字
    int subjectId,

    ///所属话题ID
    bool isPass = false,
    var forwardDynamicId,

    ///被转发动态ID
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

  ///发送评论
  Future<bool> sendComment({
    ///动态ID
    var dynamicId = 1,

    ///被回复的评论ID
    var answerCommentId,

    ///被回复的用户ID
    var answerUid,

    ///评论
    String content,
    bool isCommentDynamic = true,

    ///true评论动态,false评论回复
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

  // 话题列表
  Future<List> topicList(PageNum page) async {
    final args = page + {};

    return await _doGet($uri('dynamic/subject/page'), args);
  }

  ///动态详情
  Future<Map> momentDetail(String dynamicId) async {
    final args = {
      'dynamicId': dynamicId,
    };

    return await _doGet($uri('dynamic/detail'), args);
  }

  ///动态回复列表
  Future<List> momentReplyList(var uid, var dynamicId, PageNum page) async {
    final args =
        page + {'dynamicId': dynamicId, 'childPageNum': 1, 'childPageSize': 20};

    return await _doGet($uri('dynamic/comment/page'), args);
  }

  ///点赞动态
  Future<Map> likeMoment(var dynamicId, {bool isLike = true}) async {
    final args = {
      'dynamicId': dynamicId,
    };

    return await _doGet($uri(isLike ? 'dynamic/unlike' : 'dynamic/like'), args);
  }

  ///点赞动态评论
  Future<Map> likeMomentComment(var dynamicId, var dynamicCommentId,
      {bool isLike = true}) async {
    final args = {
      'dynamicId': dynamicId,
      'dynamicCommentId': dynamicCommentId,
    };

    return await _doGet(
        $uri(isLike ? 'dynamic/comment/unlike' : 'dynamic/comment/like'), args);
  }

  ///黑名单
  Future<bool> black({
    ///被拉黑用户ID
    var blackUid,
  }) async {
    final args = {
      'blackUid': blackUid,
    };

    return await _doPost($uri('dynamic/blacklist/add'), args);
  }

  ///删除黑名单
  Future<bool> delBlack({
    ///被拉黑用户ID
    var blackId,
  }) async {
    final args = {
      'id': blackId,
    };

    return await _doPost($uri('dynamic/blacklist/del'), args);
  }

  ///黑名单列表
  Future<List> blackList(PageNum page) async {
    final args = {
      "pageNum": page.index,
      "pageSize": page.size,
    };

    return await _doGet($uri('dynamic/blacklist/page'), args);
  }

  ///举报动态
  Future<bool> report({
    ///动态ID
    var dynamicId = 1,

    ///被举报用户ID
    var reportUid,

    ///举报原因编码
    var reportReasonCode,

    ///举报原因
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

  ///举报用户
  Future<bool> reportUser({
    ///被举报用户ID
    var reportUid,
    bool isRoom,

    ///举报原因编码
    var reportType,
  }) async {
    final args = {
      'reportUid': OAuthCtrl.obj.uid ?? '',
      'uid': reportUid,
      'type': isRoom ? 2 : 1,

      ///类型: 1,用户 2,房间
      'reportType': reportType,
    };

    return await _doPost($uri('report/save'), args);
  }

  ///举报原因列表
  Future<List> reportReasonList({bool isDynamic = false}) async {
    final args = {
      'random': '1',
    };

    return await _doGet(
        $uri(isDynamic ? 'dynamic/report/reason/list' : 'report/get/type'),
        args);
  }

  ///删除动态
  Future delMoment({
    var dynamicId,
  }) async {
    final args = {
      'dynamicId': dynamicId,
    };

    return await _doGet(host.$new('user/dynamic/delete'), args);
  }

  ///删除回复
  Future delMomentReply({
    var dynamicCommentId,
  }) async {
    final args = {
      'dynamicCommentId': dynamicCommentId,
    };

    return await _doGet(host.$new('user/dynamic/comment/delete'), args);
  }

  // 我的动态列表
  Future<List> myMomentList(int uid, PageNum page) async {
    final args = {
      'uid': uid,
      "pageNum": page.index,
      "pageSize": page.size,
    };

    return await _doGet($uri('dynamic/my/page'), args);
  }

  /// 随机头像
  Future<dynamic> getMaterialAvatar() async {
    return await _doGet($uri('getMaterialAvatar'));
  }
}

class _Family extends Api {
  const _Family(ApiHost _host, String _basePath) : super._(_host, _basePath);

  // 获取根据uid检测是否有加入公会
  Future<dynamic> checkFamilyJoin() async {
    final args = {
      'userId': OAuthCtrl.obj.uid,
    };
    var data = await _doGet($uri('checkFamilyJoin'), args);
    return UserSocietyInfo(data).data;
  }

  // 获取根据uid获取公会信息
  Future<Map> userFamily({int uid}) async {
    final args = {
      'userId': uid ?? OAuthCtrl.obj.uid,
    };

    return await _doGet($uri('getJoinFamilyInfo'), args);
  }

  // 公会列表
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

  ///搜索公会
  Future<List> searchSociety(String key, PageNum page) async {
    final args = page + {'key': key};

    return await _doGet(_host.$new('search/room'), args);
  }

  // 创建公会
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

  // 编辑公会
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

  // 取消申请创建公会
  Future cancelApplyCreateFamily({String familyId, String userId}) async {
    final args = {
//      'familyId': familyId,
      'uid': userId ?? OAuthCtrl.obj.uid,
    };
    return await _doPost($uri('cancelCreateFamilyTeam'), args);
  }

  // 积分贡献
  Future<Map> devoteIntegral({int uid, String integral}) async {
    final args = {'integral': integral, 'uid': uid ?? OAuthCtrl.obj.uid};
    return await _doPost($uri('devoteIntegral'), args);
  }

  // 获取积分贡献列表
  Future<List> getContributionList(
      {int familyId, String current, String pageSize}) async {
    final args = {
      'familyId': familyId,
      'pageNum': current,
      'pageSize': pageSize,
    };
    return await _doPost($uri('getUserIntegralList'), args);
  }

  // 获取积分贡献列表v2
  Future<Map> getContributionListV2(
      {int familyId, String current, String pageSize}) async {
    final args = {
      'familyId': familyId,
      'pageNum': current,
      'pageSize': pageSize,
    };
    return await _doPost($uri('v2/getUserIntegralList'), args);
  }

  //  根据公会Id获取成员房间信息
  Future<List> getRoomInfo({int familyId, int pageNum, int pageSize}) async {
    final args = {
      'familyId': familyId,
      'pageNum': pageNum,
      'pageSize': pageSize,
    };
    return await _doPost($uri('getRoomInfo'), args);
  }

  //获取公会成员信息
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

  // 获取管理员列表
  Future<List> getAdminList({int uid, String current, String pageSize}) async {
    final args = {
      'uid': uid ?? OAuthCtrl.obj.uid,
      'pageNum': current,
      'pageSize': pageSize,
    };
    return await _doPost($uri('getAdminList'), args);
  }

  //申请退出公会
  Future<List> applyExitTeam({String familyId, String userId}) async {
    final args = {
      'userId': userId ?? OAuthCtrl.obj.uid,
      'familyId': familyId,
    };
    return await _doPost($uri('applyExitTeam'), args);
  }

  //强制退出公会
  Future<List> forceExitTeam({String familyId, String userId}) async {
    final args = {
      'userId': userId ?? OAuthCtrl.obj.uid,
      'familyId': familyId,
    };
    return await _doPost($uri('forceExitTeam'), args);
  }

  //审核操作公会  操作公会
  Future<List> applyFamily(
      {String familyId, String userId, String status, String type}) async {
    final args = {
      'userId': userId, //被操作人ID
      'familyId': familyId,
      'status': status, //状态(1.同意,2.拒绝)
      'type': type, //状态(1.加入 2.退出)
    };
    return await _doPost($uri('applyFamily'), args);
  }

  //获取待审核列表
  Future<List> applyList(
      {String familyId, int pageNum, int pageSize, String type}) async {
    final args = {
      'familyId': familyId, //被操作人ID
      'pageNum': pageNum,
      'pageSize': pageSize, //状态(1.同意,2.拒绝)
      'type': type, //状态(1.加入 2.退出)
    };
    return await _doPost($uri('applyList'), args);
  }

  // 踢出公会
  Future<List> kickOutTeam({String familyId, List userIds}) async {
    final args = {
      'familyId': familyId,
      'userIds': userIds.join(','),
    };
    return await _doPost($uri('kickOutTeam'), args);
  }

  // 申请加入公会
  Future applyJoinFamilyTeam({String familyId, String userId}) async {
    final args = {
      'familyId': familyId,
      'userId': userId ?? OAuthCtrl.obj.uid,
    };
    return await _doPost($uri('applyJoinFamilyTeam'), args);
  }

  // 取消申请加入公会
  Future cancelApplyJoinFamilyTeam({String familyId, String userId}) async {
    final args = {
      'familyId': familyId,
      'userId': userId ?? OAuthCtrl.obj.uid,
    };
    return await _doPost($uri('cancelJoinTeam'), args);
  }

  // 取消退出公会
  Future cancelApplyOutFamilyTeam({String familyId, String userId}) async {
    final args = {
      'familyId': familyId,
      'userId': userId ?? OAuthCtrl.obj.uid,
    };
    return await _doPost($uri('cancelExitTeam'), args);
  }

  //定时获取积分接口
  Future<Map> getIntegral() async => await _doPost($uri('getIntegral'));

  // 移除公会管理员
  Future<Map> removeAdmin(
      {String familyId, String userId, List userIds}) async {
    final args = {
      'familyId': familyId,
      'userId': userId ?? OAuthCtrl.obj.uid,
      'userIds': userIds.join(','),
    };
    return await _doPost($uri('removeAdmin'), args);
  }

  // 设置公会管理员
  Future<Map> setupAdministrator(
      {String familyId, String userId, List userIds}) async {
    final args = {
      'familyId': familyId,
      'userId': userId ?? OAuthCtrl.obj.uid,
      'userIds': userIds.join(','),
    };
    return await _doPost($uri('setupAdministrator'), args);
  }

  // 获取用户积分
  Future<dynamic> getUserIntegral({String userId}) async {
    final args = {
      'uid': userId ?? OAuthCtrl.obj.uid,
    };
    return await _doPost($uri('getUserIntegral'), args);
  }

  // 解散公会
  Future<dynamic> delFamily({String userId}) async {
    final args = {
      'uid': userId ?? OAuthCtrl.obj.uid,
    };
    return await _doPost($uri('delFamily'), args);
  }

  // 根据FamilyId获取公会信息
  Future<Map> getFamilyInfo({int familyId}) async {
    final args = {
      'familyId': familyId,
    };
    return await _doPost($uri('getFamilyInfo'), args);
  }
}

class _Task extends Api {
  const _Task(ApiHost _host, String _basePath) : super._(_host, _basePath);

  // 查询珊瑚余额
  Future<Map> coinInfo() async {
    final args = {
      'uid': OAuthCtrl.obj.uid,
    };
    return await _doPost($uri('v1/getMcoinNum'), args);
  }

  //  任务中心列表,type:类型(1新手任务2每日任务3每周签到)
  Future<List> taskList({
    int type,
  }) async {
    final args = {
      'uid': OAuthCtrl.obj.uid,
      'type': type,
    };
    return await _doGet($uri('v1/getInfo'), args);
  }

  //  签到
  Future sign() async {
    final args = {
      'uid': OAuthCtrl.obj.uid,
    };
    return await _doGet($uri('v1/weeklyMission'), args);
  }

  //  查询是否签到
  Future checkSign() async {
    final args = {
      'uid': OAuthCtrl.obj.uid,
    };
    return await _doGet(_host.$new('mcoin/v1/isWeeklyMission'), args);
  }

  //  领取奖励
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

  //查询用户提现记录
  Future<List> queryUserTransfer(
    int pageNum,
    int pageSize,
  ) async {
    final args = {'pageNum': pageNum, 'pageSize': pageSize};
    return await _doGet(_host.$new('withDraw/queryUserTransfer'), args);
  }

  // 取消用户提现申请
  Future<dynamic> updateUserTransfer(int id) async {
    final args = {'id': id};
    return await _doGet(_host.$new('withDraw/updateUserTransfer'), args);
  }
}

class _Wx extends Api {
  const _Wx(ApiHost _host, String _basePath) : super._(_host, _basePath);

  //获取微信支付url
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

  ///打开
  Future receive(int id) async {
    final args = {'id': id};

    return await _doPost($uri('receivePacket'), args);
  }

  ///撤回
  Future withdraw(int id) async {
    final args = {'id': id};

    return await _doPost($uri('withdrawPacket'), args);
  }

  ///红包记录
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
