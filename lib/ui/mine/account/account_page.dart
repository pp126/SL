import 'dart:async';
import 'dart:io';

import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/net/file_api.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/tools/dialog.dart';
import 'package:app/ui/common/svga_icon.dart';
import 'package:app/ui/mine/account/name_page.dart';
import 'package:app/ui/mine/account/photo_page.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'des_page.dart';
import 'package:flutter_sound/flutter_sound.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: xAppBar('编辑个人资料'),
      backgroundColor: AppPalette.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: OAuthCtrl.use(builder: (user) {
          bool noSet = user['gender'] == 0;
          return Column(
            children: <Widget>[
              Container(
                height: 122,
                alignment: Alignment.center,
                child: InkResponse(
                  onTap: () {
                    imagePicker(
                      (file) {
                        simpleSub(
                          () async {
                            final url =
                                await FileApi.upLoadFile(file, 'avatar/');

                            await OAuthCtrl.obj.updateUserInfo({'avatar': url});
                          },
                        );
                      },
                      max: 512,
                    );
                  },
                  child: SelfView(),
                ),
              ),
              ...[
                Item(
                  '昵称',
                  user['nick'],
                  AppPalette.dark,
                  () => Get.to(NamePage()),
                ),
                Item('性别', noSet ? '请设置' : (user['gender'] == 1 ? '男' : '女'),
                    AppPalette.dark, () {
                  if (noSet) {
                    showPickerArray(context);
                  } else {
                    showToast('性别不允许修改');
                  }
                }),
                Item(
                  '生日',
                  dateFormat(user['birth']),
                  AppPalette.dark,
                  () => showPickerDateTime(user['birth'], context),
                ),
                Item(
                  '个性签名',
                  xMapStr(user, 'userDesc', defaultStr: '您暂无个人签名'),
                  AppPalette.hint,
                  () => Get.to(DesPage()),
                ),
                Item('相册管理', '${user['privatePhoto']?.length}p',
                    AppPalette.primary, () {
                  Get.to(MyPhotoPage());
                }),
                Item(
                    '我的录音',
                    null == user['voiceUrl'] ? '未设置' : '已设置',
                    null == user['voiceUrl']
                        ? AppPalette.hint
                        : AppPalette.primary, () {
                  Get.showBottomSheet(VoiceRecordContent());
                }),
              ].map(xItem).separator(Spacing.h10)
            ],
          );
        }),
      ),
    );
  }

  dateFormat(num data) {
    assert(data != null);

    return data == null
        ? '--'
        : DateFormat("yyyy-MM-dd")
            .format(DateTime.fromMillisecondsSinceEpoch(data));
  }

  showPickerArray(BuildContext context) {
    DialogUtils.showSexDialog(context);
  }

  showPickerDateTime(int birth, BuildContext context) async {
    final _birth = DateTime.fromMillisecondsSinceEpoch(birth);

    final last = DateTime.now();
    final first = last.subtract(Duration(days: 100 * 365));

    final date = await showDatePicker(
      context: context,
      firstDate: first,
      lastDate: last,
      initialDate: _birth,
    );

    if (date != null) {
      final newBirth = date.millisecondsSinceEpoch;

      simpleSub(OAuthCtrl.obj.updateUserInfo({'birth': dateFormat(newBirth)}));
    }
  }

  Widget xItem(Item item) {
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: item.onTop,
        child: Container(
          height: 60,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(item.label,
                  style: TextStyle(color: AppPalette.tips, fontSize: 14)),
              Expanded(
                child: Text(
                  item.context,
                  textAlign: TextAlign.right,
                  style: TextStyle(color: item.color, fontSize: 14),
                ),
              ),
              Spacing.w10,
              Icon(Icons.arrow_forward_ios, size: 12, color: AppPalette.hint)
            ],
          ),
        ),
      ),
    );
  }
}

class Item {
  String label;
  String context;
  Color color;
  var onTop;

  Item(this.label, this.context, this.color, this.onTop);
}

class VoiceRecordContent extends StatefulWidget {
  @override
  _VoiceRecordContentState createState() => _VoiceRecordContentState();
}

class _VoiceRecordContentState extends State<VoiceRecordContent> {
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _isPressing = false;
  bool _isFinished = false;
  bool _isUpLoading = false;

