


import 'package:ux_prototype/data_models/location.dart';
import 'package:ux_prototype/data_models/route.dart';

class ActiveHike {
  //if route is null it means that User started hike without route
  final HikingRoute route;
  final DateTime timestampStart;

  List<Location> actualRoute = [];
  DateTime timestampLastUnpaused;
  Duration totalDurationUntilLastPaused = Duration.zero;
  bool _isPaused=false;
  
  bool get isPaused => _isPaused;
  set isPaused(bool p) {
    if (p==_isPaused) return;
    if (_isPaused) {
      //was paused, now continue
      timestampLastUnpaused = DateTime.now();
    } else {
      //pause now
      totalDurationUntilLastPaused += DateTime.now().difference(timestampLastUnpaused);
    }
    _isPaused = !_isPaused;
  }

  Duration get totalTime {
    Duration dur =  totalDurationUntilLastPaused;
    if (!isPaused) dur += DateTime.now().difference(timestampLastUnpaused);
    return dur;
  }

  ActiveHike(this.route, DateTime timestampStart)
  : this.timestampStart = timestampStart,
    timestampLastUnpaused = timestampStart;
}