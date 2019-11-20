
import 'package:flutter/cupertino.dart';
import 'package:Wanderlust/data_models/location.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/services/base.dart';


/**
 * This class is a data class which wraps data concerning a hiking route.
 */
class HikingRoute {

  HikingRoute._({
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
    @required this.nearestCity,
    @required this.country
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
  final String          nearestCity;
  final String          country;

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



  //######################################
  //##
  //## communicate with backend
  //##
  //######################################
  static Future<HikingRoute> fromID(String id) async {
    //TODO: implement fromID for HikingRoute
    //! Do read the code/comments which calculate the nearestCity
    //and country parameters!

    //Mockup data
    List<Location> route = <Location>[
      Location(50, 6),
      Location(50.01, 6.005),
      Location(50.02, 6.01),
      Location(50.03, 6.005)
    ];

    //Once you have downloaded the route from the database,
    //you can calculate nearestCity and countryproperties
    //like this:
    String nearestCity = "n/a"; //"n/a" stands for non applicable, if there is no city/country to find
    String country     = "n/a";

    Geocoding geocoding = Geocoder.local;
    Coordinates coordinates = Location.average(route).toCoordinates();
    List<Address> addresses = await geocoding.findAddressesFromCoordinates(coordinates);
    if (addresses.length>0) {
      Address address = addresses.first;
      country = address.countryName;
      nearestCity = address.adminArea;
    }

    //return Hiking route with calculated city/country information

    return HikingRoute._(
      avgDifficulty: 2.4,
      avgRating: 1.7,
      avgTime: 30000,
      description: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.",
      images: <String>[
        "https://www.backpacker.com/.image/t_share/MTQ5NTkxODMyNDA4MzY4NjA0/35541767156_8ba52234a0_o.jpg",
        "https://www.outsideonline.com/sites/default/files/styles/full-page/public/2017/09/06/hiking-as-a-workout_h.jpg?itok=DyOuyqZI",
        "https://www.banfflakelouise.com/sites/default/files/styles/l_1600_12x6/public/hiking_sentinel_pass_jake_dyson_2_horizontal.jpg?itok=jsU6BajR",
      ],
      route: route,
      routeID: "RouteID",
      timestamp: 76345635743,
      tipsAndTricks: "Dont forget your water bottle!",
      title: "Gwanak",
      userID: "jon",
      nearestCity: nearestCity,
      country: country
    );
  }


/*This function uploades a Route
  It also creates Id etc. for the route
  and returns a future of the route
  if the route was uploaded,
  otherwise it finished the furure with an error
  */
  static Future<HikingRoute> uploadRoute(
    String userID,
    String title, 
    List<Location> route,
    int timestamp,
    String description,
    String tipsAndTricks,
    List<String> images) {
      //TODO: implenet upload route to the cloud!
    return Future.value(null);
  }


  /*This function updates a Route with new informarion
    It returns a future of the new route
    if the route was uploaded,
    otherwise it finished the furure with an error
    */
    static Future<HikingRoute> updateRoute(
      String routeID,
      String description,
      String tipsAndTricks,
      List<String> images) {
        //TODO: implement updateRoute to cloud
      return Future.value(null);
  }

  /*This function deletes a route from the cloude
  if successful it completed the future, otheriwse it
  completes the future with an error
  */
  static Future<void> deleteRoute(String id) {
    //TODO: implement deleteRoute
    return Future.value();
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