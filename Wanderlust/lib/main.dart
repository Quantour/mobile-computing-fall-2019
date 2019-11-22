import 'package:flutter/material.dart';
import 'package:Wanderlust/views/master/master.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'data_models/auth.dart';



void main() => runApp(
  ChangeNotifierProvider<AuthService>(
    child: MyApp(),
    builder: (BuildContext context) {
      return AuthService();
    },
  ),
);

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

