import 'dart:async';

import 'package:app/common/theme.dart';
import 'package:app/nim/nim_help.dart';
import 'package:app/store/call_overlay_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/message/chat/chat_ctrl.dart';
import 'package:app/ui/red_envelope/chat_red_envelope_page.dart';
import 'package:app/ui/room/gift_bottom_sheet.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/future_builder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class MsgSendView extends StatefulWidget {
  @override
  _MsgSendViewState createState() => _MsgSendViewState();
}

class _MsgSendViewState extends State<MsgSendView> {
  final ctrl = TextEditingController();
  final focus = FocusNode();
  final notifier = ValueNotifier<String>(null);
  final chatCtrl = Get.find<ChatCtrl>();

  @override
  void initState() {
    super.initState();

    focus.addListener(() => notifier.value = null);
  }

  @override
  void dispose() {
    ctrl.dispose();
    focus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _bottom = MediaQuery.of(context).padding.bottom;
    final _height = keyboardHeight() - _bottom;

    return Material(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.only(bottom: _bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TxtInputView(ctrl, focus, onItemClick),
            _ActionView(onItemClick),
            NotifierView<String>(notifier, (v) {
              switch (v) {
                case '表情':
                  return Container(height: _height, child: _StickersView(ctrl));
                case '说话':
                  return Container(height: _height, child: _AudioView());
                default:
                  return AnimatedContainer(
                    duration: kThemeAnimationDuration,
                    height: MediaQuery.of(context).viewInsets.bottom,
                  );
              }
            }),
          ],
        ),
      ),
    );
  }

  void onTxtSend() {
    final txt = ctrl.text;

    if (!txt.isNullOrBlank) {
      chatCtrl.sendText(txt);

      ctrl.clear();
    }
  }

  void onItemClick(String item) {
    switch (item) {
      case '表情':
      case '说话':
        hideKeyboard();
        notifier.value = item;
        return;
      case '相册':
        Get.showActionSheet(['拍照', '相册']).then((it) {
          switch (it) {
            case '拍照':
              imagePicker(chatCtrl.sendImage, source: ImageSource.camera);

              break;
            case '相册':
              imagePicker(chatCtrl.sendImage);
              break;
          }
        });
        break;
      case '礼物':
        GiftBottomSheet.to(GiftSend2UserCtrl(chatCtrl.imUser));

        break;
      case '通话':
        CallOverlayCtrl.obj.to(chatCtrl.imUid);

        break;
      case '发送':
        onTxtSend();

        break;
      case '红包':
        Get.to(ChatRedEnvelopePage(chatCtrl.imUid));

        break;
    }

    notifier.value = null;
  }
}

class _ActionView extends StatelessWidget {
  final ValueChanged<String> onItemClick;

  _ActionView(this.onItemClick);

  final data = ['相册', '礼物', '通话', '表情', '红包'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: data
            .map(
              (it) => IconButton(
                icon: SvgPicture.asset(SVG.$('chat/$it')),
                padding: EdgeInsets.zero,
                onPressed: () => onItemClick(it),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _TxtInputView extends StatelessWidget {
  final FocusNode focus;
  final ValueChanged<String> onItemClick;
  final TextEditingController ctrl;

  _TxtInputView(this.ctrl, this.focus, this.onItemClick);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Spacing.w4,
          InkResponse(
            child: Container(
              width: 56,
              height: 32,
              child: SvgPicture.asset(SVG.$('chat/说话')),
            ),
            onTap: () => onItemClick('说话'),
          ),
          Expanded(
            child: Container(
              height: 40,
              decoration: ShapeDecoration(
                color: Color(0xFFF1F0F7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.horizontal(right: Radius.circular(4), left: Radius.circular(20)),
                ),
              ),
              alignment: Alignment.centerLeft,
              child: TextField(
                focusNode: focus,
                controller: ctrl,
                style: TextStyle(fontSize: 14, color: AppPalette.dark),
                decoration: InputDecoration(
                  hintText: '说点什么吧。',
                  hintStyle: TextStyle(fontSize: 14, color: AppPalette.hint),
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
          ),
          Spacing.w6,
          Material(
            color: AppPalette.txtWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(4), right: Radius.circular(20)),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              child: Container(
                width: 72,
                height: 40,
                alignment: Alignment.center,
                child: Text(
                  '发送',
                  style: TextStyle(fontSize: 14, color: AppPalette.primary, fontWeight: fw$SemiBold),
                ),
              ),
              onTap: () => onItemClick('发送'),
            ),
          ),
          Spacing.w16,
        ],
      ),
    );
  }
}

class _StickersView extends StatelessWidget {
  final TextEditingController ctrl;

  _StickersView(this.ctrl);

  static Future<List<String>> get _data => rootBundle.loadString('assets/emoji').then((it) => it.split(','));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: XFutureBuilder(
            futureBuilder: () => _data,
            onData: (data) {
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1),
                itemCount: data.length,
                itemBuilder: (_, i) {
                  final item = data[i];

                  return InkResponse(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FittedBox(child: Text(item)),
                    ),
                    onTap: () => ctrl.join(item),
                  );
                },
              );
            },
          ),
        ),
        Container(
          height: 48,
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: Icon(Icons.backspace),
            color: AppPalette.primary,
            onPressed: ctrl.backspace,
          ),
        ),
      ],
    );
  }
}

class _AudioView extends StatefulWidget {
  @override
  _AudioViewState createState() => _AudioViewState();
}

class _AudioViewState extends State<_AudioView> {
  final format = NumberFormat('00');
  final stopwatch = RxInt(0);

  Timer timer;
  var isCancel = false;
  var isGranted = false;

  @override
  void dispose() {
    timer?.cancel();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  void requestPermission() async {
    if (!await Permission.microphone.request().isGranted) return;
    if (!await Permission.storage.request().isGranted) return;
    setState(() => isGranted = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!isGranted) return Center(child: Text('语音需要授权', style: TextStyle(fontSize: 14, color: AppPalette.tips)));

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Obx(() {
          final duration = Duration(seconds: stopwatch.value);

          return Text(
            '${format.format(duration.inMinutes)}:${format.format(duration.inSeconds)}',
            style: TextStyle(fontSize: 30, color: Color(0xFF0A294F), fontWeight: fw$SemiBold),
          );
        }),
        $RecordView(),
        Text(
          '按住说话，松开发送，移开取消发送',
          style: TextStyle(fontSize: 14, color: AppPalette.tips),
        ),
      ],
    );
  }

  Widget $RecordView() {
    final dec = BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: -6)],
    );

    final size = 100.0;

    return GestureDetector(
      child: Container(
        decoration: dec,
        width: size,
        height: size,
        child: SvgPicture.asset(SVG.$('chat/录制')),
      ),
      onPanDown: (_) => start(),
      onPanEnd: (_) => stop(),
      onPanCancel: () => stop(),
      onPanUpdate: (it) {
        if (isCancel) return;

        final position = it.localPosition;

        if (position.dx < 0 || position.dx > size || position.dy < 0 || position.dy > size) {
          cancel();
        }
      },
    );
  }

  start() {
    isCancel = false;

    stopwatch.value = 0;

    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      stopwatch.value++;
    });

    NimHelp.startRecording();
  }

  stop() {
    timer.cancel();
    stopwatch.value = 0;

    if (!isCancel) {
      NimHelp.stopRecording();

      Get.find<ChatCtrl>().sendRecording();
    }
  }

  cancel() {
    isCancel = true;

    timer.cancel();
    stopwatch.value = 0;

    NimHelp.cancelRecording();
  }
}
