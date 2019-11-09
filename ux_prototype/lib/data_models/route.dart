
import 'package:flutter/cupertino.dart';
import 'package:ux_prototype/data_models/location.dart';


/**
 * This class is a data class which wraps data concerning a hiking route.
 */
class HikingRoute {

  HikingRoute({
    @required this.routeID,
    @required this.userID,
    @required this.title,
    @required this.route,
    @required this.timestamp,
    @required this.description,
    @required this.tipsAndTricks,
    @required this.images,
    @required this.avgRating,
    @required this.avgDifficulty,
    @required this.avgTime,
  });

  //required, final, only editable by Creator while creating data
  final String          routeID;
  final String          userID;
  final String          title;
  final List<Location>  route;
  final int             timestamp; //Unix style timestamp, in milliseconds since 1970/1/1, 0:00 o'clock 


  //optional, changeable, editable by everyone
  final String          description;
  final String          tipsAndTricks;
  final List<String>    images;


  //derived Informartion
  final double          avgRating;
  final double          avgDifficulty;
  final int             avgTime;

  int get length {
    int dist = 0;
    for (int i = 0; i < route.length-1; i++) {
      dist += Location.distance(route[i], route[i+1]);
    }
    return dist;
  }

  //######################################
  //##
  //## calculate with Google Maps API...
  //##
  //######################################

  int get steepness {
    return 0;
  }

  Location get location {
    return Location.average(route);
  } 
  
  String get nearestCity {
    return "Berlin";
  } 
  String get country {
    return "Germany";
  }

  //######################################
  //##
  //## communicate with backend
  //##
  //######################################

  static Future<HikingRoute> fromID(String id) {
    return Future.delayed(
      Duration(seconds: 2),
      () {
        //mockup data
        return HikingRoute(
          avgDifficulty: 2.4,
          avgRating: 1.7,
          avgTime: 30000,
          description: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.",
          images: <String>[
            "https://www.backpacker.com/.image/t_share/MTQ5NTkxODMyNDA4MzY4NjA0/35541767156_8ba52234a0_o.jpg",
            "https://www.outsideonline.com/sites/default/files/styles/full-page/public/2017/09/06/hiking-as-a-workout_h.jpg?itok=DyOuyqZI",
            "https://www.banfflakelouise.com/sites/default/files/styles/l_1600_12x6/public/hiking_sentinel_pass_jake_dyson_2_horizontal.jpg?itok=jsU6BajR",
          ],
          route: <Location>[
            Location(51.220285, 6.792312),
            Location(51.217869, 6.788197),
            Location(51.215642, 6.771117),
            Location(51.212078, 6.779353)
          ],
          routeID: "RouteID",
          timestamp: 76345635743,
          tipsAndTricks: "Dont forget your water bottle!",
          title: "Gwanak",
          userID: "jon",
        );
      }
    );
  }

}



/*
Map<String, HikingRoute> _localMirroredData = Map();

class HikingRoute {

  HikingRoute._(String id): this.routeID = id;

  //required, final, only editable by Creator while creating data
  final String          routeID;
  final String          userID = "0";
  final String          title = "Title";
  final List<Location>  route = <Location>[
    Location(51.220285, 6.792312),
    Location(51.217869, 6.788197),
    Location(51.215642, 6.771117),
    Location(51.212078, 6.779353)
  ];
  final int             timestamp = 1571561662;

  //optional, changeable, editable by everyone
  String get       description => "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."; 
  String get       tipsAndTricks => "Don't forget your water bottle";
  List<String> get images => <String>[
    "https://www.backpacker.com/.image/t_share/MTQ5NTkxODMyNDA4MzY4NjA0/35541767156_8ba52234a0_o.jpg",
    "https://www.outsideonline.com/sites/default/files/styles/full-page/public/2017/09/06/hiking-as-a-workout_h.jpg?itok=DyOuyqZI",
    "https://www.banfflakelouise.com/sites/default/files/styles/l_1600_12x6/public/hiking_sentinel_pass_jake_dyson_2_horizontal.jpg?itok=jsU6BajR",
  ];

  //derived Informartion
  double get avgRating => 2.4;
  double get avgDifficulty => 3.0;
  int get avgTime => 36000;

  int get length {
    int dist = 0;
    for (int i = 0; i < route.length-1; i++) {
      dist += Location.distance(route[i], route[i+1]);
    }
    return dist;
  }

  int get steepness => 0;

  Location get location => Location.average(route);
  
  String get nearestCity => "Berlin";
  String get country     => "Germany";
  

  /*static Future<HikingRoute> fromID(String id) {
    if (_localMirroredData.containsKey(id))
      return Future.delayed(Duration(seconds: 3),()=>_localMirroredData[id]);
    HikingRoute r = HikingRoute._(id);
    _localMirroredData[id] = r;
    return Future.delayed(Duration(seconds: 3),()=>r);
  }*/

  static HikingRoute fromID(String id) {
    if (_localMirroredData.containsKey(id))
      return _localMirroredData[id];
    HikingRoute r = HikingRoute._(id);
    _localMirroredData[id] = r;
    return r;
  }



}

*/