import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ux_prototype/ui_elements/buttom_navigation.dart';

class CurrentHike extends StatefulWidget {
  CurrentHike({Key key}) : super(key: key);

  @override
  State<CurrentHike> createState() {
    return _CurrentHikeState();
  }
}

class _CurrentHikeState extends State<CurrentHike> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: CircularProgressIndicator(),
          ),
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(45.521563, -122.677433),
              zoom: 11.0
            ),

          )
        ],
      ),
      
      bottomNavigationBar: CommonNavBar(
        currentIndex: CommonNavBar.CURRENT_HIKE,
        onTap: (int index) {
          if (index == CommonNavBar.DISCOVER) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

}

