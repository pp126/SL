import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/store/room_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

mixin _GridViewMixin {
  final int crossAxisCount = 1;
  final double childAspectRatio = 1;

  Future getData() => Api.Room.bgList();

  Widget $GridView() {
    return XFutureBuilder(
      futureBuilder: getData,
      onData: (data) {
        return GridView.count(
          padding: EdgeInsets.all(8),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: childAspectRatio,
          children: [for (final it in data) _ItemView(it, onItemClick)],
        );
      },
    );
  }

  void onItemClick(Map item);
}

class RoomBGPage extends StatelessWidget with _GridViewMixin {
  @override
  double get childAspectRatio => 9 / 16;

  @override
  int get crossAxisCount => 2;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeDark,
      child: Scaffold(
        appBar: xAppBar('房间背景'),
        body: $GridView(),
      ),
    );
  }

  void onItemClick(Map item) => Get.back(result: item);
}

class RoomBGDrawer extends StatelessWidget with _GridViewMixin {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(8),
          child: Text(
            '选择背景',
            style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: fw$SemiBold),
          ),
        ),
        Expanded(child: $GridView()),
      ],
    );
  }

  void onItemClick(Map item) {
    Get.back();

    final ctrl = RoomCtrl.obj;

    final api = Api.Room.updateRoom(ctrl.roomID, bg: item['picUrl']);

    simpleSub(api, msg: null, callback: () async {
      ctrl.value.addAll(await api);
    });
  }
}

class _ItemView extends StatelessWidget {
  final Map data;
  final ValueChanged<Map> onItemClick;

  _ItemView(this.data, this.onItemClick);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: GridTile(
        child: NetImage(data['picUrl'], fit: BoxFit.fitWidth, alignment: Alignment.center),
        footer: GridTileBar(title: Text(data['name']), backgroundColor: Colors.black12),
      ),
      onTap: () => onItemClick(data),
    );
  }
}
