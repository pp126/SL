import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/widgets/customer/app_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';

mixin ReportMixin {
  _report<K, V>(Map<K, V> items, Future Function(MapEntry<K, V> item) createApi) {
    return showCupertinoModalPopup(
      context: Get.context,
      builder: (BuildContext context) {
        return CommonBottomSheet(
          title: '违规举报',
          message: '我们会尽快处理',
          list: items.keys.toList(growable: false),
          onItemClickListener: (index, key) async {
            simpleSub(
              createApi(MapEntry(key as K, items[key])),
              callback: Get.back,
              msg: '举报成功',
            );
          },
        );
      },
    );
  }

  reportUser(int uid,bool isRoom) {
    final data = {"举报头像": "1", "举报昵称": "2", "举报相册": "3", "政治敏感": "4", "色情低俗": "5", "广告骚扰": "6", "人身攻击": "7"};

    return _report(
      data,
      (item) => Api.Moment.reportUser(reportUid: uid, reportType: item.value,isRoom: isRoom),
    );
  }

  reportDynamic(Map dynamic) {
    final data = {"色情": "1", "暴恐": "2", "涉政": "3", "广告": "4", "违禁": "5", "谩骂": "6"};

    return _report(
      data,
      (item) => Api.Moment.report(
        dynamicId: dynamic['userDynamic']['dynamicMsgId'],
        reportUid: dynamic['userDynamic']['uid'],
        reportReasonCode: item.value,
        reportReason: item.key,
      ),
    );
  }
}
