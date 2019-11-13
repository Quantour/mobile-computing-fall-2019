import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CommonNavBar extends StatelessWidget {
  const CommonNavBar({@required this.onTap, Key key, @required this.currentIndex}) : super(key: key);

  /*static const int DISCOVER = 0;
  static const int HISTORY = 1;
  static const int CURRENT_HIKE = 2;*/

  final int currentIndex;
  final void Function(int index) onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
       currentIndex: this.currentIndex, // this will be set when a new tab is tapped
       onTap: this.onTap, /*(int index) {
          if (index == DISCOVER && currentIndex != DISCOVER)
            Navigator.pushNamed(context, "/discover");
          else if (index == HISTORY && currentIndex != HISTORY)
            Navigator.pushNamed(context, "/hike_history");
          else if (index == CURRENT_HIKE && currentIndex != CURRENT_HIKE)
            Navigator.pushNamed(context, "/current_hike");
       },*/
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