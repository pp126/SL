import 'package:app/3rd/im/im_help.dart';
import 'package:app/3rd/im/im_model.dart';
import 'package:app/tools.dart';
import 'package:app/widgets.dart';

import 'im_ctrl.dart';

class ConvManagerCtrl extends GetxController with GetDisposableMixin {
  final dataRx = RxMap<String, NIMSession>();
  final convRx = RxList<BaseConv>();
  final badge = ValueNotifier<int>(0);

  @override
  void onInit() {
    super.onInit();

    _initEventListener();
  }

  @override
  void onReady() async {
    await Get.find<ImAuth>().isReady;

    doRefresh();
  }

  void _initEventListener() {
    bindWorker(
      interval<Map<String, NIMSession>>(
        dataRx,
        time: 618.milliseconds,
        (data) {
          final dataList = <BaseConv>[];
          final unReadList = <NIMSession>[];

          for (final item in data.values) {
            if (item.filter) {
              dataList.add(ImConv(item));
            } else if (item.isSystemContent() && KvBox.read(PrefKey.convRead(item.sessionId)) != true) {
              unReadList.add(item);
            } else {
              dataList.add(ImConv(item));
            }
          }

          if (unReadList.isNotEmpty) {
            final conv = BoxConv(unReadList);

            if (dataList.length > 1) {
              dataList.insert(0, conv);
            } else {
              dataList.add(conv);
            }
          }

          convRx
            ..assignAll(dataList)
            ..sortBy<Comparable<num>>((it) => -(it.conv.lastMessageTime ?? 0));

          badge.value = convRx.map((it) => it.unReadCount).sum;
        },
      ),
    );

    bindStream(
      IM.chat.onSessionUpdate.listen((data) => dataRx.addAll(data.toMap())),
    );

    bindStream(
      IM.chat.onSessionDelete.listen((data) => dataRx.remove(data?.sessionId)),
    );
  }

  Future doRefresh() async {
    xlog('刷新会话列表', type: LogType.IM);

    final result = await IM.chat.querySessionList();

    if (result.isSuccess) {
      xlog(() => '刷新会话列表[成功] -> ${result.toMap()}', type: LogType.IM);

      dataRx.assignAll(result.data.toMap());
    } else {
      xlog('刷新会话列表[失败] -> $result', type: LogType.IM);
    }
  }
}

extension on Iterable<NIMSession>? {
  Map<String, NIMSession> toMap() {
    return {
      for (final item in this ?? <NIMSession>[]) //
        item.sessionId: item,
    };
  }
}
