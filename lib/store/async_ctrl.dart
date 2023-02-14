import 'package:app/tools.dart';
import 'package:async/async.dart';
import 'package:get/state_manager.dart';
import 'package:meta/meta.dart';

@protected
abstract class AsyncCtrl<T> extends GetxController {
  T _value;

  AsyncCtrl([this._value]);

  AsyncMemoizer _cache;

  String get persistent => null;

  @override
  @mustCallSuper
  void onInit() {
    super.onInit();

    final key = persistent;
    if (key != null) {
      final cache = readCache(key);

      if (cache != null) value = cache;
    }

    doRefresh();
  }

  T readCache(String key) => Storage.read<T>(key);

  void doRefresh() async {
    if (isClosed) return;

    _cache ??= AsyncMemoizer()
      ..runOnce(() async {
        if (isClosed) return;

        try {
          final data = transform(await api);

          if (isClosed) return;

          final key = persistent;
          if (key != null) Storage.write(key, data);

          value = data;
        } catch (e) {
          errLog(e, name: 'ASYNC_CTRL');

          if (isClosed) return;

          Future.delayed(Duration(seconds: 5), doRefresh);
        } finally {
          _cache = null;
        }
      });

    await _cache.future;
  }

  T transform(data) => data;

  @protected
  Future get api;

  set value(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    update();
  }

  T get value {
    if (_value == null) doRefresh();

    return _value;
  }
}
