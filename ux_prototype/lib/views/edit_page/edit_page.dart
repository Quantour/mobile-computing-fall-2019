
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../data_models/route.dart';
import '../../data_models/user.dart';
import '../../data_models/user.dart';


class HikeEditPage extends StatefulWidget {
  final bool isNew;
  final HikingRoute oldroute;

  HikeEditPage({this.oldroute}):isNew=(oldroute==null);

  @override
  _HikeEditPageState createState() => _HikeEditPageState();
}

class _HikeEditPageState extends State<HikeEditPage> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: <Widget>[
          SafeArea(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: FloatingActionButton(
                backgroundColor: Theme.of(context).accentColor.withAlpha(200),
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Icon(Icons.arrow_back),
              )
            ),
          ),
          Builder(
            builder: (c) {
              
              //if user is logged in they can not edit or create a new route
              if (!User.isLoggedIn)
              return Center(
                child: Column(
                  children: <Widget>[
                    Center(
                      child: Icon(Icons.error, size: 20,),
                    ),
                    Container(height: 20,),
                    Center(
                      child: Text("Please log in or register to ${widget.isNew?"create a new route":"edit a route"}!"),
                    )
                  ],
                ),
              );

              //user is logged in
              return Container(
                child: Column(
                  children: <Widget>[



                    
                  ],
                ),
              );

            },
          )
        ].reversed.toList(),
      ),
    );

  }
}