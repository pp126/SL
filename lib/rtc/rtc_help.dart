import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:app/tools.dart';
import 'package:tuple/tuple.dart';

class RtcHelp {
  RtcHelp._();

  static final micSwitch = RxBool(false), audioSwitch = RxBool(true);
  static final networkQuality =
      Rx(Tuple2(NetworkQuality.Unknown, NetworkQuality.Unknown));
  static final micVol = RxDouble(100),
      bgmLocalVol = RxDouble(50),
      bgmPushVol = RxDouble(100);
  static final bgmState = Rx(AudioMixingStateCode.Stopped);

  static RtcEngine _engine;

  static Future<void> init() async {
    _engine = await RtcEngine.create('000cddcc74f444f19c5ce7c03bf32dac');

    _engine.setEventHandler(
      RtcEngineEventHandler(
        leaveChannel: (stats) {
          xlog('用户【${stats.toJson()}】成功离开房间', name: 'RTC');

          micSwitch.value = false;
        },
        userJoined: (int uid, int elapsed) {
          xlog('用户【$uid】开麦 $elapsed', name: 'RTC');

          Bus.send(CMD.micState, Tuple2(uid, true));
        },
        userOffline: (int uid, UserOfflineReason reason) {
          xlog('用户【$uid】关麦 -> $reason', name: 'RTC');

          Bus.send(CMD.micState, Tuple2(uid, false));
        },
        joinChannelSuccess: (String channel, int uid, int elapsed) async {
          xlog('用户【$uid】成功加入房间【$channel】', name: 'RTC');

          await _enableMic(micSwitch.value);
          await _enableAudio(audioSwitch.value);

          await _engine.setEnableSpeakerphone(true);
        },
        audioVolumeIndication: (speakers, _) {
          speakers //
              .where((it) => it.volume > 0)
              .map((it) => CMD.speak(it.uid))
              .forEach(Bus.send);
        },
        warning: (warn) {
          xlog('警告【$warn】', name: 'RTC');
        },
        error: (e) {
          xlog('错误【$e】', name: 'RTC');
        },
        networkQuality: (uid, tx, rx) => networkQuality.value = Tuple2(tx, rx),
        audioMixingStateChanged: (code, _) => bgmState.value = code,
      ),
    );

    await _cfgInit();

    await _micInit();
  }

  static Future<void> _cfgInit() async {
    await _engine.setAudioProfile(
        AudioProfile.MusicHighQualityStereo, AudioScenario.GameStreaming);
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);

    await _engine.enableAudioVolumeIndication(1000 - 618, 3, true);
  }

  static Future<void> _micInit() async {
    await _enableMic(micSwitch.value);
    await _enableAudio(audioSwitch.value);

    micSwitch.listen(_enableMic);
    audioSwitch.listen(_enableAudio);

    await setMicVol(micVol.value);
    await setBgmLocalVol(bgmLocalVol.value);
    await setBgmPushVol(bgmPushVol.value);

    micVol.listen(setMicVol);
    bgmLocalVol.listen(setBgmLocalVol);
    bgmPushVol.listen(setBgmPushVol);
  }

  static Future<void> join(String token, String room, int uid) async {
    await leave(uid);

    await _engine.joinChannel(token, room, null, uid);
  }

  static Future<void> leave(int uid) async {
    try {
      await _engine.leaveChannel();

      xlog('用户【$uid】 申请离开房间', name: 'RTC');
    } catch (e, s) {
      errLog(e, s: s, name: 'RTC');
    }
  }

  //开关麦
  static Future<void> _enableMic(bool enable) async {
    try {
      await _engine
          .setClientRole(enable ? ClientRole.Broadcaster : ClientRole.Audience);

      await _engine.muteLocalAudioStream(!enable);
      await _engine.enableLocalAudio(enable);

      xlog('麦克风状态设置为【$enable】', name: 'RTC');
    } catch (e, s) {
      errLog(e, s: s, name: 'RTC');
    }
  }

  //开关声音
  static Future<void> _enableAudio(bool enable) async {
    try {
      await _engine.muteAllRemoteAudioStreams(!enable);

      xlog('声音状态设置为【$enable】', name: 'RTC');
    } catch (e, s) {
      errLog(e, s: s, name: 'RTC');
    }
  }

  static playBGM(String path) {
    xlog('播放 => $path', name: 'RTC');

    return _engine.startAudioMixing(path, false, false, 1);
  }

  static stopBGM() => _engine.stopAudioMixing();

  static pauseBGM() => _engine.pauseAudioMixing();

  static resumeBGM() => _engine.resumeAudioMixing();

  static leaveMic() {
    RtcHelp.stopBGM();

    micSwitch.value = false;
  }

  static Future<void> setMicVol(double volume) =>
      _engine.adjustRecordingSignalVolume(volume.toInt());

  static Future<void> setBgmLocalVol(double volume) =>
      _engine.adjustAudioMixingPlayoutVolume(volume.toInt());

  static Future<void> setBgmPushVol(double volume) =>
      _engine.adjustAudioMixingPublishVolume(volume.toInt());
}
