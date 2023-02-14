import 'dart:convert';

import 'package:app/net/host.dart';
import 'package:app/net/ws_event.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class MqCtrl extends GetxController {
  _StompClient _client;

  @override
  void onInit() {
    super.onInit();

    _client = _StompClient({'login': 'readonly', 'passcode': 'readonly'}, {});

    _client
      ..sub('room_draw_queue', (it) => Bus.fire(RoomDrawEvent(it)))
      ..sub('room_horn_queue', (it) => Bus.fire(RoomHornEvent(it)))
      ..sub('app.send_biggift_queue', (it) => Bus.fire(BigGiftEvent(it)))
      ..sub('app.public_chat_queue', (it) => Bus.fire(PublicChatEvent(it)))
      ..sub('app.send_flash_chat_queue',
          (it) => Bus.fire(CallPushEvent('直聊', it))) /**/;

    void subByGender(int gender) {
      switch (gender) {
        case 1:
          _client.sub(
            'app.send_flash_chat_boy_queue',
            (it) => Bus.fire(CallPushEvent('找男', it)),
          );
          break;
        case 2:
          _client.sub(
            'app.send_flash_chat_girl_queue',
            (it) => Bus.fire(CallPushEvent('找女', it)),
          );
          break;
        default:
          assert(false);
      }
    }

    final gender = OAuthCtrl.obj.gender.value;

    if (gender == -1) {
      once(OAuthCtrl.obj.gender, subByGender);
    } else {
      subByGender(gender);
    }
  }

  @override
  void onClose() {
    _client.stop();

    super.onClose();
  }

  sub(String topic, OnData<Map<String, dynamic>> onData) =>
      _client.sub(topic, onData);

  unsub(String topic) => _client.unsub(topic);

  static MqCtrl get obj => Get.find();
}

class _StompClient {
  final Map<String, _SubInfo> subMap;
  final StompClient _client;

  _StompClient(Map<String, String> auth, this.subMap)
      : _client = _init(auth, subMap)..activate();

  sub(String topic, OnData<Map<String, dynamic>> onData) {
    Function unsub;

    if (_client.connected) {
      unsub = _client.subscribe(
        destination: _topic(topic),
        callback: _onData(onData),
      );

      xlog('开始订阅【$topic】', name: 'STOMP');
    }

    subMap[topic] = _SubInfo(onData, unsub);
  }

  unsub(String topic) {
    xlog('取消订阅【$topic】', name: 'STOMP');

    try {
      final f = subMap.remove(topic);

      f?.unsub?.call();
    } catch (e) {
      errLog(e, name: 'STOMP');
    }
  }

  stop() => _client.deactivate();

  static StompClient _init(
      Map<String, String> auth, Map<String, _SubInfo> subMap) {
    xlog('初始化 -> $auth', name: 'STOMP');

    final _delay = Duration(seconds: 2);
    final _timeout = Duration(seconds: 15);
    StompClient client;
    client = StompClient(
      config: StompConfig(
        url:
            '${Uri(scheme: 'ws', host: host.host, port: host.port, path: 'stomp')}',
        stompConnectHeaders: auth,
        reconnectDelay: _delay,
        connectionTimeout: _timeout,
        onWebSocketDone: () => xlog('WS已断开', name: 'STOMP'),
        onWebSocketError: (e) => errLog(e, name: 'STOMP'),
        onConnect: (frame) {
          xlog('连接成功', name: 'STOMP');
          subMap.forEach((k, v) {
            xlog('恢复订阅【$k】', name: 'STOMP');

            try {
              v.unsub?.call();
            } catch (e) {
              errLog(e, name: 'STOMP');
            }

            try {
              v.unsub = client.subscribe(
                destination: _topic(k),
                callback: _onData(v.onData),
              );
            } catch (e) {
              errLog(e, name: 'STOMP');
            }
          });
        },
      ),
    );
    return client;
  }

  static String _topic(String topic) => '/topic/$topic';

  static Function(StompFrame) _onData(OnData<Map<String, dynamic>> onData) {
    return (StompFrame frame) {
      final body = frame.body;

      if (isDebug) {
        String topic = frame.headers['destination'];

        topic = topic.substring(topic.lastIndexOf('/') + 1);

        xlog('$topic -> $body', name: 'STOMP');
      }

      onData(jsonDecode(body));
    };
  }
}

class _SubInfo {
  final OnData<Map<String, dynamic>> onData;

  _SubInfo(this.onData, this.unsub);

  Function unsub;
}
