import 'package:flutter/material.dart';
import 'package:ux_prototype/ui_elements/buttom_navigation.dart';
import 'package:ux_prototype/views/current_hike/current_hike.dart';
import 'package:ux_prototype/views/discover/discover.dart';
import 'package:ux_prototype/views/hike_history/hike_history.dart';

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
}

class _MasterViewState extends State<MasterView> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
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
          });
        }
      ),
    );
  }
}