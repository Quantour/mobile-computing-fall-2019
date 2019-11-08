import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ux_prototype/data_models/route.dart';
import 'package:ux_prototype/ui_elements/route_map.dart';
import 'package:location/location.dart';

class CurrentHike extends StatefulWidget {
  CurrentHike({Key key}) : super(key: key);

  @override
  State<CurrentHike> createState() => _CurrentHikeState();
}

class _CurrentHikeState extends State<CurrentHike> {
  
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('user').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        var location = new Location();
        double currentLatitude = 0; double currentLongitude = 0; double currentAltitude = 0;
        
        location.onLocationChanged().listen((LocationData currentLocation) {

          var latitudebefore = snapshot.data.documents[1].data['latitude'];
          Firestore.instance.collection("user").document(snapshot.data.documents[1].documentID).updateData({'latitude' :  new List.from(latitudebefore)..addAll([currentLocation.latitude])});
          
          var longitudebefore = snapshot.data.documents[1].data['longitude'];
          Firestore.instance.collection("user").document(snapshot.data.documents[1].documentID).updateData({'longitude' :  new List.from(longitudebefore)..addAll([currentLocation.longitude])});

          var altitudebefore = snapshot.data.documents[1].data['altitude'];
          Firestore.instance.collection("user").document(snapshot.data.documents[1].documentID).updateData({'altitude' :  new List.from(altitudebefore)..addAll([currentLocation.altitude])});

          currentLatitude = currentLocation.latitude;
          currentLongitude = currentLocation.longitude;
          currentAltitude = currentLocation.altitude;
        });

        return Scaffold(

            body: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Center(
                  child: CircularProgressIndicator(),
                ),
                RouteMap(
                  route: HikingRoute.fromID("id"),
                )
              ],
            ),
                floatingActionButton: new FloatingActionButton(
                  heroTag: "FloatingActionButton:currentHike",
                onPressed: () {
        //          Firestore.instance.collection("user").document().setData({'username' : "Paul", 'expertise' : 5, 'difficulty' : 9.8, 'region' : "Italy"});
        //          var currentLocation = location.getLocation();
                  Firestore.instance.collection("user").document(snapshot.data.documents[1].documentID).setData({'marker' : currentAltitude });
                },
              ),
        );
        },
      );
  }

}
