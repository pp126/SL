import 'package:app/net/api.dart';
import 'package:app/ui/home/widgets/home_card.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

class HomeIndexRecommendView extends StatefulWidget {
  @override
  _HomeIndexRecommendViewState createState() => _HomeIndexRecommendViewState();
}

class _HomeIndexRecommendViewState
    extends NetList<Map, HomeIndexRecommendView> {
  @override
  Future fetch() => Api.Home.recommendRoom(1);

  @override
  Widget itemBuilder(BuildContext context, Map item, int index) =>
      RoomCard(item);

  @override
  BaseConfig initListConfig() {
    return GridConfig(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
      gridDelegate: RoomCard.gridDelegate,
    );
  }
}
