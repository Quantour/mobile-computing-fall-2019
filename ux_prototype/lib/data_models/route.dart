
class HikingRoute {

  static Map<String, HikingRoute> _localMirroredData = Map();

  final String id;

  HikingRoute._(String id): this.id = id;

  String get userID => "0";
  List<String> get images => <String>[
    "https://www.backpacker.com/.image/t_share/MTQ5NTkxODMyNDA4MzY4NjA0/35541767156_8ba52234a0_o.jpg",
    "https://www.outsideonline.com/sites/default/files/styles/full-page/public/2017/09/06/hiking-as-a-workout_h.jpg?itok=DyOuyqZI",
    "https://www.banfflakelouise.com/sites/default/files/styles/l_1600_12x6/public/hiking_sentinel_pass_jake_dyson_2_horizontal.jpg?itok=jsU6BajR",
  ];
  String get description => "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."; 

  static HikingRoute fromID(String id) {
    if (_localMirroredData.containsKey(id))
      return _localMirroredData[id];
    HikingRoute r = HikingRoute._(id);
    _localMirroredData[id] = r;
    return r;
  }



}