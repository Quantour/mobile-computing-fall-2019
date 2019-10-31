import 'package:flutter/material.dart';
import 'package:ux_prototype/views/discover/discover.dart';
import 'style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wanderlust UI Prototyp',
      theme: appTheme(),
      home: SearchScreenWidget(),
    );
  }
}

