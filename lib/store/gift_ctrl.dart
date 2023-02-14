import 'package:app/net/api.dart';
import 'package:app/store/async_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/widgets.dart';

class GiftCtrl extends AsyncCtrl<Map> {
  GiftCtrl() : super({});

  @override
  Future get api => Api.Gift.list();

  @override
  Map transform(data) => Map.fromIterable(data, key: (it) => '${it['giftId']}');

  @override
  String get persistent => PrefKey.GiftData;
}

class PackageGiftCtrl extends AsyncCtrl<List> with BusDisposableMixin {
  final hPrice = RxInt(0);
  final _rx = Rx<DateTime>(null);

  PackageGiftCtrl() : super([]);

  @override
  Future get api => Api.Gift.packageGiftList(page: PageNum(size: 999));

  @override
  List transform(data) {
    hPrice.value = data['hPrice'];

    return data['list'];
  }

  @override
  void onInit() {
    super.onInit();

    bus(CMD.package_gift_change, (data) {
      _rx.value = DateTime.now();

      //TODO 珊瑚礼物会错
      hPrice.value -= data['giftNum'] * data['goldPrice'];

      final item = value.firstWhere((it) => it['giftId'] == data['giftId'], orElse: null);

      if (item == null) {
        assert(false, '未知错误');
      } else {
        final num = data['userGiftPurseNum'];

        if (num <= 0) {
          value.remove(item);
        } else {
          item['userGiftPurseNum'] = num;
        }

        update();
      }
    });

    interval(
      _rx,
      (_) => doRefresh(),
      time: Duration(seconds: 6),
    );
  }
}
