import 'package:flutter/material.dart';
import 'dart:async';
///倒计时
class TimerOutLine extends StatefulWidget {
  TimerOutLine({Key key, this.time}) : super(key: key);
  final int time;///毫秒
  @override
  createState() => new _TimerOutLineState();
}

class _TimerOutLineState extends State<TimerOutLine> {

  Timer _timer;
  int seconds = 0;
  bool _timeState = true;
  String _title = 'start';
  String _content = '00:00:00';

  @override
  Widget build(BuildContext context) {

    print('build');

    _content = constructTime(seconds);

    return Container(
      width: 70,
      child: Center(
        child: Text("$_content",
          style: TextStyle(color: Colors.red,fontSize: 16),
        ),
      ),
    );
  }


  //时间格式化，根据总秒数转换为对应的 hh:mm:ss 格式
  String constructTime(int seconds) {
    int hour = seconds ~/ 3600;
    int minute = seconds % 3600 ~/ 60;
    int second = seconds % 60;
    return formatTime(hour) + ":" + formatTime(minute) + ":" + formatTime(second);
  }

  //数字格式化，将 0~9 的时间转换为 00~09
  String formatTime(int timeNum) {
    return timeNum < 10 ? "0" + timeNum.toString() : timeNum.toString();
  }

  // 初始化方法。先于build执行
  @override
  void initState() {
    super.initState();

    countDownTest();
  }

  void countDownTest(){

    _timeState = !_timeState;
    setState(() {
      if (_timeState) {
        _title = 'start';
      } else {
        _title = 'stop';
      }
    });

    if (!_timeState) {
      //获取当期时间
      var now = DateTime.now();
      //获取 2 分钟的时间间隔
      var twoHours = now.add(Duration(milliseconds: widget.time)).difference(now);
      //获取总秒数，2 分钟为 120 秒
      seconds = twoHours.inSeconds;
      startTimer();
    } else {
      seconds = 0;
      cancelTimer();
    }
  }

  void startTimer() {
    //设置 1 秒回调一次
    const period = const Duration(seconds: 1);
    _timer = Timer.periodic(period, (timer) {
      //更新界面
      setState(() {
        //秒数减一，因为一秒回调一次
        seconds--;
      });
      if (seconds == 0) {
        //倒计时秒数为0，取消定时器
        cancelTimer();
      }
    });
  }

  void cancelTimer() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    cancelTimer();
    // 相当于dealloc
    super.dispose();
  }
}
