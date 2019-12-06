// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

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
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      // _timer = Timer(
      //   Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
      //   _updateTime,
      // );
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
    final dayOfWeek = DateFormat('EEE').format(_dateTime);
    final date = DateFormat('dd').format(_dateTime);
    final month = DateFormat('MMM').format(_dateTime);
    final fontSize = MediaQuery.of(context).size.width / 28;
    final smallFontSize = MediaQuery.of(context).size.width / 38;
    final bigFontSize = MediaQuery.of(context).size.width / 4.5;

    final defaultStyle = TextStyle(
      color: colors[_Element.text],
      // fontFamily: 'PressStart2P',
      fontSize: fontSize,
    );

    final smallStyle = TextStyle(
      color: colors[_Element.text],
      // fontFamily: 'PressStart2P',
      fontSize: smallFontSize,
    );

    final boldStyle = TextStyle(
        color: colors[_Element.text],
        // fontFamily: 'PressStart2P',
        fontSize: bigFontSize,
        fontWeight: FontWeight.bold);

    return Container(
      // color: colors[_Element.background],
      child: Center(
        child: DefaultTextStyle(
          style: defaultStyle,
          child: Stack(
            children: <Widget>[
              Positioned(
                left: 0,
                right: 0,
                child: Image(
                    image: AssetImage('assets/images/geometric.png'),
                    fit: BoxFit.fill),
              ),
              Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _headerWidget(
                        widget.model.weatherCondition,
                        widget.model.temperatureString,
                        smallStyle,
                      ),
                      _dateWidget('$dayOfWeek, $month $date'),
                      _timeWidget('$hour:$minute', boldStyle),
                      _locationWidget('${widget.model.location}', smallStyle)
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

  Widget _headerWidget(
      WeatherCondition condition, String temperature, TextStyle style) {
    String _weatherCondition = _weatherConditionText(condition);
    IconData _weatherIconData = _weatherConditionIcon(condition);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4.0),
          child: _weatherWidget(
              _weatherIconData, '$_weatherCondition $temperature', style),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 4.0),
          child: _alarmWidget(style),
        ),
      ],
    );
  }

  IconData _weatherConditionIcon(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.snowy:
        return FontAwesomeIcons.snowflake;
        break;
      case WeatherCondition.foggy:
        return FontAwesomeIcons.cloud;
        break;
      case WeatherCondition.windy:
        return FontAwesomeIcons.wind;
        break;
      case WeatherCondition.rainy:
        return FontAwesomeIcons.cloudRain;
        break;
      case WeatherCondition.sunny:
        return FontAwesomeIcons.sun;
        break;
      case WeatherCondition.thunderstorm:
        return FontAwesomeIcons.cloudRain;
        break;
      default:
        return FontAwesomeIcons.cloud;
    }
  }

  String _weatherConditionText(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.snowy:
        return 'Snowy';
        break;
      case WeatherCondition.foggy:
        return 'Cloud';
        break;
      case WeatherCondition.windy:
        return 'Windy';
        break;
      case WeatherCondition.rainy:
        return 'Cloud Rain';
        break;
      case WeatherCondition.sunny:
        return 'Sunny';
        break;
      case WeatherCondition.thunderstorm:
        return 'Thunderstorm';
        break;
      default:
        return 'Cloud';
    }
  }

  Widget _weatherWidget(IconData iconData, String text, TextStyle style) {
    return _textIconWidget(iconData, text, style);
  }

  Widget _alarmWidget(TextStyle style) =>
      _textIconWidget(FontAwesomeIcons.clock, '6:20', style);

  Widget _dateWidget(String date) => Text('$date');

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
