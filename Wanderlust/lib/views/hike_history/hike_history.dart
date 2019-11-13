import 'package:flutter/material.dart';

class HikeHistory extends StatefulWidget {
  HikeHistory({Key key}) : super(key: key);

  @override _HikeHistoryState createState() => _HikeHistoryState();
}

class _HikeHistoryState extends State<HikeHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hike History"),
      ),

      body: Container(
        color: Colors.lightBlue,
      ),

      

    );
  }
}