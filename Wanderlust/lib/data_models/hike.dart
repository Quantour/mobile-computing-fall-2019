

import 'package:Wanderlust/data_models/location.dart';
import 'package:Wanderlust/data_models/user.dart';
import 'package:flutter/widgets.dart';

/**
 * Saves one Hike from the User.
 * Either he/she started a route or didnt follow any route.
 * In this case is routeID null
 */
class Hike {

  String routeID;
  DateTime start;
  DateTime stop;
  List<Location> actualRoute;

  Duration get duration => stop.difference(start);

  Hike({this.routeID, @required this.start, @required this.stop, @required this.actualRoute});

  //TODO implemenet stuff here
  static Future<List<Hike>> getUserHistory(String userID) {
    return Future.value([]);
  }

  static Future<List<Hike>> getCurrentUserHistory(String userID) {
    if (!User.isLoggedIn)
      return Future.error("User must be logged in to view his history");
    return getUserHistory(User.currentUser.ID);
  }

}