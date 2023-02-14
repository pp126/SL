import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

class RoomTagPage extends StatefulWidget {
  @override
  _RoomTagPageState createState() => _RoomTagPageState();
}

class _RoomTagPageState extends State<RoomTagPage> {
  final _tagNotifier = ValueNotifier<Map>(null);

  @override
  void initState() {
    super.initState();

    _tagNotifier.addListener(() => Get.back(result: _tagNotifier.value));
  }

  @override
  void dispose() {
    _tagNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeDark,
      child: Scaffold(
        appBar: xAppBar('房间类型'),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: RoomTagView(_tagNotifier),
        ),
      ),
    );
  }
}

class RoomTagView extends StatelessWidget {
  final ValueNotifier<Map> _tagNotifier;

  RoomTagView(this._tagNotifier);

  @override
  Widget build(BuildContext context) {
    Widget createItem(Map it, Map select) {
      Widget child = NetImage(it['pict'], width: 64, height: 30, fit: BoxFit.fill);

      if (select == null || it['id'] != select['id']) {
        child = InkWell(
          child: Opacity(opacity: 0.618, child: child),
          onTap: () => _tagNotifier.value = it,
        );
      }

      return child;
    }

    return XFutureBuilder(
      futureBuilder: () => Api.Room.tagList(),
      onData: (data) {
        return NotifierView(
          _tagNotifier,
          (select) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: data.map<Widget>((it) => createItem(it, select)).toList(growable: false),
          ),
        );
      },
    );
  }
}
