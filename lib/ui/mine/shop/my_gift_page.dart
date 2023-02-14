import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/home/widgets/tab_bar_persistent_header_delegate.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/mine/shop/my_package_item.dart';
import 'package:app/ui/mine/shop/product_item.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/future_builder.dart';
import 'package:app/widgets/spacing.dart';
import 'package:flutter/material.dart';

///礼物
class MyGiftPage extends StatefulWidget {
  final int uid;

  MyGiftPage({
    this.uid
  });

  @override
  MyGiftPageState createState() => new MyGiftPageState();
}

class MyGiftPageState extends State<MyGiftPage> {

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: _buildTopView(),
          ),
        ];
      },
      body: MyPackageItem(type:ProductType.giftExchange,),
    );
  }

  _buildTopView() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16,vertical: 20),
      child: Row(
        children: [
          Text('我的礼物',style: TextStyle(fontSize: 16,color: AppPalette.dark,fontWeight: fw$SemiBold),),
          Spacing.exp,
        ],
      ),
    );
  }
}