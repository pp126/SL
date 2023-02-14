import 'package:app/common/bus_key.dart';
import 'package:app/net/api.dart';
import 'package:app/tools/bus.dart';
import 'package:app/ui/home/search/search_record.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/list/list_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:tuple/tuple.dart';

class SearchRoomView extends StatefulWidget {
  final String text;

  SearchRoomView(this.text);

  @override
  _SearchRoomViewState createState() => _SearchRoomViewState();
}

class _SearchRoomViewState extends NetPageList<Map, SearchRoomView> {
  String text;

  @override
  void initState() {
    super.initState();
    text = widget.text;
    Bus.sub(BUS_SEARCH_ROOM, (data) {
      text = data;
      doRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConfigListState(
      buildEmptyView: ([Tuple2<VoidCallback, bool> arg]) => TipsView(arg.item1, tipsType: TipsType.noSearch),
      child: super.build(context),
    );
  }

  @override
  Future fetchPage(PageNum page) => Api.Home.search(text, page, 2);

  @override
  Widget itemBuilder(BuildContext context, Map item, int index) => roomItem(item);

  @override
  bool get wantKeepAlive => true;
}
