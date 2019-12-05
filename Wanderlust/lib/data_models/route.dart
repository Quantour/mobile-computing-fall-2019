
import 'dart:ffi';

import 'package:Wanderlust/google_maps_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:Wanderlust/data_models/location.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/services/base.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as Math;

/*
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
    @required this.ratings,
    @required this.avgRating,
    @required this.avgDifficulty,
    @required this.avgTime,
    @required this.nearestCity,
    @required this.country,
    @required this.steepness
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
  final Map<String,Map> ratings;


  //derived Informartion
  final double          avgRating;
  final double          avgDifficulty;
  final int             avgTime;
  final String          nearestCity;
  final String          country;
  final int             steepness;

  static HikingRoute packInfoToObject(
    String routeID,
    String userID,
    String title,
    List<Location> route,
    int timestamp,
    String description,
    String tipsAndTricks,
    List<String> images,
    double avgRating,
    double avgDifficulty,
    int avgTime,
    String nearestCity,
    String country,
    int steepness,
    Map<String,Map> ratings){
      return HikingRoute._(
      routeID: routeID,
      userID: userID,
      title: title,
      route: route,
      timestamp: timestamp,
      description: description,
      tipsAndTricks: tipsAndTricks,
      images: images,
      ratings: ratings,
      avgRating: avgRating,
      avgDifficulty: avgDifficulty,
      avgTime: avgTime,
      nearestCity: nearestCity,
      country: country,
      steepness: steepness
    );
  }

  int get length {
    int dist = 0;
    for (int i = 0; i < route.length-1; i++) {
      dist += Location.distance(route[i], route[i+1]);
    }
    return dist;
  }

  Location get location {
    return Location.average(route);
  }

  
  //######################################
  //##
  //## calculate derived info from route list
  //##
  //######################################

  static Future<List<String>> _calculateLocationName(Location loc) async {
    String nearestCity = "n/a"; //"n/a" stands for not applicable, if there is no city/country to find
    String country     = "n/a";

    Geocoding geocoding;
    try {
      //try internet first,better accuracy
      geocoding = Geocoder.google(kGoogleMapsApiKey); 
    } catch (e) {
      geocoding = Geocoder.local; 
    }
    Coordinates coordinates = loc.toCoordinates();
    List<Address> addresses = await geocoding.findAddressesFromCoordinates(coordinates);
    if (addresses.length>0) {
      Address address = addresses.first;
      country = address.countryName;
      nearestCity = address.adminArea;
    }
    return [nearestCity,country];
  }

  static Future<double> _calculateAltitude(Location loc) async {
    //Build URL for the Elevation API to fetch the data from
    const String BASE_URL
     = "https://maps.googleapis.com/maps/api/elevation/json?locations=<LAT>,<LON>&key=<KEY>";
    String fetchURL;
    fetchURL = BASE_URL.replaceFirst("<KEY>", kGoogleMapsApiKey);
    fetchURL = fetchURL.replaceFirst("<LAT>", loc.latitude.toString());
    fetchURL = fetchURL.replaceFirst("<LON>", loc.longitude.toString());

    http.Response response = await http.get(fetchURL);
    double elevation;
    try {
      //Structure of response should look like this:
      /*
      {
        "results" : [
            {
              "elevation" : 10.5185432434082,
              "location" : {
                  "lat" : 40.714728,
                  "lng" : -73.998672
              },
              "resolution" : 76.35161590576172
            }
        ],
        "status" : "OK"
      }*/
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      List<dynamic> results = jsonResponse["results"];
      Map<String, dynamic> result = results.first;
      elevation = result["elevation"];
    } catch (e) {
      print("Error while parsing answer from Google Map Elivation API: ${e.toString()}");
    }

    return elevation;
  }

  static Future<int> _calculateSteepness(List<Location> route) async {
    List<double> elevations = [];
    for (Location loc in route) {
      double elevation = await _calculateAltitude(loc);
      if (elevation!=null)
        elevations.add(elevation);
    }

    if (elevations.length<2)
      return 0;

    double max = elevations.fold(elevations[0], Math.max);
    double min = elevations.fold(elevations[0], Math.min);

    double steepness = max-min;
    
    return steepness.floor();
  }

  static Future<int> _calculateAvgTime(List<Location> route) async {
    Location prevLoc = route[0];
    int totalDistance = 0;
    for (Location loc in route) {
      totalDistance = totalDistance + Location.distance(loc, prevLoc);
    }
    return totalDistance; // Assumed the walking speed of 1m/s
  }

  //######################################
  //##
  //## communicate with backend
  //##
  //######################################
  static Future<HikingRoute> fromID(String id) async {

/*
    //Mockup data
    List<Location> route = <Location>[
      Location(50, 6),
      Location(50.01, 6.005),
      Location(50.02, 6.01),
      Location(50.03, 6.005)
    ];
*/

    Firestore.instance.collection("route").document(id).get().then((DocumentSnapshot ds) async {
        if(!ds.exists) return Future.value(null);
        else {

          List<Location> route = [];
          var docRoute = ds["route"];
          for(int j = 0; j < docRoute.length; j++){
            route.add(Location(docRoute[j]['latitude'],docRoute[j]['longitude']));
          }

          List<String> images = [];
          var docImages = ds["images"];
          for(int j = 0; j < docImages.length; j++){
            images.add(docImages[j]);
          }

          //Once you have downloaded the route from the database,
          //you can calculate nearestCity and country properties
          //and the steepness of the route like this:
          List<String> locationName = await _calculateLocationName(Location.average(route));
          String nearestCity = locationName[0];
          String country = locationName[1];
          int avgTime = await _calculateAvgTime(route);
          int steepness = await _calculateSteepness(route);

          return HikingRoute._(
            avgDifficulty: ds['avgDifficulty'],
            avgRating: ds['avgRating'],
            avgTime: avgTime,
            description: ds['description'],
            images: images,
            ratings: ds['ratings'],
            route: route,
            routeID: ds['routeID'],
            timestamp: ds['timestamp'],
            tipsAndTricks: ds['tipsAndTricks'],
            title: ds['title'],
            userID: ds['userID'],
            nearestCity: nearestCity,
            country: country,
            steepness: steepness
          );
        }
    });

    
/*
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
      country: country,
      steepness: steepness
    );
*/
    
  }


  /*This function uploades a Route
  It also creates Id etc. for the route
  and returns a future of the route
  if the route was uploaded,
  otherwise it finished the furure with an error
  */
  static Future<HikingRoute> uploadRoute (
    String userID,
    String title, 
    List<Location> route,
    int timestamp,
    String description,
    String tipsAndTricks,
    List<String> images) async {

    var a = Firestore.instance.collection("route").document(); String docID = a.documentID;
    List<String> locationName = await _calculateLocationName(Location.average(route));
    String nearestCity = locationName[0];
    String country = locationName[1];
    int avgTime = await _calculateAvgTime(route);
    int steepness = await _calculateSteepness(route);

    List modifiedRoute = [];
    for(Location loc in route){
      modifiedRoute.add({'latitude' : loc.latitude, 'longitude' : loc.longitude});
    }
      
    a.setData({
      'avgDifficulty' : 2.5,
      'avgRating' : 2.5,
      'avgTime' : avgTime,
      'routeID' : docID,
      'userID' : userID,
      'title' : title,
      'route' : modifiedRoute,
      'ratings' : {},
      'timestamp' : timestamp,
      'tipsAndTricks' : tipsAndTricks,
      'description' : description,
      'images' : images,
      'nearestCity' : nearestCity,
      'country' : country,
      'steepness' : steepness
      });

    return Future.value(null);
  }


  /*This function updates a Route with new information
    It returns a future of the new route
    if the route was uploaded,
    otherwise it finished the future with an error
    */
    static Future<HikingRoute> updateRoute(
      String routeID,
      String description,
      String tipsAndTricks,
      List<String> images) {
      var a = Firestore.instance.collection("route").document(routeID); 
      a.updateData({'description' : description, 'tipsAndTricks' : tipsAndTricks, 'images' : images });
      return Future.value(null);
  }

  /*This function deletes a route from the cloude
  if successful it completed the future, otheriwse it
  completes the future with an error
  */
  static Future<void> deleteRoute(String id) {
    Firestore.instance.collection("route").document(id).delete();
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