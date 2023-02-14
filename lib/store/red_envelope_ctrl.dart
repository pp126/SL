import 'package:app/tools.dart';
import 'package:flutter/material.dart';

class RedEnvelopeCtrl extends GetxService {
  final value = RxMap(<String, int>{});

  @override
  void onInit() {
    super.onInit();

    final data = Storage.read<Map>(PrefKey.RedEnvelope);

    if (!data.isNullOrBlank) {
      value.assignAll(data.cast());
    }

    ever(value, (it) => Storage.write(PrefKey.RedEnvelope, it));
  }

  static Widget use(int id, {@required Widget Function(String status) builder}) {
    return GetX<RedEnvelopeCtrl>(builder: (it) => builder(statusToName(it.value['$id'])));
  }

  static void updateStatus(int id, int status) => Get.find<RedEnvelopeCtrl>().value['$id'] = status;

  static String statusToName(int status) {
    switch (status) {
      case 1:
        return '待领取';
      case 2:
        return '已领取';
      case 3:
        return '红包已退回';
      case 4:
        return '红包已过期';
      case 5:
        return '红包被领取';
    }

    return '';
  }
}
