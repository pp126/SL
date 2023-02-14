import 'package:app/net/api.dart';
import 'package:app/ui/home/widgets/home_card.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

class HomeIndexRoomView extends StatefulWidget {
  final Map data;

  HomeIndexRoomView(this.data);

  @override
  _HomeIndexRoomViewState createState() => _HomeIndexRoomViewState();
}

class _HomeIndexRoomViewState extends NetPageList<Map, HomeIndexRoomView> {
  @override
  Future fetchPage(PageNum page) => Api.Home.tagIndex(widget.data['id'], page);

  @override
  Widget itemBuilder(BuildContext context, Map item, int index) => RoomCard(item);

  @override
  BaseConfig initListConfig() {
    return GridConfig(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
      gridDelegate: RoomCard.gridDelegate,
    );
  }
}
