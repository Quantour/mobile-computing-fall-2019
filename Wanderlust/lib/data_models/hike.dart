

import 'package:Wanderlust/data_models/location.dart';
import 'package:Wanderlust/data_models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

/*
 * Saves one Hike from the User.
 * Either he/she started a route or didnt follow any route.
 * In this case is routeID null
 */
class Hike {

  String hikeID;
  String userID;

  String routeID;
  DateTime start;
  DateTime stop;
  List<Location> actualRoute;

  Duration get duration => stop.difference(start);

  Hike({this.hikeID, this.routeID, @required this.start, @required this.stop, @required this.actualRoute});

  static Future<Stream<List<Hike>>> getCurrentUserHistory() async {
    if (!(await User.isLoggedIn))
      return Stream.error("User must be logged in to view his history");
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    List<Hike> curUserHistory = [];
    Firestore.instance.collection("hike").where("userID", isEqualTo: user.uid).snapshots().listen((data) =>
        data.documents.forEach((doc) {
          List<Location> locInfo = [];
          var loc = doc["location"];
          for(int j = 0; j < loc.length; j++){
            locInfo.add(Location(loc[j]['latitude'],loc[j]['longitude']));
          }
          curUserHistory.add(Hike(
            start: doc["start"].toDate(),
            stop: doc["stop"].toDate(),
            hikeID: doc["hikeID"],
            routeID: doc["routeID"],
            actualRoute: locInfo,
          ));
        })
    );
    
    return Future.value(Future.value(curUserHistory).asStream());
  /*
    return Future.value(Future.value([
      Hike(
        start: DateTime.utc(2019,02,20,12),
        stop: DateTime.utc(2019,02,20,13, 34, 12),
        routeID: "ID",
        actualRoute: <Location>[
          Location(50+0.01, 6+0.01),
          Location(50.01+0.01, 6.005+0.01),
          Location(50.02+0.01, 6.01+0.01),
          Location(50.03+0.01, 6.005+0.01)
        ]
      ),
      Hike(
        start: DateTime.utc(2019,02,20,12),
        stop: DateTime.utc(2019,02,20,13, 34, 12),
        routeID: null,
        actualRoute: <Location>[
          Location(50+0.01, 6+0.01),
          Location(50.01+0.01, 6.005+0.01),
          Location(50.02+0.01, 6.01+0.01),
          Location(50.03+0.01, 6.005+0.01)
        ]
      )
    ]).asStream());
  */
  }


  /*
  * uploades a hike with this information
  * Also creates unique hikeID.
  * routeID may be null and when download a hike from the database
  * the null value must be restored. Not something like "null"
  */
  static Future<Hike> uploadHike(
      String userID,
      String routeID,
      DateTime start, 
      DateTime stop, 
      List<Location> actualRoute) async {
    
    var a = Firestore.instance.collection("hike").document();
    String docID = a.documentID;

    List location = [];
    for(Location loc in actualRoute) {
      location.add({'latitude' : loc.latitude, 'longitude' : loc.longitude});
    }

    a.setData({
      'hikeID' : docID,
      'userID' : userID,
      'routeID' : routeID,
      'start' : start,
      'stop' : stop,
      'location' : location
    });

    return Future.value();
  }

  /*
    This deletes a hike from the database and resolves future.
    if this fails it resolves the future with an error
   */
  static Future<void> deleteHike(String hikeID) {
    Firestore.instance.collection('hike').document(hikeID).delete();
    return Future.value();
  }
  
  /* This method is called when a hike is published as a route */
  static Future<void> updateRoute(String hikeID, String routeID) {
    var a = Firestore.instance.collection('hike').document(hikeID);
    a.updateData({'routeID' : routeID});
    return Future.value();
  }

}