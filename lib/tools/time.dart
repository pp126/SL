
///时间格式
enum DateFormat {
  DEFAULT, //yyyy-MM-dd HH:mm:ss.SSS
  NORMAL, //yyyy-MM-dd HH:mm:ss
  YEAR_MONTH_DAY_HOUR_MINUTE, //yyyy-MM-dd HH:mm
  YEAR_MONTH_DAY, //yyyy-MM-dd
  YEAR_MONTH, //yyyy-MM
  MONTH_DAY, //MM-dd
  MONTH_DAY_HOUR_MINUTE, //MM-dd HH:mm
  HOUR_MINUTE_SECOND, //HH:mm:ss
  HOUR_MINUTE, //HH:mm

  ZH_DEFAULT, //yyyy年MM月dd日 HH时mm分ss秒SSS毫秒
  ZH_NORMAL, //yyyy年MM月dd日 HH时mm分ss秒  /  timeSeparate: ":" --> yyyy年MM月dd日 HH:mm:ss
  ZH_YEAR_MONTH_DAY_HOUR_MINUTE, //yyyy年MM月dd日 HH时mm分  /  timeSeparate: ":" --> yyyy年MM月dd日 HH:mm
  ZH_YEAR_MONTH_DAY, //yyyy年MM月dd日
  ZH_YEAR_MONTH, //yyyy年MM月
  ZH_MONTH_DAY, //MM月dd日
  ZH_MONTH_DAY_HOUR_MINUTE, //MM月dd日 HH时mm分  /  timeSeparate: ":" --> MM月dd日 HH:mm
  ZH_HOUR_MINUTE_SECOND, //HH时mm分ss秒
  ZH_HOUR_MINUTE, //HH时mm分
}

Map<int, int> monthDay = {
  1: 31,
  2: 28,
  3: 31,
  4: 30,
  5: 31,
  6: 30,
  7: 31,
  8: 31,
  9: 30,
  10: 31,
  11: 30,
  12: 31,
};

class TimeUtils{
  static final double MILLIS_LIMIT = 1000.0;

  static final double SECONDS_LIMIT = 60 * MILLIS_LIMIT;

  static final double MINUTES_LIMIT = 60 * SECONDS_LIMIT;

  static final double HOURS_LIMIT = 24 * MINUTES_LIMIT;

  static final double DAYS_LIMIT = 30 * HOURS_LIMIT;

  ///日期格式转换
  static String getNewsTimeStr(var date) {
    var data;

    if(date is String){
      data = DateTime.tryParse(date);
    }else if(date is int){
      data = getDateTimeByMs(date);
    }else if(!(date is DateTime)){
      return date.toString();
    }

    if(data != null) {
      int subTime = DateTime
          .now()
          .millisecondsSinceEpoch - data.millisecondsSinceEpoch;

      if (subTime < MILLIS_LIMIT) {
        return "刚刚";
      } else if (subTime < SECONDS_LIMIT) {
        return (subTime / MILLIS_LIMIT).round().toString() + " 秒前";
      } else if (subTime < MINUTES_LIMIT) {
        return (subTime / SECONDS_LIMIT).round().toString() + " 分钟前";
      } else if (subTime < HOURS_LIMIT) {
        return (subTime / MINUTES_LIMIT).round().toString() + " 小时前";
      } else if (subTime < DAYS_LIMIT) {
        return (subTime / HOURS_LIMIT).round().toString() + " 天前";
      } else {
        return getDateStr(data);
      }
    }
    return date;
  }
  static String getDateStr(DateTime date) {
    if (date == null || date.toString() == null) {
      return "";
    } else if (date.toString().length < 10) {
      return date.toString();
    }
    return date.toString().substring(0, 10);
  }
  ///日期格式转换
  static String getShortTimeStr(var date) {
    var data;
    if(date is String){
      data = DateTime.tryParse(date);
    }else if(!(date is DateTime)){
      return date.toString();
    }
    if(data != null) {
      int subTime = DateTime
          .now()
          .millisecondsSinceEpoch - data.millisecondsSinceEpoch;

      if (subTime < HOURS_LIMIT) {
        return getDateStrByTimeStr(date,format: DateFormat.HOUR_MINUTE);
      } else {
        return getDateStrByTimeStr(date,format: DateFormat.YEAR_MONTH_DAY);
      }
    }
    return data;
  }
  ///获取时间差的具体时间
  static formatToTime(double time) {
    time = time / Duration.microsecondsPerMillisecond;
    int day = time > Duration.secondsPerDay ? time / Duration.secondsPerDay : 0;
    int hour = (time - day * Duration.secondsPerHour) ~/ Duration.secondsPerHour;
    int minute = (time - day * Duration.secondsPerHour - hour * Duration.secondsPerHour) ~/
        Duration.secondsPerMinute;
    int second = (time -
        day * Duration.microsecondsPerHour -
        hour * Duration.secondsPerHour -
        minute * Duration.secondsPerMinute)
        .toInt();
    return Time(day: day, hour: hour, minute: minute, second: second);
  }

