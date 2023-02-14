import 'package:app/common/bus_key.dart';
import 'package:app/net/api.dart';
import 'package:app/tools/bus.dart';
import 'package:app/ui/home/search/search_record.dart';
import 'package:app/ui/mine/society/ui/society_uis.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/list/list_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:tuple/tuple.dart';

class SearchSocietyItem extends StatefulWidget {
  final String text;

  SearchSocietyItem(this.text);

  @override
  _SearchSocietyItemState createState() => _SearchSocietyItemState();
}

class _SearchSocietyItemState extends NetPageList<Map, SearchSocietyItem> {
  String text;

  @override
  void initState() {
    super.initState();
    text = widget.text;
    Bus.sub(BUS_SEARCH_Society, (data) {
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
  BaseConfig initListConfig() {
    return ListConfig(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
    );
  }

  @override
  List<Map> transform(data) {
    return super.transform(data['familyList']);
  }

  @override
  Future fetchPage(PageNum page) => Api.Family.familyList(page: page,searchTest: text);

  @override
  Widget itemBuilder(BuildContext context, Map item, int index){
    return SocietySubItem(
      data:item,
      index:index,
      showOrder: false,
    );
  }
}
