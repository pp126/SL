import 'package:app/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:app/nim/nim_help.dart';
import 'package:app/ui/message/message_item_view.dart';
import 'package:app/widgets/future_builder.dart';

class MessageStorageBoxView extends StatefulWidget {
  final List unReadList;

  MessageStorageBoxView(this.unReadList);

  @override
  _MessageStorageBoxViewState createState() => _MessageStorageBoxViewState();
}

class _MessageStorageBoxViewState extends State<MessageStorageBoxView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: xAppBar('互动消息'),
        body: NotifierView(NimHelp.messagesNotifier, (data) {
          return RefreshIndicator(
            onRefresh: () async => NimHelp.refreshChatList(),
            child: ListView.separated(
              itemCount: widget.unReadList.length,
              itemBuilder: (_, i) => MessageItemView(
                widget.unReadList[i],
                dataChange: () {
                  setState(() {
                    widget.unReadList.removeAt(i);
                  });
                },
              ),
              separatorBuilder: (_, __) =>
                  Divider(height: 1, indent: 73, endIndent: 15),
            ),
          );
        }));
  }
}
