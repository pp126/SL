import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/ui/mine/young/young_pwd_page.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class YoungRecommendPage extends StatefulWidget {
  @override
  _YoungRecommendPageState createState() => _YoungRecommendPageState();
}

class _YoungRecommendPageState extends State<YoungRecommendPage> {
  bool isOpen = false;

  final _key = GlobalKey<XFutureBuilderState>();

  @override
  void initState() {
    super.initState();
  }

  Future <Map> getYoungData() {
    return Api.User.getUsersTeensMode();
  }

  doRefresh(){
    _key.currentState.doRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar('青少年模式'),
      body: XFutureBuilder<Map>(key: _key,futureBuilder: getYoungData, onData: (data) {
        isOpen = data['cipherCode'] != null;

        return Column(
          children: [
            SizedBox(height: 50),
            Image.asset(IMG.$(isOpen ? '保护开' : '保护关'),width: 48,height: 48,),
            Text('青少年模式${isOpen ? '开启' : '未开启'}', style: TextStyle(color: Color(0xff252142), fontSize: 20)),
            SizedBox(height: 20),
            Row(
              children: [
                SvgPicture.asset(SVG.$('mine/young/时间限制')),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    '在青少年模式中，每日晚22时至次日早上6时期间无法使用喵喵语音，需输入密码才能继续使用',
                    style: TextStyle(color: AppPalette.tips, fontSize: 12),
                  ),
                )
              ],
            ).toTagView(null, Colors.white,
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 36), padding: EdgeInsets.all(20), radius: 12),
            Row(
              children: [
                SvgPicture.asset(SVG.$('mine/young/保护花朵')),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    '青少年模式是喵喵语音为促进青少年健康成长做出的一次尝试，我们优先针对核心场景进行优化，也将致力于更多场景',
                    style: TextStyle(color: AppPalette.tips, fontSize: 12),
                  ),
                )
              ],
            ).toTagView(null, Colors.white,
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 36), padding: EdgeInsets.all(20), radius: 12),
            Spacer(),
            Text('了解《喵喵语音未成年人保护计划》', style: TextStyle(color: AppPalette.primary, fontSize: 12)),
            isOpen
                ? Text('关闭青少年模式', style: TextStyle(color: AppPalette.primary, fontSize: 12))
                .toBtn(40, AppPalette.txtWhite, margin: EdgeInsets.symmetric(vertical: 20, horizontal: 40), onTap: onOpenTap)
                : Text('开启青少年模式', style: TextStyle(color: Colors.white, fontSize: 12))
                .toBtn(40, AppPalette.primary, margin: EdgeInsets.symmetric(vertical: 20, horizontal: 40), onTap: onOpenTap),
            SizedBox(height: 20),
          ],
        );
      }),
    );
  }
  onOpenTap(){
    Get.to(YoungPwdPage(isOpen:isOpen)).then((value) => doRefresh());
  }
}
