

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const largeTextSize = 26.0;
const mediumTextSize = 20.0;
const bodyTestSize = 16.0;

const String defaultFontName = "Montserrat";

const largeTextStyle = TextStyle(
  fontFamily: defaultFontName,
  fontWeight: FontWeight.w300,
  color: Colors.black,
  fontSize: largeTextSize
);

const mediumTextStyle = TextStyle(
  fontFamily: defaultFontName,
  fontWeight: FontWeight.w300,
  color: Colors.black,
  fontSize: mediumTextSize
);

const bodyTextStyle = TextStyle(
  fontFamily: defaultFontName,
  fontWeight: FontWeight.w300,
  color: Colors.black,
  fontSize: bodyTestSize
);

ThemeData appTheme() => ThemeData(
  primarySwatch: Colors.brown,
  textTheme: TextTheme(
    body1: bodyTextStyle,
    title: largeTextStyle,
    subtitle: mediumTextStyle
  )
);