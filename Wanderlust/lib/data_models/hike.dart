

import 'package:Wanderlust/data_models/location.dart';
import 'package:Wanderlust/data_models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

/*
 * Saves one Hike from the User.
 * Either he/she started a route or didnt follow any route.
 * In this case is routeID null
 */
class Hike {

  Hike._({
    @required this.hikeID,
    @required this.userID,
    @required this.routeID,
    @required this.start,
    @required this.stop,
    @required this.actualRoute
  });

  final String hikeID;
  final String userID;

  final String routeID;
  final DateTime start;
  final DateTime stop;
  final List<Location> actualRoute;

  static Hike packInfoToObject(
      String hikeID,
      String userID,
      String routeID,
      DateTime start,
      DateTime stop,
      List<Location> actualRoute){
        return Hike._(
        hikeID: hikeID,
        userID: userID,
        routeID: routeID,
        start: start,
        stop: stop,
        actualRoute: actualRoute
    );
  }

  Duration get duration => stop.difference(start);

  static Stream<List<Hike>> DEBUGgetCurrentUserHistory() {
    if (!User.isLoggedIn)
      return Stream.error("User must be logged in to view his history");
  }

  static Future<Hike> fromID(String id) async {
    Firestore.instance.collection("hike").document(id).get().then((
        DocumentSnapshot ds) async {
      if (!ds.exists)
        return Future.value(null);
      else {
        List<Location> route = [];
        var docRoute = ds["hike"];
        for (int j = 0; j < docRoute.length; j++) {
          route.add(
              Location(docRoute[j]['latitude'], docRoute[j]['longitude']));
        }

        return Hike._(
            hikeID: ds['hikeID'],
            userID: ds['userID'],
            routeID: ds['routeID'],
            start: ds['start'],
            stop: ds['stop'],
            actualRoute: route
        );
      }
    });
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

    return Future.value(null);
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