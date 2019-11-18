import 'package:Wanderlust/data_models/pin.dart';
import 'package:Wanderlust/views/current_hike/pin_info_overlay.dart';
import 'package:Wanderlust/views/edit_pin/edit_pin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:Wanderlust/data_models/location.dart';
import 'package:Wanderlust/data_models/route.dart';
import 'package:Wanderlust/ui_elements/route_map.dart';
import 'dart:async';

import 'package:Wanderlust/util.dart';
import 'package:Wanderlust/views/current_hike/active_hike.dart';

//TODO set this to 40 seconds or so when deug o this section is finished
const RECORD_INTERVAL_ACTUAL_ROUTE = const Duration(seconds: 60);


class CurrentHike extends StatefulWidget {
  CurrentHike({Key key}) : super(key: key);

  static _CurrentHikeState _state;

  @override
  State<CurrentHike> createState() {
    _state = _CurrentHikeState();
    return _state;
  }

  static Completer<ActiveHike> activeHike = Completer();
  static Stream updatePosTickerStream;

  static bool get isActive => activeHike.isCompleted;

  static void setActiveWithRoute(HikingRoute route) {
    assert(!isActive);
    ActiveHike ah = ActiveHike(route, DateTime.now());
    activeHike.complete(ah);
    //Start recording actual route

    updatePosTickerStream = Stream.periodic(RECORD_INTERVAL_ACTUAL_ROUTE)..listen((event) {
      _state.addActualRoutePoint();
    });
  }

  static void setActiveWithoutRoute() => setActiveWithRoute(null);

  static void stopActiveRoute() {
    assert(isActive);
    //stop time keeping of active hike
    activeHike.future.timeout(Duration(milliseconds: 500)).then((ah) {
      ah.isPaused = true;
      updatePosTickerStream = null;

      //save Stuff

      //reset all
      activeHike = Completer<ActiveHike>();
    });
  }

}






class _CurrentHikeState extends State<CurrentHike> {
  
  GoogleMapController mapController;
  CameraPosition camPos;
  //if tappedPin==null then no info will be shown,
  //otherwise an overview for the pin Information will be shown
  PinInfoOverlay pinInfo;

  @override
  void initState() {
    super.initState();
    pinInfo = PinInfoOverlay(
      onDelete: (pin) {
        Pin.deletePin(pin.docID).then((evt) {
          setState(() {
              pinInfo.discard();
            });
        });
      },
      onEdit: (pin) async {
        Pin p = await Navigator.push(context, MaterialPageRoute(
          builder: (context) => PinEditPage(oldPin: pin)
        ));
        return p;
      },
    );
  }

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

  void addActualRoutePoint() async {
    Position pos = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if (!CurrentHike.isActive) return;
    ActiveHike ah = await CurrentHike.activeHike.future;
    if (ah.isPaused) return;
    setState(() {
      ah.actualRoute.add(Location(pos.latitude, pos.longitude));
    });
  }

  void _onStop(BuildContext context) {
    showDialog(
      context: context,
      child: AlertDialog(
        content: Text("Are you sure ou want to stop your hike?"),
        actions: <Widget>[
          FlatButton(
            child: Text("Yes", style: TextStyle(color: Theme.of(context).accentColor)),
            onPressed: (){
              //Stop route now!
              setState(() {
                //reset mapController and camera position, if next hike is initiated
                mapController = null;
                camPos = null;
                _discardPinInfo();
                CurrentHike.stopActiveRoute();
              });
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text("No", style: TextStyle(color: Theme.of(context).accentColor)),
            onPressed: () => Navigator.pop(context),
          )
        ],
      )
    );
  }

  Widget buildInactive(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height*0.25,
            ),
            Center(
              child: Icon(Icons.directions_walk, size: 40, color: Theme.of(context).accentColor,),
            ),
            Container(
              height: 10,
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width*0.7,
                child: Text("Please start a hike in order to see it here.",textAlign: TextAlign.center,)
              ),
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.only(top: 20),
                width: MediaQuery.of(context).size.width*0.7,
                child: Text("You can start a route from the discover page or",textAlign: TextAlign.center,)
              ),
            ),
            Center(
              child: RaisedButton(
                onPressed: () => CurrentHike.setActiveWithoutRoute(),
                color: Theme.of(context).accentColor,
                child: Text("Start hike without route", style: TextStyle(color: Colors.white,)),
              ),
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

  void _discardPinInfo() {
    pinInfo.discard();
  }

  void _onPinTap(Pin pin) {
    //TODO iplement navigator back fetch by user
    pinInfo.show(pin);
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
              if (mapController==null) {
                //initial setting of mapController
                //only then locate User
                mapController=con;
                _locateUser();
              } else mapController=con;
            },
            onPinTap: _onPinTap,
            //if actual route is updated, the map is rebuild
            //so this is neccessary to keep the camera on the
            //same position
            onCameraMove: (camera) {
              camPos = camera;
            },
            initialCameraPosition:
              //if the route map is build the first time for a just
              //activted active route, the camera will show
              //the start of the route, otherwise it will be the same
              //camera position as it was before rebuild
              (camPos!=null ||
               activeHike.route==null ||
               activeHike.route.route==null ||
               activeHike.route.length==0) 
              ? camPos
              : CameraPosition(
                target: activeHike.route.route[0].toLatLng(),
                zoom: 14
              ),
            additionalPolylines: <Polyline>[
              Polyline(
                polylineId: PolylineId("currentHikeActualRoute"),
                endCap: Cap.roundCap,
                geodesic: true,
                jointType: JointType.round,
                color: Color.fromRGBO(244,81,30, 1),
                width: 5,
                points: activeHike.actualRoute.map((l)=>l.toLatLng()).toList()
              )
            ],
          ),
          
          pinInfo,

          if (activeHike.isPaused)
            Container(
              color: Colors.white.withAlpha(150),
              child: Center(
                child: Icon(Icons.pause, size: 100, color: Theme.of(context).accentColor,),
              ),
            )
        ],
      ),

      //<-----Floating Action----->
      floatingActionButton: Column(
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
                return Container(
                  padding: const EdgeInsets.all(5),
                  child: Text("Time elapsed: $hour:$min:$sec")
                );
              }
            )
          ),
          Container(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              FloatingActionButton(
                heroTag: UUID(),
                onPressed: ()=>_onStop(context),
                child: Icon(Icons.stop),
              ),
              Container(width: 15,),
              if (activeHike.isPaused)
                FloatingActionButton(
                  heroTag: UUID(),
                  onPressed: (){setState(() {
                    activeHike.isPaused = false;
                  });},
                  child: Icon(Icons.play_arrow),
                ),
              if (!activeHike.isPaused)
                FloatingActionButton(
                  heroTag: UUID(),
                  onPressed: (){setState(() {
                    activeHike.isPaused = true;
                  });},
                  child: Icon(Icons.pause),
                ),
              Container(width: 15,),
              FloatingActionButton(
                heroTag: UUID(),
                onPressed: activeHike.isPaused?null:(){_locateUser();},
                backgroundColor: activeHike.isPaused?Colors.grey:Theme.of(context).accentColor,
                child: Icon(Icons.location_searching, color: activeHike.isPaused?Colors.black:Colors.white),
              )
            ],
          ),
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