  ///获取彩票时间差的具体时间
  static formatLotteryTime(int time) {
    //计算出天数
    var days = (time/(24*3600*1000)).floor();
    //计算出小时数
    var leave1 = time%(24*3600*1000);   //计算天数后剩余的毫秒数
    var hours = (leave1/(3600*1000)).floor();
    //计算相差分钟数
    var leave2 = leave1%(3600*1000)   ;     //计算小时数后剩余的毫秒数
    var minutes = (leave2/(60*1000)).floor();
    //计算相差秒数
    var leave3 = leave2%(60*1000);      //计算分钟数后剩余的毫秒数
    var seconds = (leave3/1000).floor();
    if (days > 0) {
      hours = days*24 + hours;
    }

    return Time(hour: hours.toInt(), minute: minutes.toInt(), second: seconds);
  }

  ///时间前面补0
  static getTimeInfo(int time) {
    if (time < 10) {
      return '0' + time.toString();
    }
    return time.toString();
  }
  ///获取时间子串
  static getTimeSub(int time,bool first) {
    String timeStr = getTimeInfo(time).trim();
    if(first){
      return timeStr.substring(0,1);
    }else{
      return timeStr.substring(timeStr.length-1,timeStr.length);
    }
  }

  static DateTime getDateTime(String dateStr) {
    if (null == dateStr) {
      return null;
    }
    DateTime dateTime = DateTime.tryParse(dateStr);
    return dateTime;
  }

