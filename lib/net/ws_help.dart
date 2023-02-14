import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app/common/app_crypto.dart';
import 'package:app/exception.dart';
import 'package:app/net/api_help.dart';
import 'package:app/net/host.dart';
import 'package:app/net/ws_event.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/store/room_ctrl.dart';
import 'package:app/tools.dart';
import 'package:async/async.dart';
import 'package:meta/meta.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

typedef void CallBack(Map data);

class WsHelp {
  WsHelp._();

  static var _seq = 0;
  static WebSocketChannel _ws;
  static Timer _timer;
  static Future _cache;

  static final _func = <int, CallBack>{};
  static const _timeout = Duration(seconds: 15);

  static Future<void> init() async {
    _cache ??= AsyncMemoizer().runOnce(_init);

    await _cache.timeout(_timeout);
  }

  static Future<void> _init() async {
    try {
      final url = Uri(scheme: 'ws', host: host.host, port: host.port, path: 'ws');

      xlog('地址 $url', name: 'WS');

      _ws = IOWebSocketChannel(await WebSocket.connect('$url').timeout(_timeout)) //
        ..stream.listen(_onData, onDone: _onDone);

      await WsApi.login();
    } catch (e) {
      _ws?.sink?.close();
      _cache = null;

      errLog(e, name: 'WS');

      rethrow;
    }

    _startHeartbeat();
  }

  static void _startHeartbeat() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_ws == null) {
        timer.cancel();

        return;
      }

      send('heartbeat');
    });
  }

  static void _onData(msg) {
    try {
      final data = WsCrypto.msgDecode(msg);
      switch (data['route']) {
        case 'heartbeat':
          break;
        case 'kickoff':
          showToast(data['req_data']['errmsg']);

          Bus.send(CMD.no_auth, 'IM -> ${data['req_data']['errmsg']}');
          break;
        default:
          final event = WsEvent.fromMsg(data);

          if (event is HideEvent) {
            xlog(event, name: 'WS');
          } else if (event != null) {
            Bus.fire(event);
          } else {
            if (!_doResult(data)) xlog('未处理消息 => $data', name: 'WS');
          }
      }
    } catch (e, s) {
      xlog('收到异常消息 => $msg', name: 'WS');

      errLog(e, s: s, name: 'WS');
    }
  }

  // 需要处理返回值的消息
  static bool _doResult(data) {
    var mark = false;

    final resData = data['res_data'];
    if (resData != null) {
      final func = _func.remove(data['id']);
      if (func != null) {
        mark = true;

        try {
          func(resData);
        } catch (e, s) {
          errLog(e, s: s, name: 'WS');
        }
      }
    }

    return mark;
  }

  static void _onDone() {
    if (_ws == null) return;

    xlog('已结束，原因【${_ws.closeCode}#${_ws.closeReason}】', name: 'WS');

    _doClearUp();

    if (OAuthCtrl.obj.isLogin) {
      var i = 1;
      final watch = Stopwatch()..start();

      Future.doWhile(() async {
        try {
          await init();

          watch.stop();

          xlog('第【$i】次重连成功，耗时【${watch.elapsedMilliseconds / 1000}秒】', name: 'WS');

          return false;
        } catch (e) {
          xlog('第【$i】次重连失败', name: 'WS');
        }

        i++;

        return await Future.delayed(Duration(seconds: 3), () => true);
      });
    }
  }

  static void _doClearUp() {
    _ws.sink.close(status.normalClosure);
    _func.clear();

    _ws = null;
    _cache = null;
  }

  static void close() {
    xlog('主动断开连接', name: 'WS');

    if (_ws == null) return;

    _doClearUp();
  }

  static int send(String cmd, {Map<String, dynamic> data, CallBack callback}) {
    if (_ws == null) throw NetException('房间数据链接已断开');

    final id = _seq++;

    final _data = {'id': id, 'route': cmd};
    if (data != null) _data['req_data'] = data;

    _ws.sink.add(WsCrypto.msgEncode(_data));

    _func[id] = callback;

    if (cmd != 'heartbeat') xlog('发送消息 => $_data', name: 'WS');

    return id;
  }

  static Future<Map> request(String cmd, {Map<String, dynamic> data, Duration timeout = _timeout}) {
    final _completer = Completer<Map>();

    send(cmd, data: data, callback: (it) {
      final code = it['errno'];

      switch (code) {
        case 0:
          _completer.complete(it['data']);
          break;
        case 100100:
          Bus.send(CMD.no_auth, 'IM -> 100100');
          continue err;
        err:
        default:
          _completer.completeError(LogicException(code, it['errmsg']));
      }
    });

    // TODO 回收永远不会回消息的函数

    return _completer.future.timeout(timeout);
  }
}

