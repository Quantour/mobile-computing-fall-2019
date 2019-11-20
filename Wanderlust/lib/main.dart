import 'package:flutter/material.dart';
import 'package:Wanderlust/views/master/master.dart';
import 'package:flutter/services.dart';
import 'style.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //App is only ever in portrait mode, not in landscape mode
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Wanderlust',
      theme: appTheme(),
      home: MasterView(), 
    );
  }
}

