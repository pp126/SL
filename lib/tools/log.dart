import 'dart:developer' show log;

import 'package:app/tools.dart';

typedef String CreateLog();

// const _block = <String>{};
const _block = {'WS', 'STOMP', 'BUS', 'HTTP', 'STORAGE','IMG'};

// bool canLog(String name) => isDebug && !_block.contains(name);
bool canLog(String name) => true;

void xlog(message, {String name = ''}) {
  if (canLog(name)) {
    log('', name: name);
    log('>'.padLeft(20, '-'), name: name);

    if (message is CreateLog) {
      log(message(), name: name);
    } else {
      log('$message', name: name);
    }

    log('<'.padRight(20, '-'), name: name);
  }
}

void errLog(e, {StackTrace s, String name = ''}) {
  if (canLog(name)) {
    log('', name: name);
    log('>'.padLeft(20, '='), name: name);
    log('e->', name: name);
    log('', error: e, name: name);

    if (s != null) {
      log('s->', name: name);
      log('', stackTrace: s, name: name);
    }

    log('<'.padRight(20, '='), name: name);
  }
}
