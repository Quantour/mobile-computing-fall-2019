import 'package:Wanderlust/data_models/hike.dart';
import 'package:Wanderlust/data_models/pin.dart';
import 'package:Wanderlust/data_models/user.dart';
import 'package:Wanderlust/views/current_hike/pin_info_overlay.dart';
import 'package:Wanderlust/views/edit_pin/edit_pin.dart';
import 'package:Wanderlust/views/master/master.dart';
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

  static Future<void> stopActiveRoute(BuildContext context) async {
    assert(isActive);

    if (!User.isLoggedIn) {
      bool answer = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text("If you stop this hike while you're not logged in, the hike cannot be saved to the cloud!"),
            actions: <Widget>[
              FlatButton(
                onPressed: ()=>Navigator.pop(context, true),
                child: Text("Stop", style: TextStyle(color: Theme.of(context).accentColor),),
              ),
              FlatButton(
                onPressed: ()=>Navigator.pop(context, false),
                child: Text("Continue", style: TextStyle(color: Theme.of(context).accentColor),),
              )
            ],
          );
        }
      );
      if (answer!=true) {
        return;
      }
    }

    //stop time keeping of active hike
    activeHike.future.timeout(Duration(milliseconds: 500)).then((ah) async {
      ah.isPaused = true;
      updatePosTickerStream = null;

      //save Stuff
      String userID = (await User.currentUser).getID;
      String routeID = ah.route==null?null:ah.route.routeID;
      DateTime start = ah.timestampStart;
      DateTime stop = DateTime.now();
      List<Location> actualRoute = ah.actualRoute;
      Hike.uploadHike(userID, routeID, start, stop, actualRoute);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text("This hike was saved in your hike history!"),
            actions: <Widget>[
              FlatButton(
                onPressed: ()=>Navigator.pop(context),
                child: Text("Ok", style: TextStyle(color: Theme.of(context).accentColor),),
              )
            ],
          );
        }
      );

      //reset all
      activeHike = Completer<ActiveHike>();
      MasterView.resetCurrentHikeWidget();
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
        Pin.deletePin(pin.pinID).then((evt) {
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

  Future<void> _onAddNewPin(BuildContext context) async {
    if (camPos!=null) {
      Location loc = Location(camPos.target.latitude, camPos.target.longitude);
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PinEditPage(locationSuggestion: loc,))
      );
      setState(() {});
    } else {
      Position pos = await Geolocator()
                            .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
                            .timeout(Duration(seconds: 1));
      if (pos==null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text("Error while opening Menu for edit new pin"),
            actions: <Widget>[
              FlatButton(
                onPressed: ()=>Navigator.pop(context),
                child: Text("Ok", style: TextStyle(color: Theme.of(context).accentColor)),
              )
            ],
          )
        );
        return;
      }
      Location loc = Location(pos.latitude, pos.longitude);
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PinEditPage(locationSuggestion: loc,))
      );
      setState(() {});
    }
  }

  void _onStop(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text("Are you sure ou want to stop your hike?"),
          actions: <Widget>[
            FlatButton(
              child: Text("Yes", style: TextStyle(color: Theme.of(context).accentColor)),
              onPressed: (){
                Navigator.pop(context);
                //Stop route now!
                setState(() {
                  //reset mapController and camera position, if next hike is initiated
                  mapController = null;
                  camPos = null;
                  _discardPinInfo();
                  CurrentHike.stopActiveRoute(context);
                });
              },
            ),
            FlatButton(
              child: Text("No", style: TextStyle(color: Theme.of(context).accentColor)),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
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

  Future<bool> _onWillPop() async {
    if (pinInfo.currentPin==null) {
      return true; //you may pop the screen
    } else {
      pinInfo.discard();
      return false; //dont pop the screen
    }
  }

  void _onPinTap(Pin pin) {
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
            initialCameraPositionBuilder: (mapSize) {
              //if the route map is build the first time for a just
              //activted active route, the camera will show
              //the start of the route, otherwise it will be the same
              //camera position as it was before rebuild
              if (camPos!=null ||
               activeHike.route==null ||
               activeHike.route.route==null ||
               activeHike.route.length==0) 
               return camPos;
              
              return CameraPosition(
                target: activeHike.route.route[0].toLatLng(),
                zoom: 14
              );
            },
            
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
                onPressed: ()=>_onAddNewPin(context),
                backgroundColor: Color.fromRGBO(244,81,30,1),
                child: Icon(Icons.add_location),
              ),
              Container(width: 15,),
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
    return WillPopScope(
      onWillPop: _onWillPop,
      child: FutureBuilder(
        future: CurrentHike.activeHike.future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done)
            return buildInactive(context);

          if (!snapshot.hasData)
            return buildWhenError(context);

          return buildActive(context, snapshot.data);
        }
      ),
    );
  }

}
