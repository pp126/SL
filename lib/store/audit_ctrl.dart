import 'dart:convert';

import 'package:app/net/api.dart';
import 'package:app/net/file_api.dart';
import 'package:app/tools.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:get/state_manager.dart';
import 'package:meta/meta.dart';

@protected
class AuditCtrl extends GetxService {
  // 默认不是在审核
  final _audit = false.obs;

  bool get isAudit => _audit.value;

  @override
  @mustCallSuper
  void onInit() async {
    super.onInit();

    Api.Home.iooooos().then((it) {
      if (it == 0) {
        _audit.value = true;
      }
    });

    final uri = Uri.https(
      FileApi.config.imgHost.first,
      'icon_${sha1.convert(utf8.encode(appInfo.version))}',
    );

    Dio().get('$uri').then((_) => _audit.value = true, onError: (e) {});
  }

  static AuditCtrl get obj => Get.find();
}
