
import 'package:app/common/theme.dart';
import 'package:app/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ServiceType {
  privacy,///隐私协议
  user,///用户协议
}

class TermsOfServicePage extends StatefulWidget {
  final ServiceType type;

  TermsOfServicePage({this.type = ServiceType.user});

  @override
  _TermsOfServicePageState createState() => _TermsOfServicePageState();
}

class _TermsOfServicePageState extends State<TermsOfServicePage> {
  final data = {
    ServiceType.privacy:['隐私协议','《喵喵语音隐私协议》','pact_privacy'],
    ServiceType.user:['用户协议','《喵喵语音用户协议》','pact_user'],
  };

  @override
  Widget build(BuildContext context) {
    final item = data[widget.type];

    return Scaffold(
      appBar: xAppBar(item[0]),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 35, vertical: 20),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 15),
              child: Text(
                item[1],
                style: TextStyle(fontSize: 18,color: AppPalette.dark,fontWeight: fw$SemiBold),
              ),
            ),
            FutureBuilder(
              future: rootBundle.loadString('assets/pact/${item[2]}.txt'),
              builder: (_, data) {
                if (data.hasData) {
                  final ts = TextStyle(color: Color(0xff2D2A26), fontSize: 14);

                  return Text(data.data, style: ts);
                } else {
                  return SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
