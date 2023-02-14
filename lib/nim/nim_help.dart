import 'dart:async';
import 'dart:convert';

import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_nim/flutter_nim.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nim_core/nim_core.dart';

class NimHelp {
  NimHelp._();

  static final chatNotifier = ValueNotifier([]);
  static final messagesNotifier = ValueNotifier(<NIMMessage>[]);
  static final unreadCount = ValueNotifier(0);

  static final _nim = FlutterNIM();

  static void init() {
    // Android的key需要到Android项目配置
    _nim.init(appKey: 'ce835d7553742255135982f952165c66');

    _nim.messagesResponse.listen((data) => messagesNotifier.value = data);

    final _rx = RxList<NIMRecentSession>();
    interval(
      _rx,
      (it) async {
        List<NIMMessageData> dataList = []; //主表
        NIMMessageData storageBoxData = NIMMessageData(unReadList: <NIMMessageData>[]);
        bool isMan = OAuthCtrl.obj.gender.value == 1;
        for (var item in it) {
          NIMMessageData data = (NIMMessageData(recentSession: item));

          String customerContent = data?.recentSession?.lastMessage?.customMessageContent;
          bool isSystemContent = data.isSystemContent(customerContent);

          if (!isMan) {
            if (data.filter) {
              dataList.add(data);
            } else if (isSystemContent) {
              storageBoxData.unReadList.add(data);
            } else {
              dataList.add(data);
            }
          } else {
            if (!isSystemContent) {
              dataList.add(data);
            }
          }
        }
        if (storageBoxData.unReadList.isNotEmpty) {
          if (dataList.length > 1) {
            dataList.insert(0, storageBoxData);
          } else {
            dataList.add(storageBoxData);
          }
        }
        chatNotifier.value = dataList;
      },
      condition: 618.milliseconds,
    );

    _nim.recentSessionsResponse.listen((data) {
      var count = 0;

      data.forEach((it) => count += it.unreadCount);

      unreadCount.value = count;

      // 需要改变对象才能触发刷新
      // ignore: deprecated_member_use, invalid_use_of_protected_member
      _rx.value = data;
    });
  }

  static Future<bool> login(int uid, String imToken) async {
    assert(uid != null);
    assert(imToken != null);

    xlog('申请登录【$uid】', name: 'NIM');
    xlog('申请登录【$imToken】', name: 'NIM');
    bool isOK = false;
    try{
      isOK = await _nim.login('$uid', imToken);
    }catch(e){
      print('======> $e');
    }

    xlog('登录结果【$isOK】', name: 'NIM');

    if (isOK) refreshChatList();

    return isOK;
  }

  static void logout() {
    xlog('申请登出', name: 'NIM');

    _nim.logout();
  }

  static void refreshChatList() {
    _nim.loadRecentSessions();

    xlog('刷新会话列表', name: 'NIM');
  }

  static Future<bool> startChat(String session) async {
    final result = await _nim.startChat(session);

    xlog('会话【$session】创建结果 【$result】', name: 'NIM');

    return result;
  }

  static void closeChat() {
    xlog('申请结束会话', name: 'NIM');

    _nim.exitChat();
  }

  static void loadMessage(int index) => _nim.loadMessages(index);

  static void sendText(String txt) {
    _nim.sendText(txt);
  }

  static void sendImage(PickedFile file) => _nim.sendImage(file.path);

  static void startRecording() {
    _nim.onStartRecording();

    xlog('开始录音', name: 'NIM');
  }

  static void stopRecording() {
    _nim.onStopRecording();

    xlog('结束录音', name: 'NIM');
  }

  static void cancelRecording() {
    _nim.onCancelRecording();

    xlog('取消录音', name: 'NIM');
  }

  static void markAllMessageRead() {
    _nim.markAllMessageRead();
  }
}

class NIMMessageData {
  NIMMessageData({this.recentSession, this.unReadList});

  NIMRecentSession recentSession;

  bool get filter => int.parse(recentSession.sessionId) == 346 || int.parse(recentSession.sessionId) == 36;

  get isRead async => await Storage.read(recentSession.sessionId);

  bool get isStorageBox => unReadList?.isNotEmpty ?? false;

  final List unReadList;

  int unReadCount() {
    return unReadList.length;
  }

  bool isSystemContent(String customContent) {
    if (null == customContent) {
      return false;
    }
    Map customerJson = json.decode(customContent);

    if (customerJson['first'] == 10 && customerJson['second'] == 101) {
      return true;
    } else {
      return false;
    }
  }
}