  FlutterSoundRecorder _recorder;
  FlutterSoundPlayer _player = FlutterSoundPlayer();

  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;

  Timer timer;

  var isCancel = false;
  var isGranted = false;

  final format = NumberFormat('00');
  final stopwatch = RxInt(0);

  File _outputFile;

  StreamSubscription _playerSubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestPermission();
    _initRecorder();

    stopwatch.value = 0;
  }

  void requestPermission() async {
    bool micIsGranted = await Permission.microphone.request().isGranted;
    bool storageIsGranted = await Permission.storage.request().isGranted;
    if (micIsGranted && storageIsGranted) {
      setState(() => isGranted = true);
    } else {
      var result = await Get.simpleDialog(
        msg: '录音需要您麦克风和存储权限',
        okLabel: '去授权',
      );
      if ('去授权' == result) {
        openAppSettings();
      } else {
        Navigator.pop(context);
      }
    }
  }

  _initRecorder() async {
    Directory directory = await getTemporaryDirectory();
    _outputFile = File('${directory.path}/flutter_sound.aac');
    if (_outputFile.existsSync()) {
      await _outputFile.delete();
    }

    // _player.openAudioSession(mode: SessionMode.modeSpokenAudio).then((value) {
    //   setState(() {
    //     _mPlayerIsInited = true;
    //   });
    // });

    // _recorder = await FlutterSoundRecorder()
    //     .openAudioSession(mode: SessionMode.modeSpokenAudio);
    _mRecorderIsInited = true;

    // _recorder.setAudioFocus(focus: AudioFocus.requestFocusAndDuckOthers);
  }

  @override
  Widget build(BuildContext context) {
    final size = 100.0;
    return Container(
      height: 336,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12.0))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _isUpLoading
              ? SizedBox()
              : Container(
                  alignment: Alignment.topRight,
                  child: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context)),
                ),
          _isUpLoading
              ? SizedBox()
              : Obx(() {
                  final duration = Duration(milliseconds: stopwatch.value);
                  int tens = duration.inMilliseconds ~/ 10 % 10;
                  int hundred = duration.inMilliseconds ~/ 100 % 10;
                  int seconds = duration.inMilliseconds ~/ 1000;
                  if (duration.inMilliseconds >= 30000) {
                    stop();
                  }
                  return Text(
                    '${format.format(seconds)}:${format.format(hundred * 10 + tens)}',
                    style: TextStyle(
                        fontSize: 30,
                        color: AppPalette.dark,
                        fontWeight: fw$SemiBold),
                  );
                }),
          _isUpLoading || _isPressing
              ? SizedBox()
              : Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Text(
                    _isFinished ? _isPlaying?'点击停止':'点击试听' : '点击开始录制',
                    style: TextStyle(
                        color: AppPalette.dark,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _isUpLoading
                    ? SizedBox()
                    : (_isFinished && !_isPlaying)
                        ? tpbtButton(
                            images: 'mic/重录',
                            title: '重录',
                            onPressed: () {
                              setState(() {
                                _isFinished = false;
                              });
                              cancel();
                            })
                        : SizedBox(),
                Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onTap: () async {
                      if (_isFinished) {
                        setState(() {
                          _isPlaying = !_isPlaying;
                          if (_isPlaying) {
                            play();
                            stopwatch.value = 0;
                            starTimer();
                          }else{
                            stopPlay();
                          }
                        });
                      }
                    },
                    onLongPressStart: (LongPressStartDetails details) {
                      print('onPanDown');
                      if (!_isFinished) {
                        start();
                      }
                    },
                    onLongPressEnd: (LongPressEndDetails details) {
                      stop();
                    },
                    onLongPressMoveUpdate: (it) async {
                      if (isCancel) return;

                      final position = it.localPosition;

                      if (position.dx < 0 ||
                          position.dx > size ||
                          position.dy < 0 ||
                          position.dy > size) {
                        cancel();
                      }
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _isPlaying || _isPressing
                            ? Center(
                                child: Container(
                                  width: 254,
                                  child: SVGAImg(
                                    assets: SVGA.$('音浪'),
                                  ),
                                ),
                              )
                            : SizedBox(),
                        Center(
                          child: AnimatedContainer(
                            margin: const EdgeInsets.symmetric(vertical: 30),
                            width: _isRecording && !_isFinished ? 120 : 102,
                            height: _isRecording && !_isFinished ? 120 : 102,
                            duration: Duration(milliseconds: 618),
                            curve: Curves.easeInOut,
                            onEnd: () {
                              if (_isPressing && !_isFinished) {
                                setState(() {
                                  _isRecording = !_isRecording;
                                });
                              }
                            },
                            child: _isUpLoading
                                ? SVGAImg(
                                    assets: SVGA.$('loading'),
                                  )
                                : Image.asset(
                                    IMG.$(_isFinished
                                        ? _isPlaying
                                            ? 'mic/停止'
                                            : 'mic/播放'
                                        : 'mic/录制'),
                                    width: 91,
                                    height: 91,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _isUpLoading
                    ? SizedBox()
                    : (_isFinished && !_isPlaying)
                        ? tpbtButton(
                            images: 'mic/确定',
                            title: '确定',
                            iconColor: AppPalette.primary,
                            onPressed: () {
                              setState(() {
                                _isUpLoading = true;
                              });
                              stopPlayer();
                              uploadAudio(PickedFile(_outputFile.path));
                            })
                        : SizedBox(),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 15),
            child: Text(
              _isUpLoading
                  ? '正在上传'
                  : _isFinished
                      ? '录制完成'
                      : '最短5s，最长30秒',
              style: TextStyle(fontSize: 14, color: AppPalette.tips),
            ),
          )
        ],
      ),
    );
  }

  Widget tpbtButton(
      {String images, String title, Color iconColor, VoidCallback onPressed}) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      child: IconButton(
          iconSize: 70,
          icon: Column(
            children: [
              Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  height: 37,
                  width: 37,
                  decoration: BoxDecoration(
                      color: iconColor ?? AppPalette.hint,
                      borderRadius: BorderRadius.all(Radius.circular(18.5))),
                  child: Image.asset(
                    IMG.$('$images'),
                    width: 37,
                    height: 37,
                  )),
              Text(
                '$title',
                style: TextStyle(color: AppPalette.dark),
              )
            ],
          ),
          onPressed: onPressed),
    );
  }

  start() async {
    isCancel = false;
    setState(() {
      _isRecording = true;
      _isPressing = true;
    });
    assert(_mRecorderIsInited && _player.isStopped);
    await _recorder.startRecorder(
      toFile: _outputFile.path,
      codec: Codec.aacADTS,
    );

    starTimer();
  }

  starTimer() {
    timer = Timer.periodic(Duration(milliseconds: 1), (timer) {
      stopwatch.value++;
    });
  }

  stop() async {
    setState(() {
      _isPressing = false;
      _isRecording = false;
      if (stopwatch.value <= 5000) {
        _isFinished = false;
        stopwatch.value = 0;
        showToast('录制音频必须大于5秒');
      } else {
        _isFinished = true;
      }
    });
    await _recorder.stopRecorder();
    _mplaybackReady = true;

    timer?.cancel();
  }

  stopPlay() {
    stopwatch.value = 0;
    stopPlayer();
    timer?.cancel();
  }
  cancel() {
    isCancel = true;
    stopwatch.value = 0;
    stopPlayer();
  }

  void play() async {
    assert(_mPlayerIsInited &&
        _mplaybackReady &&
        _recorder.isStopped &&
        _player.isStopped);
    await _player.startPlayer(
        fromURI: _outputFile.path,
        codec: Codec.aacADTS,
        whenFinished: () {
          setState(() {
            _isPlaying = false;
            timer?.cancel();
            stopwatch.value = 0;
          });
        });
    setState(() {});
  }

  Future<void> stopPlayer() async {
    await _player?.stopPlayer();
  }

  uploadAudio(PickedFile audio) async {
    final url = await FileApi.upLoadAudioFile(audio, 'audio/');
    await Api.User.updateUserInfo({'voiceUrl': url});
    await OAuthCtrl.obj.fetchInfo();
    Navigator.pop(context);
    showToast('上传成功');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if (_recorder != null) {
      _recorder.closeRecorder();
      _recorder = null;
    }
    timer?.cancel();
    super.dispose();
  }
}
