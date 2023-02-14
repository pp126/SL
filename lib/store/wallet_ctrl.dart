import 'package:app/net/api.dart';
import 'package:app/store/async_ctrl.dart';
import 'package:app/tools.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class WalletCtrl extends AsyncCtrl<RxMap> with BusDisposableMixin {
  final _rx = Rx<DateTime>(null);

  WalletCtrl() : super(RxMap({}));

  @override
  Future get api => Api.User.getWalletInfos();

  @override
  RxMap transform(data) => RxMap(data);

  @override
  void onInit() {
    super.onInit();

    bus(CMD.gold_change, (int amount) {
      final old = value['goldNum'] ?? 0;

      value['goldNum'] = old + amount;

      _rx.value = DateTime.now();
    });

    bus(CMD.diamond_change, (num amount) {
      final old = value['diamondNum'] ?? 0.0;

      value['diamondNum'] = old + amount;

      _rx.value = DateTime.now();
    });

    bus(CMD.conch_change, (Tuple2<int, int> data) {
      final key = data.item1 == 0 ? 'conchNum' : 'maxConchNum';
      final amount = data.item2;

      final old = value[key] ?? 0;

      value[key] = old + amount;

      _rx.value = DateTime.now();
    });

    interval(
      _rx,
      (_) => doRefresh(),
      time: Duration(seconds: 6),
    );
  }

  @override
  set value(RxMap data) => value.addAll(data);

  static Widget useGold({@required Widget Function(int) builder}) {
    return GetX<WalletCtrl>(
      autoRemove: false,
      builder: (it) => builder(it.value['goldNum'] ?? 0),
    );
  }

  static Widget useAllGold({@required Widget Function(Map data, int gold, double diamond) builder}) {
    return GetX<WalletCtrl>(builder: (it) {
      return builder(
        it.value,
        it.value['goldNum'] ?? 0,
        it.value['diamondNum'] ?? 0.0,
      );
    });
  }
}