class WsApi {
  WsApi._();

  static int _room;
  static Map _member;

  static Future login() async {
    final data = {
      "page_name": 1,
      "uid": OAuthCtrl.obj.uid,
      "ticket": OAuthCtrl.obj.ticket,
      "appCode": ApiHelp.buildNum(),
      "appVersion": ApiHelp.version(),
    };

    final result = await WsHelp.request('login', data: data);

    xlog('登录成功  => $result', name: 'WSO');

    if (_room != null) {
      xlog('重连进入房间【$_room】', name: 'WS');

      final result = await joinRoom(_room);

      Bus.send(CMD.refreshMic, result['queue_list']);
    }
  }

  static Future<Map> joinRoom(int roomID) async {
    final data = {'room_id': roomID};

    final result = await WsHelp.request('enterChatRoom', data: data);

    _room = result['room_info']['roomId'];
    _member = result['member'];

    return result;
  }

  static Future<Map> leaveRoom() {
    final data = {'room_id': _room};

    _room = null;
    _member = null;

    return WsHelp.request('exitChatRoom', data: data);
  }

  /// 上麦
  static Future<Map> joinMic(int position, int uid) {
    final data = {
      'room_id': _room,
      'key': position,
      'uid': uid,
    };

    return WsHelp.request('updateQueue', data: data);
  }

  /// 下麦
  static Future<Map> leaveMic(int position) {
    final data = {
      'room_id': _room,
      'key': position,
    };

    return WsHelp.request('pollQueue', data: data);
  }

  /// 抱Ta下麦
  static Future<void> micDown(int micUid, int position) async {
    //实际下麦
    await WsApi.leaveMic(position);

    //发送下麦消息
    return _apiWithMsg(
      first: FirstCMD.RoomSet,
      second: 82,
      data: {'uid': '$micUid', 'micPosition': 0},
    );
  }

  /// 抱Ta上麦
  static Future<void> micUp(int micUid, int position) async {
    await WsApi.joinMic(position, micUid);

    return _apiWithMsg(
      first: FirstCMD.RoomSet,
      second: 81,
      data: {'uid': '$micUid', 'micPosition': position},
    );
  }

  /// 发送提醒消息
  static Future<void> tips(String msg) async {
    return _apiWithMsg(
      first: FirstCMD.Tips,
      second: 1,
      data: {'msg': msg},
    );
  }

  /// 开关房间聊天
  static Future<void> settingChat(bool isEnable) async {
    return _apiWithMsg(
      first: FirstCMD.RoomSet,
      second: RoomSettingCmd.findCode(isEnable ? RoomSettingCmd.openChat : RoomSettingCmd.closeChat),
    );
  }

  /// 开关房间礼物
  static Future<void> settingGift(bool isEnable) async {
    return _apiWithMsg(
      first: FirstCMD.RoomSet,
      second: RoomSettingCmd.findCode(isEnable ? RoomSettingCmd.openGift : RoomSettingCmd.closeGift),
    );
  }

  /// 送礼物给个人
  static void sendGift(Map data) {
    _member['wealth_level'] = data['wealthLevel'];

    _apiWithMsg(first: FirstCMD.OneGift, second: 31, data: data);
  }

  /// 送礼物给多人
  static void sendWholeMicro(Map data) {
    _member['wealth_level'] = data['wealthLevel'];

    _apiWithMsg(first: FirstCMD.MultipleGift, second: 121, data: data);
  }

  /// 清除公屏
  static void clearMsg() => _apiWithMsg(first: FirstCMD.ClearMsg, second: 1, data: {'member': _member});

  static void _apiWithMsg({@required int first, @required int second, Map data}) {
    sendMsg(
      jsonEncode(
        {
          "first": first,
          "second": second,
          "data": data,
        },
      ),
    );
  }

  static void sendTxtMsg(String content) {
    final data = {
      'room_id': _room,
      'member': _member,
      'content': content,
    };

    WsHelp.send('sendText', data: data);
  }

  static void sendStickersMsg(String name) {
    _sendStickersMsg(1, name);
  }

  static void sendStickersGameMsg(Map info) {
    _sendStickersMsg(2, info);
  }

  static void _sendStickersMsg(int second, info) {
    final data = {
      'uid': _member['account'],
      'sticker': info,
      'member': _member,
    };

    sendRichMsg(second, data);
  }

  static void sendRichMsg(int second, Map data) {
    _apiWithMsg(first: FirstCMD.RichMsg, second: second, data: data);
  }

  static void sendMsg(content) {
    final data = {
      'room_id': '$_room',
      'custom': content,
    };

    WsHelp.send('sendMessage', data: data, callback: print);
  }
}
