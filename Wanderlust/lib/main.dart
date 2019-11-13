import 'package:flutter/material.dart';
import 'package:Wanderlust/views/master/master.dart';
import 'style.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wanderlust',
      theme: appTheme(),
      home: MasterView(), 
    );
  }
}

