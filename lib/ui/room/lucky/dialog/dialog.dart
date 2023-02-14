import 'package:app/net/api.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

class RuleDialog extends StatefulWidget {
  int drawType;

  RuleDialog(int drawType) {
    this.drawType = drawType;
  }

  @override
  State<StatefulWidget> createState() {
    return new RuleDialogState();
  }
}

class RuleDialogState extends State<RuleDialog> {
  Map data = Map();

  @override
  void initState() {
    super.initState();
    getInvestReturn(widget.drawType+1);
  }

  Future<Map> getInvestReturn(int type) {
    Api.User.getInvestAndReturn(type).then((value) => setState(() {
          data = value;
        }));
  }

  @override
  Widget build(BuildContext context) {
    final txt = [
      '开宝箱前需要充值海星，每开一次消耗${widget.drawType == 1 ? 5000 : 20}个海星。',
      '您可以选择一次开一个，也可也选择开10个或100个，连续开宝箱更容易获得更好的物资哦。',
      '开宝箱100%获取物资。',
      '收集到的物资直接放在背包中。',
      '您可以在收集记录中看到自己最近收集的物资记录。',
      '如有问题可联系官方公众号：多肉语音',
    ];

    return SizedBox(
      height: 400,
      child: Material(
        color: Color(0xff363059),
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(18), topLeft: Radius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 15),
            child: Text('规则(爆率)',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text.rich(
              TextSpan(children: [
                for (var i = 0; i < txt.length; ++i)
                  TextSpan(text: '${i + 1}. ${txt[i]}\n')
              ]),
              style: TextStyle(
                  color: Color(0xff7C66FF), fontSize: 14, height: 1.8),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '今日消耗: ${data['inputNum']??0}',
                  style: TextStyle(
                      color: Color(0xff7C66FF), fontSize: 14, height: 1.8),
                ),
                Text(
                  '今日产出: ${data['outputNum']??0}',
                  style: TextStyle(
                      color: Color(0xff7C66FF), fontSize: 14, height: 1.8),
                ),
                Text(
                  '今日爆率: ${data['rate']??0}%',
                  style: TextStyle(
                      color: Color(0xff7C66FF), fontSize: 14, height: 1.8),
                ),
              ],
            ),
          )
          // XFutureBuilder<Map>(
          //   futureBuilder: getInvestReturn,
          //   onData: (data) {
          //     print("ddddddd=" + data.toString());
          //     return Text("XXXXXXX");
          //     // return SingleChildScrollView(
          //     //   padding: EdgeInsets.only(bottom: 10, top: 20),
          //     //   child: Text("xxxxx"),
          //     // );
          //   },
          // ),
        ]),
      ),
    );
  }
}
