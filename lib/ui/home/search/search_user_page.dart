import 'package:app/common/bus_key.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/ui/home/search/search_record.dart';
import 'package:app/widgets/list/list_page.dart';
import 'package:flutter/cupertino.dart';

class SearchUserView extends StatefulWidget {
  final String text;

  SearchUserView(this.text);

  @override
  _SearchUserViewState createState() => _SearchUserViewState();
}

class _SearchUserViewState extends NetPageList<Map, SearchUserView> {
  String text;

  @override
  void initState() {
    super.initState();
    text = widget.text;
    Bus.sub(BUS_SEARCH_USER, (data) {
      text = data;
      doRefresh();
    });
  }

  @override
  Future fetchPage(PageNum page) => Api.Home.search(text, page, 1);

  @override
  Widget itemBuilder(BuildContext context, Map item, int index) => userItem(item);

  @override
  bool get wantKeepAlive => true;
}
