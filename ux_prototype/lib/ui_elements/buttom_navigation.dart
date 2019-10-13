import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CommonNavBar extends StatelessWidget {
  const CommonNavBar({ Key key, this.currentIndex, this.onTap }) : super(key: key);

  static const int DISCOVER = 0;
  static const int HISTORY = 1;
  static const int CURRENT_HIKE = 2;

  final int currentIndex;
  final Function(int index) onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
       currentIndex: this.currentIndex, // this will be set when a new tab is tapped
       onTap: this.onTap,
       items: [
         BottomNavigationBarItem(
           icon: new Icon(Icons.home),
           title: new Text('Discover'),
         ),
         BottomNavigationBarItem(
           icon: new Icon(Icons.history),
           title: new Text('My Hikes'),
         ),
         
        BottomNavigationBarItem(
          icon: Icon(Icons.directions_walk),
          title: Text('Current Activity')
        )
       ],
     );
  }
}