import 'dart:async';
import 'dart:math' as math;

import 'package:android_intent/android_intent.dart';
import 'package:app/exception.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

void goHome() async {
  final intent = AndroidIntent(
    action: 'android.intent.action.MAIN',
    category: 'android.intent.category.HOME',
  );

  await intent.launch();
}

showProgress(f) async {
  final ctrl = WaitingCtrl.obj;

  try {
    ctrl.show();

    if (f is Future) {
      return await f;
    } else if (f is Function) {
      final data = f.call();

      if (data is Future) {
        return await data;
      } else {
        return data;
      }
    }
  } finally {
    ctrl.hidden();
  }
}

Future<T> holderProgress<T>(Future<T> f) async {
  final ctrl = WaitingCtrl.obj;

  if (ctrl.isShow) {
    try {
      ctrl.hidden();

      return await f;
    } finally {
      ctrl.show();
    }
  } else {
    return await f;
  }
}

simpleSub(f,
    {VoidCallback callback,
    String msg = '操作成功',
    bool isShowProgress = true,
    Map<int, ValueChanged<LogicException>> whenErr}) async {
  await simpleTry(
    () async {
      if (isShowProgress) {
        await showProgress(f);
      }

      if (msg != null) showToast(msg);

      callback?.call();
    },
    whenErr: whenErr,
  );
}

simpleTry(Future Function() body,
    {Map<int, ValueChanged<LogicException>> whenErr}) async {
  try {
    await body();
  } on LogicException catch (e) {
    if (whenErr == null) {
      showToast('$e');
    } else {
      final call = whenErr[e.code];

      if (call == null) {
        showToast('$e');
      } else {
        call(e);
      }
    }
  } on NetException catch (e) {
    showToast('$e');
  } catch (e, s) {
    errLog(e, s: s, name: 'SimpleTry');

    showToast('网络错误');
  }
}

bool isEmpty(v) => v == null || v.isEmpty;

bool isNotEmpty(v) => !isEmpty(v);

extension XNum<T extends num> on T {
  T limit(T min, T max) => math.min(math.max(this, min), max);
}

extension XIterable<E> on Iterable<E> {
  List<E> separator(E separator) {
    Iterator<E> iterator = this.iterator;

    if (!iterator.moveNext()) return const [];

    final buffer = <E>[];

    buffer.add(iterator.current);

    while (iterator.moveNext()) {
      buffer.add(separator);
      buffer.add(iterator.current);
    }

    return buffer.toList(growable: false);
  }

  Map<K, List<E>> groupBy<K>(K key(E it)) {
    final out = <K, List<E>>{};

    forEach((it) => out.putIfAbsent(key(it), () => <E>[]).add(it));

    return out;
  }
}

final _picker = ImagePicker();

void imagePicker(ValueChanged<PickedFile> okCall,
    {double max = 1080, ImageSource source = ImageSource.gallery}) {
  Permission.photos.request().isGranted.then((b) {
    if (b) {
      _picker
          .getImage(
              source: source, imageQuality: 90, maxWidth: max, maxHeight: max)
          .then((file) {
        if (file != null) okCall(file);
      });
    } else {
      showToast('权限获取失败');
    }
  });
}

checkVersion(BuildContext ctx, {bool alert = true}) async {
  try {
    var future = Api.User.versionInfo();

    final data = await future;

    String updateVersion = xMapStr(data, 'updateVersion');
    if (updateVersion.isNotEmpty && updateVersion != appInfo.version) {
      final ignore = data['status'] != 3;

      final actions = <Widget>[
        if (ignore)
          FloatingActionButton(
              onPressed: () {
                Get.back();
              },
              child: Text('取消')),
        FloatingActionButton(
          onPressed: () async {
            if (ignore) Get.back();
            String url = xMapStr(data, 'downloadUrl');
            bool can = await canLaunch(url);
            if (can) {
              await launch(url);
            }
          },
          child: Text('更新'),
        ),
      ];

      showDialog(
        context: ctx,
        barrierDismissible: !ignore,
        builder: (_) => AlertDialog(
          title: Text('检测到新版本$updateVersion'),
          content: Text(data['updateVersionDesc']),
          actions: actions,
        ),
      );
    } else if (alert) {
      showToast('当前是最新版本');
    }
  } catch (e, s) {
    errLog(e, s: s, name: 'check_update');

    if (alert) showToast(e);
  }
}

extension XTextEditingController on TextEditingController {
  join(String txt) {
    final _selection = selection;

    final oldOffset = _selection.start;

    if (oldOffset == -1) {
      text += txt;
      return;
    }

    final newOffset = oldOffset + txt.length;

    value = value.copyWith(
      text: text.replaceRange(_selection.start, _selection.end, txt),
      selection:
          _selection.copyWith(baseOffset: newOffset, extentOffset: newOffset),
      composing: TextRange.empty,
    );
  }

  backspace() {
    final _text = text.characters.skipLast(1).string;

    value = value.copyWith(
      text: _text,
      selection: TextSelection.collapsed(offset: _text.length),
      composing: TextRange.empty,
    );
  }
}

Future<void> autoTips(String key, FutureOr call) async {
  if (showTips(key)) await Future(call);
}

bool showTips(String key) {
  final b = Storage.read(key) ?? true;

  if (b) Storage.write(key, false);

  return b;
}
