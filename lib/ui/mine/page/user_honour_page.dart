
import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/mine/page/detail/user_honour_detail_page.dart';
import 'package:app/ui/mine/page/detail/user_honour_list_page.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/future_builder.dart';
import 'package:flutter/material.dart';

///用户荣耀
class UserHonourPage extends StatefulWidget {
  final int uid;
  final Map userInfo;
  UserHonourPage({this.uid,this.userInfo});
  @override
  _UserHonourPageState createState() => _UserHonourPageState();
}

class _UserHonourPageState extends State<UserHonourPage> {
  @override
  void initState() {
    super.initState();
  }
  Future<Map> getGiftData(){
    return Api.User.userGiftList(userId: widget.uid.toString(),type: 1);
  }
  Future<Map> getHeadData(){
    return Api.User.userHeadList(userId: widget.uid.toString());
  }
  Future<Map> getCarData(){
    return Api.User.userCarList(userId: widget.uid.toString());
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          xFutureItem(
              getGiftData,
              '礼物墙',
              tips: '共收到%@勋章',
              emptyTips: '暂无收到的礼物～',
              onPress: (){
                Get.to(UserHonourDetailPage(
                  uid: widget.uid,
                  userInfo: widget.userInfo,
                  type: HonourType.gift,
                  title: '礼物墙',
                ));
              }
          ),
          xFutureItem(
              getCarData,
              '座驾',
              tips: '共获得%@件座驾',
              emptyTips: '暂无座驾～',
              onPress: (){
                Get.to(UserHonourDetailPage(
                  uid: widget.uid,
                  userInfo: widget.userInfo,
                  type: HonourType.car,
                  title: '座驾',
                ));
              }
          ),
          xFutureItem(
              getHeadData,
              '头饰',
              tips: '共获得%@件头饰',
              emptyTips: '暂无头饰～',
              onPress: (){
                Get.to(UserHonourDetailPage(
                  uid: widget.uid,
                  userInfo: widget.userInfo,
                  type: HonourType.head,
                  title: '头饰',
                ));
              }
          ),
        ],
      ),
    );
  }

  Widget xFutureItem(
      AsyncFutureBuilder<Map> futureBuilder,
      String title,
      {
        String tips = '',
        VoidCallback onPress,
        String emptyTips,
      }){
    return XFutureBuilder<Map>(futureBuilder: futureBuilder,tipsSize: 80, onData: (data) {
      tips = tips.replaceFirst('%@', '${xMapStr(data,'obtainedCount',defaultStr: 0)}/${xMapStr(data,'count',defaultStr: 0)}');
      return honorView(
          title,
          data['list'],
          tips: tips,
          emptyTips: emptyTips,
          onPress: onPress
      );
    },onEmpty: ({msg}){
      return honorView(
          title,
          null,
          tips: tips,
          emptyTips: emptyTips,
          onPress: onPress
      );
    },);
  }
  Widget honorView(String title,List data,{String tips = '',VoidCallback onPress,String emptyTips}) {
    bool isEmpty = data == null || data.length == 0;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$title',
                style: TextStyle(color: AppPalette.dark,fontWeight: FontWeight.w600, fontSize: 16),
              ),
              Text(
                tips,
                style: TextStyle(color: AppPalette.hint, fontSize: 10),
              ),
            ],
          ),
          Spacing.h8,
          Row(
            children: [
              Expanded(
                child: !isEmpty?SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...data.map((e){
                        return Container(
                          margin: EdgeInsets.only(right: 10),
                          child: AvatarView(url: xMapStr(e, 'picUrl'),size: 48,),
                        );
                      }).toList(),
                    ],
                  ),
                ):Center(child: Text(emptyTips??'暂无数据', style: TextStyle(color: AppPalette.c9))),
              ),
              RightArrowIcon(),
            ],
          ).toBtn(73, AppPalette.background,
              onTap: onPress,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ],
      ),
    );
  }
}