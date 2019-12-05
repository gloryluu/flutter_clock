// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:digital_clock/stripe_clipper.dart';

enum _Element {
  background,
  text,
  shadow,
}

final _lightTheme = {
  _Element.background: Color(0xFF81B3FE),
  _Element.text: Colors.white,
  _Element.shadow: Colors.black,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.white,
  _Element.shadow: Color(0xFF174EA6),
};

/// A basic digital clock.
///
/// You can do better than this!
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.
      // _timer = Timer(
      //   Duration(minutes: 1) -
      //       Duration(seconds: _dateTime.second) -
      //       Duration(milliseconds: _dateTime.millisecond),
      //   _updateTime,
      // );
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final second = DateFormat('ss').format(_dateTime);
    final dayOfWeek = DateFormat('EEE').format(_dateTime);
    final date = DateFormat('dd').format(_dateTime);
    final month = DateFormat('MMM').format(_dateTime);
    final fontSize = MediaQuery.of(context).size.width / 4.5;

    final defaultStyle = TextStyle(
      color: colors[_Element.text],
      // fontFamily: 'PressStart2P',
      fontSize: fontSize,
    );

    final smallStyle = TextStyle(
      color: colors[_Element.text],
      // fontFamily: 'PressStart2P',
      fontSize: 18.0,
    );

    return Container(
      // color: colors[_Element.background],
      child: Center(
        child: DefaultTextStyle(
          style: defaultStyle,
          child: Stack(
            children: <Widget>[
              StripsWidget(
                color1: Color.fromRGBO(231, 79, 36, 1),
                color2: Color.fromRGBO(218, 59, 32, 1),
                gap: 100,
                noOfStrips: 10,
              ),
              Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _headerWidget(smallStyle),
                      _dateWidget('$dayOfWeek $month $date', smallStyle),
                      _timeWidget('$hour:$minute:$second', defaultStyle),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: _locationWidget(
                            '${widget.model.location}', smallStyle),
                      ),
                      _musicWidget('ME • Taylor Swift', smallStyle),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textIconWidget(IconData iconData, String text, TextStyle style) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    return Row(children: <Widget>[
      Icon(
        iconData,
        color: colors[_Element.text],
      ),
      SizedBox(
        width: 8.0,
      ),
      Text(
        text,
        style: style,
      ),
    ]);
  }

  Widget _headerWidget(TextStyle style) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4.0),
          child: _weatherWidget(style),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 4.0),
          child: _alarmWidget(style),
        ),
      ],
    );
  }

  Widget _weatherWidget(TextStyle style) {
    return _textIconWidget(FontAwesomeIcons.cloud, 'Cloudy 26˚C', style);
  }

  Widget _alarmWidget(TextStyle style) =>
      _textIconWidget(FontAwesomeIcons.clock, '6:20', style);

  Widget _musicWidget(String title, TextStyle style) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _textIconWidget(FontAwesomeIcons.music, title, style),
        ],
      );

  Widget _dateWidget(String date, TextStyle style) => Text(
        '$date',
        style: style,
      );

  Widget _timeWidget(String time, TextStyle style) {
    return Text(
      '$time',
      style: style,
    );
  }

  Widget _locationWidget(String location, TextStyle style) => Text(
        '$location',
        style: style,
      );
}
