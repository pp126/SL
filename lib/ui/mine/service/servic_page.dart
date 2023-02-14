import 'dart:typed_data';

import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/tools/common_utils.dart';
import 'package:app/widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';


class ServicPage extends StatefulWidget {
  @override
  _ServicPageState createState() => _ServicPageState();
}

// getCustomer
class _ServicPageState extends State<ServicPage> {
  Future<Map> getCustomer() {
    return Api.User.getCustomer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar('联系客服'),
      backgroundColor: AppPalette.background,
      body: XFutureBuilder(
        futureBuilder: getCustomer,
        onData: (data) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 10, top: 20),
            child: Column(
              children: <Widget>[
                $QRCode('微信客服：', data['wxCustomer'], data['wxCustomerUrl']),
                $QRCode('微信公众号：', data['wxSubscription'], data['wxSubscriptionUrl']),
                $Data('官方网址：', data['companyUrl'], Color(0xff7C66FF)),
                $Data('公司名称：', data['companyName'], Color(0xff908DA8)),
              ].separator(SizedBox(height: 10)),
            ),
          );
        },
      ),
    );
  }

  $QRCode(String label, String name, String qrUrl) {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text.rich(
            TextSpan(children: [
              TextSpan(text: label, style: TextStyle(color: Color(0xff252142))),
              TextSpan(text: name, style: TextStyle(color: Color(0xff7C66FF)))
            ]),
            style: TextStyle(fontSize: 14),
          ),
          Text(
            '复制',
            style: TextStyle(color: Colors.white, fontSize: 10),
          ).toBtn(24, Color(0xff7C66FF), width: 50, onTap: () {
            CommonUtils.copyToClipboard(name);
            showToast('复制成功');
          })
        ],
      ),
      Padding(
        padding: const EdgeInsets.only(top: 28, bottom: 10),
        child: NetImage(
          qrUrl,
          width: 120,
          height: 120,
          fit: BoxFit.fill,
        ),
      ),
      Text(
        '保存二维码',
        style: TextStyle(color: Color(0xff7C66FF), fontSize: 10),
      ).toBtn(24, Color(0xffF1EEFF), width: 104, onTap: () async {
        if (await Permission.storage.request().isGranted) {
          try {
            var response = await Dio().get(qrUrl, options: Options(responseType: ResponseType.bytes));
            await ImageGallerySaver.saveImage(Uint8List.fromList(response.data));
            showToast('保存成功');
          } catch (e) {
            showToast('保存失败');
          }
        }
      })
    ]).toWarp(padding: EdgeInsets.all(20), margin: EdgeInsets.symmetric(horizontal: 15));
  }

  $Data(String label, String data, Color textColor) {
    return DefaultTextStyle(
        style: TextStyle(fontSize: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: Color(0xff252142))),
            Text(data, style: TextStyle(color: textColor)),
          ],
        )).toWarp(padding: EdgeInsets.all(20), margin: EdgeInsets.symmetric(horizontal: 15));
  }
}
