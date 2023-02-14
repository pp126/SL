import 'package:app/net/api.dart';
import 'package:app/ui/home/widgets/home_card.dart';
import 'package:app/widgets/list/list_page.dart';
import 'package:flutter/material.dart';

class HomeIndexHotView extends StatefulWidget {
  @override
  _HomeIndexHotViewState createState() => _HomeIndexHotViewState();
}

class _HomeIndexHotViewState extends NetList<Map, HomeIndexHotView> {
  @override
  Future fetch() => Api.Home.recommendRoom(2);

  @override
  Widget itemBuilder(BuildContext context, Map item, int index) => RoomCard(item);

  @override
  BaseConfig initListConfig() {
    return GridConfig(
      padding: EdgeInsets.only(left: 16, right: 16,top: 16, bottom: 16),
      gridDelegate: RoomCard.gridDelegate,
    );
  }
}
