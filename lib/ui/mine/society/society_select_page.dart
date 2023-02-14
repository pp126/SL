import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/ui/mine/society/society_page.dart';
import 'package:app/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../exception.dart';
import 'noin_society_page.dart';

class SocietySelectPage extends StatefulWidget {
  @override
  _SocietySelectPageState createState() => _SocietySelectPageState();
}

class _SocietySelectPageState extends State<SocietySelectPage> {
  Future getData(){
    return Api.Family.checkFamilyJoin();
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: XFutureBuilder(futureBuilder: getData, onData: (value) {
        if (value != null && value != '') {
          return SocietyPage(value);
        } else {
          return NoinSocietyPage();
        }
      },),
    );
  }
  appber(boy) {
    return Scaffold(backgroundColor: Colors.white, appBar: xAppBar('我的工会'), body: boy);
  }
}
