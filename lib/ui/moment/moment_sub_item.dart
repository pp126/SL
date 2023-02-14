import 'package:app/event/moment_event.dart';
import 'package:app/net/api.dart';
import 'package:app/tools/bus.dart';
import 'package:app/ui/moment/moment_item_view.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/list/list_page.dart';
import 'package:flutter/material.dart';

class MomentSubItem extends StatefulWidget {
  final int type;

  MomentSubItem({this.type = 0});

  @override
  _MomentSubItemState createState() => _MomentSubItemState();
}

class _MomentSubItemState extends NetPageList<Map, MomentSubItem> with BusStateMixin {
  @override
  void initState() {
    super.initState();

    on<MomentEvent>((data) => doRefresh());
    on<MomentCommentEvent>((data) => doRefresh());
  }

  @override
  Future fetchPage(PageNum page) => Api.Moment.momentList(type: widget.type, page: page);

  @override
  BaseConfig initListConfig() => ListConfig(divider: Spacing.h8);

  @override
  Widget itemBuilder(BuildContext context, Map item, int index) {
    return MomentItemView(data: item);
  }
}
