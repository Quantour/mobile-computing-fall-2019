import 'package:flutter/material.dart';
import 'package:ux_prototype/ui_elements/buttom_navigation.dart';
import 'package:ux_prototype/views/current_hike/current_hike.dart';
import 'package:ux_prototype/views/discover/discover.dart';
import 'package:ux_prototype/views/hike_history/hike_history.dart';
import 'dart:async';

StreamController<int> _pageControllerStream = StreamController();

/**
 * This Screen is the Master screen for the App.
 * It holds the views discover, history and current hike as children
 * in a Stack. Because of that, the views preserve their state, even
 * when there not shown, because they are never removed from the 
 * widget tree.
 * 
 */
class MasterView extends StatefulWidget {
  MasterView({Key key}) : super(key: key);

  @override
  _MasterViewState createState() => _MasterViewState();


  /**
   * Methods to change displayed page from outside this widget
   */
  static const int DISCOVER = 0;
  static const int MY_HIKES = 1;
  static const int CURRENT_HIKE = 2; 
  
  static void navigate(int page) {
    if (page < 0 || page > 2) throw ArgumentError("page must be in Range");
    _pageControllerStream.add(page);
  }
}

class _MasterViewState extends State<MasterView> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _pageControllerStream.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData)
            _index = snapshot.data;
        
        return Scaffold(
          body: Stack(
            children: <Widget>[
              Offstage(
                child: SearchScreenWidget(),
                offstage: _index!=0,
              ),
              Offstage(
                child: HikeHistory(),
                offstage: _index!=1,
              ),
              Offstage(
                child: CurrentHike(),
                offstage: _index!=2,
              ),
            ],
          ),

          bottomNavigationBar: CommonNavBar(
            currentIndex: _index,
            onTap: (index) {
              setState(() {
                _index = index;
                MasterView.navigate(index);
              });
            }
          ),
        );
      },
    );
  }
}