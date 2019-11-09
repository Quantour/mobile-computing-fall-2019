import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ux_prototype/data_models/route.dart';
import 'package:ux_prototype/ui_elements/route_map.dart';
import 'dart:async';

class ActiveHike {
  final HikingRoute route;
  final DateTime timestamp_start;

  DateTime timestamp_last_unpaused;
  Duration total_duration_until_last_paused = Duration.zero;
  bool _isPaused=false;
  
  bool get isPaused => _isPaused;
  set isPaused(bool p) {
    if (p==_isPaused) return;
    if (_isPaused) {
      //was paused, now continue
      timestamp_last_unpaused = DateTime.now();
    } else {
      //pause now
      total_duration_until_last_paused += timestamp_last_unpaused.difference(DateTime.now());
    }
    _isPaused = !_isPaused;
  }

  Duration get totalTime {
    Duration dur =  total_duration_until_last_paused;
    if (!isPaused) total_duration_until_last_paused += timestamp_last_unpaused.difference(DateTime.now());
    return dur;
  }

  ActiveHike(this.route, DateTime timestamp_start)
  : this.timestamp_start = timestamp_start,
    timestamp_last_unpaused = timestamp_start;
}

class CurrentHike extends StatefulWidget {
  CurrentHike({Key key}) : super(key: key);

  @override
  State<CurrentHike> createState() {
    return _CurrentHikeState();
  }

  static Completer<ActiveHike> activeHike = Completer();

  static bool get isActive => activeHike.isCompleted;

  static void setActiveWithRoute(HikingRoute route) {
    ActiveHike ah = ActiveHike(route, DateTime.now());
    activeHike.complete(ah);
  }

}






class _CurrentHikeState extends State<CurrentHike> {
  
  GoogleMapController mapController;

  void _locateUser() {
    Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((pos){
      try {
        if (mapController!=null)
          mapController.animateCamera(
            CameraUpdate.newLatLng(LatLng(pos.latitude, pos.longitude))
          );  
      } catch (e) {}   
    });
  }


  Widget buildInactive(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height*0.34,
            ),
            Center(
              child: Icon(Icons.directions_walk, size: 40, color: Theme.of(context).accentColor,),
            ),
            Container(
              height: 10,
            ),
            Center(
              child: Text("Please start a Hike in order to see it here."),
            )
          ],
        ),
      ),
    );
  }

  Widget buildWhenError(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height*0.34,
            ),
            Center(
              child: Icon(Icons.error, size: 40, color: Theme.of(context).accentColor,),
            ),
            Container(
              height: 10,
            ),
            Center(
              child: Text("An error occured while loading your route!"),
            )
          ],
        ),
      ),
    );
  }

  Widget buildActive(BuildContext context, ActiveHike activeHike) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: CircularProgressIndicator(),
          ),
          RouteMap(
            route: Future.value(activeHike.route),
            myLocationEnabled: true,
            onMapCreated: (con) {
              mapController=con;
            }
          )
        ],
      ),

      //<-----Floating Action----->
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Card(
            child: StreamBuilder(
              stream: Stream.periodic(Duration(milliseconds: 900)),
              builder: (context, snapshot) {
                Duration total = activeHike.totalTime;
                int sec  = total.inSeconds % 60;
                int min = total.inMinutes % 60;
                int hour = total.inHours;
                return Text("Time elapsed: $hour:$min:$sec");
              }
            )
          ),
          FloatingActionButton(
            heroTag: "CurHikeFlHeroTagStop",
            onPressed: () {
              //TODO: Stop hike
            },
            child: Icon(Icons.stop),
          ),
          Container(width: 15,),
          if (activeHike.isPaused)
            FloatingActionButton(
              heroTag: "CurHikeFlHeroResume",
              onPressed: (){activeHike.isPaused = false;},
              child: Icon(Icons.play_arrow),
            ),
          if (!activeHike.isPaused)
            FloatingActionButton(
              heroTag: "CurHikeFlHeroPause",
              onPressed: (){activeHike.isPaused = true;},
              child: Icon(Icons.pause),
            ),
          Container(width: 15,),
          FloatingActionButton(
            heroTag: "CurHikeFlHeroTagLocateUsrPosition",
            onPressed: () => _locateUser(),
            child: Icon(Icons.location_searching),
          )
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: CurrentHike.activeHike.future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done)
          return buildInactive(context);

        if (!snapshot.hasData)
          return buildWhenError(context);

        return buildActive(context, snapshot.data);
      }
    );

  }

}
