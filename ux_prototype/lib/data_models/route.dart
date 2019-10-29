
import 'package:ux_prototype/data_models/location.dart';

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