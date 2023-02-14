import 'package:app/tools.dart';
import 'package:flutter/widgets.dart';
import 'package:get_storage/get_storage.dart';
import 'package:meta/meta.dart';

GetStorage _box;

@protected
storageInit() async {
  try {
    await GetStorage.init('App');

    _box = GetStorage('App');
  } catch (e) {
    xlog(e);
  }
}

class Storage {
  const Storage._();

  static write(String k, v) {
    xlog('WRITE => ${v.runtimeType} $k', name: 'STORAGE');

    return _box.write(k, v);
  }

  static T read<T>(String k) {
    xlog('READ => $T $k', name: 'STORAGE');

    final result = _box.read<T>(k);

    return result;
  }

  static remove(String k) => _box.remove(k);
}
