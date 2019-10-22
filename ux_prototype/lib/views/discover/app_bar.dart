
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ux_prototype/views/discover/search_text_input.dart';

class DiscoverAppBar extends StatefulWidget {
  final SearchTextInputFieldController controller;

  DiscoverAppBar({this.controller});

  @override
  State<StatefulWidget> createState() {
    return _DiscoverAppBarState();
  }
}

class _DiscoverAppBarState extends State<DiscoverAppBar> {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      elevation: 0,   //no shadow
      floating: true, //App bar floats ontop body of scaffold
      snap: true,     //is shown fully or hidden fully
      automaticallyImplyLeading: false,
      
      //elliptical background
      flexibleSpace: Card(
        margin: EdgeInsets.all(0),
        elevation: 0,
        child: Container(
          decoration: new BoxDecoration(
            //color: Theme.of(context).accentColor,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomLeft,
              stops: [0,0.5, 0.7],
              colors: [
                Color.fromRGBO(188,91,60,1),
                Color.fromRGBO(148,84,62,1),
                Color.fromRGBO(109,76,65,1)
              ]
            ),
            boxShadow: [
              new BoxShadow(blurRadius: 25.0)
            ],
            borderRadius: new BorderRadius.vertical(
                bottom: new Radius.elliptical(
                    MediaQuery.of(context).size.width, 12.0)),
          ),
          height: kToolbarHeight+kTextTabBarHeight,
        ),
      ),
      backgroundColor: Colors.transparent, //background is handled by elliptical Form

      //Title
      centerTitle: true,
      title: Text(
        "Wanderlust",
        style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w600,color: Colors.white)
      ),

      //Container for actual search bar
      bottom: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Container(
          child: SearchTextInputFieldWidget(
            controller: widget.controller
          ),
          margin: EdgeInsets.only(bottom: 5),
        ),
      ),
    );
  }
}