  static DateTime getDateTimeByMs(int milliseconds, {bool isUtc: false}) {
    if (null == milliseconds) {
      return null;
    }
    DateTime dateTime = new DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: isUtc);
    return dateTime;
  }

  static int getDateMsByTimeStr(String dateStr) {
    if (null == dateStr) return null;
    DateTime dateTime = DateTime.tryParse(dateStr);
    return dateTime == null ? null : dateTime.millisecondsSinceEpoch;
  }

  static int getNowDateMs() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  static String getNowDateStr() {
    return getDateStrByDateTime(DateTime.now());
  }

  static String getDateStrByTimeStr(
      String dateStr, {
        DateFormat format: DateFormat.YEAR_MONTH_DAY_HOUR_MINUTE,
        String dateSeparate,
        String timeSeparate,
      }) {
//    print('__________date: $dateStr');

    var temp = getDateStrByDateTime(getDateTime(dateStr),
        format: format, dateSeparate: dateSeparate, timeSeparate: timeSeparate);


//    print('__________dateTrabsalte: $temp');
    return getDateStrByDateTime(getDateTime(dateStr),
        format: format, dateSeparate: dateSeparate, timeSeparate: timeSeparate);
  }

  static String getDateStrByMs(int milliseconds,
      {DateFormat format: DateFormat.YEAR_MONTH_DAY_HOUR_MINUTE,
        String dateSeparate,
        String timeSeparate,
        bool isUtc: false}) {
    DateTime dateTime = getDateTimeByMs(milliseconds, isUtc: isUtc);
    return getDateStrByDateTime(dateTime,
        format: format, dateSeparate: dateSeparate, timeSeparate: timeSeparate);
  }

  static String getDateStrByDateTime(DateTime dateTime,
      {DateFormat format: DateFormat.YEAR_MONTH_DAY_HOUR_MINUTE,
        String dateSeparate,
        String timeSeparate}) {
    if (dateTime == null) return null;
    String dateStr = dateTime.toString();
    if (isZHFormat(format)) {
      dateStr = formatZHDateTime(dateStr, format, timeSeparate);
    } else {
      dateStr = formatDateTime(dateStr, format, dateSeparate, timeSeparate);
    }
    return dateStr;
  }

  ///格式化中文
  ///time            时间
  ///format          类型
  ///timeSeparate    格式化形式
  static String formatZHDateTime(String time, DateFormat format, String timeSeparate) {
    time = convertToZHDateTimeString(time, timeSeparate);
    switch (format) {
      case DateFormat.ZH_NORMAL: //yyyy年MM月dd日 HH时mm分ss秒
        time = time.substring(
            0,
            "yyyy年MM月dd日 HH时mm分ss秒".length -
                (timeSeparate == null || timeSeparate.isEmpty ? 0 : 1));
        break;
      case DateFormat.ZH_YEAR_MONTH_DAY_HOUR_MINUTE: //yyyy年MM月dd日 HH时mm分
        time = time.substring(0,
            "yyyy年MM月dd日 HH时mm分".length - (timeSeparate == null || timeSeparate.isEmpty ? 0 : 1));
        break;
      case DateFormat.ZH_YEAR_MONTH_DAY: //yyyy年MM月dd日
        time = time.substring(0, "yyyy年MM月dd日".length);
        break;
      case DateFormat.ZH_YEAR_MONTH: //yyyy年MM月
        time = time.substring(0, "yyyy年MM月".length);
        break;
      case DateFormat.ZH_MONTH_DAY: //MM月dd日
        time = time.substring("yyyy年".length, "yyyy年MM月dd日".length);
        break;
      case DateFormat.ZH_MONTH_DAY_HOUR_MINUTE: //MM月dd日 HH时mm分
        time = time.substring("yyyy年".length,
            "yyyy年MM月dd日 HH时mm分".length - (timeSeparate == null || timeSeparate.isEmpty ? 0 : 1));
        break;
      case DateFormat.ZH_HOUR_MINUTE_SECOND: //HH时mm分ss秒
        time = time.substring(
            "yyyy年MM月dd日 ".length,
            "yyyy年MM月dd日 HH时mm分ss秒".length -
                (timeSeparate == null || timeSeparate.isEmpty ? 0 : 1));
        break;
      case DateFormat.ZH_HOUR_MINUTE: //HH时mm分
        time = time.substring("yyyy年MM月dd日 ".length,
            "yyyy年MM月dd日 HH时mm分".length - (timeSeparate == null || timeSeparate.isEmpty ? 0 : 1));
        break;
      default:
        break;
    }
    return time;
  }

  ///格式化时间
  ///time            时间
  ///format          格式化类型
  ///dateSeparate    日期格式
  ///timeSeparate    时间格式
  static String formatDateTime(
      String time, DateFormat format, String dateSeparate, String timeSeparate) {
    switch (format) {
      case DateFormat.NORMAL: //yyyy-MM-dd HH:mm:ss
        time = time.substring(0, "yyyy-MM-dd HH:mm:ss".length);
        break;
      case DateFormat.YEAR_MONTH_DAY_HOUR_MINUTE: //yyyy-MM-dd HH:mm
        time = time.substring(0, "yyyy-MM-dd HH:mm".length);
        break;
      case DateFormat.YEAR_MONTH_DAY: //yyyy-MM-dd
        time = time.substring(0, "yyyy-MM-dd".length);
        break;
      case DateFormat.YEAR_MONTH: //yyyy-MM
        time = time.substring(0, "yyyy-MM".length);
        break;
      case DateFormat.MONTH_DAY: //MM-dd
        time = time.substring("yyyy-".length, "yyyy-MM-dd".length);
        break;
      case DateFormat.MONTH_DAY_HOUR_MINUTE: //MM-dd HH:mm
        time = time.substring("yyyy-".length, "yyyy-MM-dd HH:mm".length);
        break;
      case DateFormat.HOUR_MINUTE_SECOND: //HH:mm:ss
        time = time.substring("yyyy-MM-dd ".length, "yyyy-MM-dd HH:mm:ss".length);
        break;
      case DateFormat.HOUR_MINUTE: //HH:mm
        time = time.substring("yyyy-MM-dd ".length, "yyyy-MM-dd HH:mm".length);
        break;
      default:
        break;
    }
    time = dateTimeSeparate(time, dateSeparate, timeSeparate);
    return time;
  }

  ///是否需要格式化中文
  static bool isZHFormat(DateFormat format) {
    return format == DateFormat.ZH_DEFAULT ||
        format == DateFormat.ZH_NORMAL ||
        format == DateFormat.ZH_YEAR_MONTH_DAY_HOUR_MINUTE ||
        format == DateFormat.ZH_YEAR_MONTH_DAY ||
        format == DateFormat.ZH_YEAR_MONTH ||
        format == DateFormat.ZH_MONTH_DAY ||
        format == DateFormat.ZH_MONTH_DAY_HOUR_MINUTE ||
        format == DateFormat.ZH_HOUR_MINUTE_SECOND ||
        format == DateFormat.ZH_HOUR_MINUTE;
  }

  ///格式化时间x
  static String convertToZHDateTimeString(String time, String timeSeparate) {
    time = time.replaceFirst("-", "年");
    time = time.replaceFirst("-", "月");
    time = time.replaceFirst(" ", "日 ");
    if (timeSeparate == null || timeSeparate.isEmpty) {
      time = time.replaceFirst(":", "时");
      time = time.replaceFirst(":", "分");
//      time = time.replaceFirst("", "秒");
      time = time + "秒";
    } else {
      time = time.replaceAll(":", timeSeparate);
    }
    return time;
  }

  static String dateTimeSeparate(String time, String dateSeparate, String timeSeparate) {
    if (dateSeparate != null) {
      time = time.replaceAll("-", dateSeparate);
    }
    if (timeSeparate != null) {
      time = time.replaceAll(":", timeSeparate);
    }
    return time;
  }

  ///每一天的最早时间
  static DateTime dateDayBegin(DateTime date) {
    if (null == date) return date;

    return DateTime(date.year, date.month, date.day);
  }

  ///每一天的最晚时间
  static DateTime dateDayEnd(DateTime date) {
    if (null == date) return date;
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 0, 0);
  }

  ///比较日期间隔
  static bool isBefore(String startTime, String endTime) {
    try {
      bool b = DateTime.tryParse(startTime).isBefore(DateTime.tryParse(endTime));
      return b;
    } catch (e) {
      return false;
    }
  }

  ///英文时间
  static String getWeekDayByMs(int milliseconds, {bool isUtc: false}) {
    DateTime dateTime = getDateTimeByMs(milliseconds, isUtc: isUtc);
    return getWeekDay(dateTime);
  }

  ///中文时间
  static String getZHWeekDayByMs(int milliseconds, {bool isUtc: false}) {
    DateTime dateTime = getDateTimeByMs(milliseconds, isUtc: isUtc);
    return getZHWeekDay(dateTime);
  }

  ///英文
  static String getWeekDay(DateTime dateTime) {
    if (dateTime == null) return null;
    String weekday;
    switch (dateTime.weekday) {
      case 1:
        weekday = "Monday";
        break;
      case 2:
        weekday = "Tuesday";
        break;
      case 3:
        weekday = "Wednesday";
        break;
      case 4:
        weekday = "Thursday";
        break;
      case 5:
        weekday = "Friday";
        break;
      case 6:
        weekday = "Saturday";
        break;
      case 7:
        weekday = "Sunday";
        break;
      default:
        break;
    }
    return weekday;
  }

  ///中文
  static String getZHWeekDay(DateTime dateTime) {
    if (dateTime == null) return null;
    String weekday;
    switch (dateTime.weekday) {
      case 1:
        weekday = "星期一";
        break;
      case 2:
        weekday = "星期二";
        break;
      case 3:
        weekday = "星期三";
        break;
      case 4:
        weekday = "星期四";
        break;
      case 5:
        weekday = "星期五";
        break;
      case 6:
        weekday = "星期六";
        break;
      case 7:
        weekday = "星期日";
        break;
      default:
        break;
    }
    return weekday;
  }

  ///是否是闰年
  static bool isLeapYearByDateTime(DateTime dateTime) {
    return isLeapYearByYear(dateTime.year);
  }

  ///是否是闰年
  static bool isLeapYearByYear(int year) {
    return year % 4 == 0 && year % 100 != 0 || year % 400 == 0;
  }

  ///是否是昨天.
  static bool isYesterdayByMillis(int millis, int locMillis) {
    return isYesterday(DateTime.fromMillisecondsSinceEpoch(millis),
        DateTime.fromMillisecondsSinceEpoch(locMillis));
  }

  ///是否是昨天.
  static bool isYesterday(DateTime dateTime, DateTime locDateTime) {
    if (yearIsEqual(dateTime, locDateTime)) {
      int spDay = getDayOfYear(locDateTime) - getDayOfYear(dateTime);
      return spDay == 1;
    } else {
      return ((locDateTime.year - dateTime.year == 1) &&
          dateTime.month == 12 &&
          locDateTime.month == 1 &&
          dateTime.day == 31 &&
          locDateTime.day == 1);
    }
  }

  ///在今年的第几天.
  static int getDayOfYearByMillis(int millis) {
    return getDayOfYear(DateTime.fromMillisecondsSinceEpoch(millis));
  }

  ///在今年的第几天.
  static int getDayOfYear(DateTime dateTime) {
    int year = dateTime.year;
    int month = dateTime.month;
    int days = dateTime.day;
    for (int i = 1; i < month; i++) {
      days = days + monthDay[i];
    }
    if (isLeapYearByYear(year) && month > 2) {
      days = days + 1;
    }
    return days;
  }

  ///year is equal.
  ///是否同年.
  static bool yearIsEqualByMillis(int millis, int locMillis) {
    return yearIsEqual(DateTime.fromMillisecondsSinceEpoch(millis),
        DateTime.fromMillisecondsSinceEpoch(locMillis));
  }

  ///year is equal.
  ///是否同年.
  static bool yearIsEqual(DateTime dateTime, DateTime locDateTime) {
    return dateTime.year == locDateTime.year;
  }
  ///几天后的日期MONTH_DAY格式
  static String getAfterTimeStr({int day = 0,DateFormat format = DateFormat.MONTH_DAY}){
    int nowTime = getNowDateMs();
    String dateStr = getDateStrByMs(nowTime+day*24*60*60*1000,format: format);
    return dateStr;
  }
  ///与当前时间差几天
  static int diffDay(String startTime){
    int nowTime = getNowDateMs();
    int diff = nowTime - getDateMsByTimeStr(startTime);
    return (diff/(24*60*60*1000.0)).toInt();
  }


}


///时间实体
class Time {
  final int year;
  final int month;
  final int day;
  final int hour;
  final int minute;
  final int second;

  Time(
      {this.year = 0,
        this.month = 0,
        this.day = 0,
        this.hour = 0,
        this.minute = 0,
        this.second = 0});

//  Time(
//      {this.year = 0,
//        this.month = 0,
//        int day = 0,
//        int hour = 0,
//        this.minute = 0,
//        this.second = 0}){
//
//    if(true){
//      hour = day*24+hour;
//    }
//
//  }

  @override
  String toString() {
    return 'Time{year: $year, month: $month, day: $day, hour: $hour, minute: $minute, second: $second}';
  }
}