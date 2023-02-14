import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools/time.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

import '../../../../tools.dart';

class WalletDrawListPage extends StatefulWidget {
  @override
  _WalletDrawListPageState createState() => _WalletDrawListPageState();
}

class _WalletDrawListPageState extends State<WalletDrawListPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar('提现记录'),
      backgroundColor: AppPalette.background,
      body: WalletDrawListView(),
    );
  }
}

class WalletDrawListView extends StatefulWidget {
  @override
  _WalletDrawListViewState createState() => _WalletDrawListViewState();
}

class _WalletDrawListViewState extends NetPageList<Map, WalletDrawListView> {
  // 订单状态：1申请提现；2提现成功；3提现失败,4.提现取消,5.提现中
  final imgs = {
    1: Image.asset(
      IMG.$('icon支付宝'),
      width: 40,
      height: 40,
    ),
    2: Image.asset(
      IMG.$('icon微信'),
      width: 40,
      height: 40,
    ),
    3: Image.asset(IMG.$('icon银行卡'), scale: 3).toTagView(40, Color(0xff7C66FF), radius: 10, width: 40),
  };

  final colors = {
    1: Color(0xffFF607C),
    2: Color(0xff50B674),
    3: Color(0xffFF607C),
    4: Color(0xffCBC8DC),
    5: Color(0xff50B674),
  };

  final types = {
    1: '审核中',
    2: '提现成功',
    3: '提现失败',
    4: '提现取消',
    5: '提现中',
  };

  @override
  Widget itemBuilder(BuildContext context, Map item, int index) => _itme(item);

  @override
  Future fetchPage(PageNum page) {
    return Api.Draw.queryUserTransfer(page.index, page.size);
  }

  _itme(Map item) {
    int billStatus = xMapStr(item, 'billStatus', defaultStr: 1);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              imgs[xMapStr(item, 'realTranType', defaultStr: 1)],
              Spacing.w10,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${xMapStr(item, 'account', defaultStr: '')}',
                    style: TextStyle(fontSize: 14),
                  ),
                  Spacing.h6,
                  Text(
                    '${TimeUtils.getDateStrByDateTime(DateTime.fromMillisecondsSinceEpoch(xMapStr(item, 'updateTime', defaultStr: 0)), format: DateFormat.MONTH_DAY_HOUR_MINUTE)}',
                    style: TextStyle(fontSize: 11, color: Color(0xffCBC8DC)),
                  ),
                ],
              ),
              Spacing(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${xMapStr(item, 'money', defaultStr: '0')}元',
                    style: TextStyle(color: Color(0xff7C66FF), fontSize: 14),
                  ),
                  Spacing.h6,
                  Text(
                    '${types[billStatus]}',
                    style: TextStyle(fontSize: 11, color: colors[billStatus]),
                  ),
                ],
              ),
            ],
          ),
          if (billStatus == 1 || billStatus == 5) ...[
            Spacing.h6,
            Divider(),
            Spacing.h6,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                billStatus == 5
                    ? Text('预计两小时到账', style: TextStyle(color: Color(0xffCBC8DC), fontSize: 12))
                    : SizedBox(),
                Text(
                  '取消申请',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ).toBtn(
                  29,
                  AppPalette.hint,
                  width: 81,
                  colors: [Color(0xffAA66FF), Color(0xff7C66FF)],
                  onTap: () => doSub(xMapStr(item, 'id', defaultStr: -1)),
                )
              ],
            )
          ]
        ],
      ).toWarp(radius: 12, padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10)),
    );
  }

  doSub(int id) {
    simpleSub(Api.Draw.updateUserTransfer(id), msg: '取消成功', callback: () {
      doRefresh();
    });
  }
}
