

import 'package:Wanderlust/data_models/location.dart';
import 'package:Wanderlust/data_models/user.dart';
import 'package:flutter/widgets.dart';

/**
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

  Hike({this.routeID, @required this.start, @required this.stop, @required this.actualRoute});

  static Stream<List<Hike>> DEBUGgetCurrentUserHistory() {
    if (!User.isLoggedIn)
      return Stream.error("User must be logged in to view his history");
    return Future.value([
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
    ]).asStream();
  }

}