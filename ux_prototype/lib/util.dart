

import 'dart:math';
import 'package:flutter/cupertino.dart';

Random _randomGen = Random();
String UUID() {
  return DateTime.now().microsecondsSinceEpoch.toString()+"-"+UniqueKey().hashCode.toString()+"-"+UniqueKey().toString()+"-"+_randomGen.nextDouble().toString()+"-"+_randomGen.nextDouble().toString();
}