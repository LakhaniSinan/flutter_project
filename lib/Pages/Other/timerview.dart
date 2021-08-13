
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:intl/intl.dart';

class TimerView extends StatefulWidget {
  final DateTime dateTime;
  final double fontSize;
  final Color color;

  const TimerView({
    Key key,
    this.dateTime,
    this.fontSize = 14,
    this.color,
  }) : super(key: key);

  @override
  _TimerViewState createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  var timerCountDown = '00:00:00';
  Color colors = Colors.red;
  DateTime dateCheck;
  Timer timer;
  DateTime dateTimeStart;

  @override
  void initState() {
    if (widget.dateTime == null) {
      dateTimeStart = DateTime.now();
    } else {
      dateTimeStart = widget.dateTime;
    }
    if (widget.color != null) {
      colors = widget.color;
    }
    print('${widget.dateTime}');
    print('${dateTimeStart}');
    dateCheck =
        DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTimeStart.toString());
    print('${dateCheck}');
    setTime();
    super.initState();
  }

  void setTime() {
    if (dateCheck.difference(DateTime.now()).inSeconds < 0) {
      colors = kRedColor;
      setState(() {
        timerCountDown = 'Deal ends in - '+getData(dateTimeStart.millisecondsSinceEpoch);
      });
    } else {
      if (dateCheck.difference(DateTime.now()).inHours < 24) {
        colors = kRedColor;
        timer?.cancel();
        timer = new Timer(new Duration(seconds: 1), () {
          setJustTime();
          setTime();
        });
      } else {
        final date = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTimeStart.toString());
        final today = DateFormat('yyyy-MM-dd HH:mm:ss').parse(DateTime.now().toString());
        if (date.difference(today).inDays == 1) {
          colors = Colors.yellow;
          timerCountDown = 'Deal ends Tomorrow';
        } else {
          if (!mounted) return;
          setState(() {
            colors = kMainColor;
            timerCountDown = 'Deal ends at - '+DateFormat.E().format(date) +
                ', ' +
                DateFormat.d().format(date) +
                ' ' +
                DateFormat.MMM().format(date) +
                ' ' +
            DateFormat.Hms().format(date);
          });
        }
      }
    }
  }

  void setJustTime() {
    final seconds = dateCheck.difference(DateTime.now()).inSeconds;
    if (!mounted) return;
    setState(() {
      timerCountDown = 'Deal ends in - '+secondsToHoursMinutesSeconds(seconds);
    });
  }

  String getData(int seconds) {
    var messageDate = new DateTime.fromMillisecondsSinceEpoch(seconds);
    var formatter = new DateFormat('yyyy-MM-dd');
    String formatted = formatter.format(messageDate);
    var finalDate = DateTime.parse(formatted);
    var days = DateTime.now().difference(finalDate).inDays;
    if (days == 0) {
      if (DateTime.now().difference(messageDate).inHours > 0) {
        colors = Colors.black54;
        return '${DateTime.now().difference(messageDate).inHours} hours ago.';
      } else if (DateTime.now().difference(messageDate).inMinutes > 0) {
        return '${DateTime.now().difference(messageDate).inMinutes} minutes ago.';
      } else {
        return 'Few seconds ago.';
      }
    } else if (days == 1) {
      colors = Colors.red;
      return 'Yesterday ${DateFormat.jm().format(messageDate)}';
    } else if (days >= 2 && days <= 6) {
      return DateFormat.EEEE().format(messageDate) +
          " " +
          DateFormat.jm().format(messageDate);
    } else {
      return DateFormat.yMd().add_jm().format(messageDate);
    }
  }

  String secondsToHoursMinutesSeconds(int seconds) {
    var hour = seconds ~/ 3600;
    var minute = (seconds % 3600) ~/ 60;
    var second = (seconds % 3600) % 60;
    final hourUpdate = hour < 10 ? '0$hour' : '$hour';
    final minuteUpdate = minute < 10 ? '0$minute' : '$minute';
    final secondUpdate = second < 10 ? '0$second' : '$second';
    return hourUpdate + ' : ' + minuteUpdate + ' : ' + secondUpdate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: <Widget>[
          Text(
            timerCountDown,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight: FontWeight.bold,
              color: colors,
            ),
          ),
        ]));
  }
}