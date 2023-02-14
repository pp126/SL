import 'package:app/common/theme.dart';
import 'package:app/tools.dart';
import 'package:app/tools/screen.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

enum TipsType {
  noNetwork,///无网络
  empty,///空数据:无商品，无礼物，无物
  none,///无活动，无人
  noSearch,///搜索无结果
  fail,///加载失败
}

class TipsView extends StatelessWidget {
  final TipsType tipsType;
  final Widget bottom;
  final String message;
  final double imageSize;
  final TextStyle style;
  final VoidCallback doRefresh;
  final bool noImage;///不展示提示图片

  TipsView(
      this.doRefresh,
      {
        this.bottom,
        this.message,
        this.imageSize,
        this.style,
        TipsType tipsType,
        this.noImage = false,
      }):tipsType = tipsType ?? TipsType.empty;

  final data = {
    TipsType.noNetwork: ['无网络', 233.0 / 2, 214.0 / 2, '网络链接失败，请稍后重试～'],
    TipsType.empty: ['无人', 304.0 / 2, 228.0 / 2, '很可惜，这里什么都没有～'],
    TipsType.none: ['无人', 305.0 / 2, 248.0 / 2, '暂时没有活动哦～'],
    TipsType.noSearch: ['搜索无结果', 256.0 / 2, 228.0 / 2, '很抱歉，没有搜索到您需要的内容'],
    TipsType.fail: ['加载失败', 282.0 / 2, 234.0 / 2, '加载失败了，刷新下看看吧～'],
  };

  @override
  Widget build(BuildContext context) {
    final item = data[tipsType];
    String image = item[0];
    String defaultMessage = item[3];
    double imageW = item[1];
    double imageH = item[2];
    bool isSmall = imageSize != null;
    if(isSmall){
      imageW = imageSize * imageW/imageH;
      imageH = imageSize;
    }
    TextStyle ts = TextStyle(fontSize: isSmall?12:14, color: AppPalette.tips);
    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Stack(
        children: [
          Container(
            color: isSmall?Colors.transparent:Colors.white,
            width: double.infinity,
            height: isSmall?((imageSize??0)+120.0):Screen.bodyHeight,
            child: Column(
              mainAxisSize: isSmall?MainAxisSize.min:MainAxisSize.max,
              mainAxisAlignment: noImage?MainAxisAlignment.center:MainAxisAlignment.start,
              children: <Widget>[
                if(!noImage)Container(
                  width: imageW,
                  height: imageH,
                  margin: isSmall?null:EdgeInsets.only(top: 60),
                  child: Image.asset(
                    IMG.$(image),
                    fit: BoxFit.fill,),
                ),
                Spacing.h16,
                Text(message??defaultMessage, style: style??ts),
                Spacing.h8,
                Text('刷新', style: TextStyle(fontSize: 12,color: Colors.white)).toTagView(32, AppPalette.primary,width: 85),
                Spacing.h8,
                if (bottom != null) ...{
                  Spacing.h32,
                  bottom,
                },
              ],
            ),
          ),
          Positioned.fill(
            child:
            Material(
              color: Colors.transparent,
              child: InkWell(onTap: doRefresh,),
            ),
          ),
        ],
      ),
    );
  }
}
