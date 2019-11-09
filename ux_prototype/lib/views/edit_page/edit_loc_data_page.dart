import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:location/location.dart' as Loc;
import '../../data_models/location.dart' as Dat;
import 'package:geolocator/geolocator.dart';


class EditLocInfoPage extends StatefulWidget {
  final List<Dat.Location> prevList;
  final CameraPosition prevCamPos;
  EditLocInfoPage(this.prevList, this.prevCamPos, {Key key}) : super(key: key);

  @override
  _EditLocInfoPageState createState() => _EditLocInfoPageState(prevList, prevCamPos);
}

class _EditLocInfoPageState extends State<EditLocInfoPage> {

  List<Dat.Location> route;
  CameraPosition currentCameraPosition = CameraPosition(target: LatLng(37.555031, 126.988863), zoom: 12);
  GoogleMapController mapController;

  _EditLocInfoPageState(List<Dat.Location> prevList, CameraPosition prevCamPos) {
    route = []..addAll(prevList); //clone
    if (prevCamPos != null)
      currentCameraPosition = prevCamPos;
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

  void _locateDatLoc(Dat.Location loc) {
    try {
      if (mapController!=null)
        mapController.animateCamera(
          CameraUpdate.newLatLng(loc.toLatLng())
        ); 
    }catch(e){}    
  }

  Widget buildGoogleMap(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: currentCameraPosition,
      compassEnabled: true,
      //myLocationButtonEnabled: true,
      myLocationEnabled: true,
      onCameraMove: (campos) => setState(() => currentCameraPosition=campos),
      onMapCreated: (con) {
        mapController=con;
        _locateUser();
      },
      markers: Set.from(<Marker>[
        Marker(
          markerId: MarkerId("currentCameraPosition"),
          position: currentCameraPosition.target,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
        ),
        for (Dat.Location loc in route)
          Marker(
            markerId: MarkerId("currentCameraPosition${loc.hashCode}"),
            position: loc.toLatLng(),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)
          )
      ]),
      polylines: Set.from(<Polyline>[
        Polyline(
          polylineId: PolylineId("RoutePolyLine"),
          points: route.map((p) => p.toLatLng()).toList(),
          color: Theme.of(context).accentColor,
          geodesic: true,
          jointType: JointType.round,
          endCap: Cap.roundCap,
          startCap: Cap.roundCap
        )
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        actions: <Widget>[
          FlatButton(
            onPressed: (){},
            child: Icon(Icons.search),
          )
        ]
      ),*/
      body: buildGoogleMap(context),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          //<----- add current location ---->
          FloatingActionButton(
            heroTag: "FlHeroTagAddPosToRoute",
            onPressed: () {setState(() {
              //add current pos to list
              route.add(Dat.Location(currentCameraPosition.target.latitude, currentCameraPosition.target.longitude));
            });},
            child: Icon(Icons.add_location),
          ),
          Container(width: 15,),
          FloatingActionButton(
            heroTag: "FlHeroTagRemovePosFromRoute",
            onPressed: (){
              if (route.length>0)
                route.removeLast();
              if (route.length>0)
                _locateDatLoc(route.last);
            },
            child: Icon(Icons.location_off),
          ),
          Container(width: 15,),
          FloatingActionButton(
            heroTag: "FlHeroTagLocateUsrPosition",
            onPressed: () => _locateUser(),
            child: Icon(Icons.location_searching),
          )
        ],
      ),

      //<-----OK or dismiss---->
      bottomNavigationBar: Row(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.pop(context, [route,currentCameraPosition]); //pass new route back
              },
              child: Container(
                height: 50,
                color: Colors.green,
                child: Center(
                  child: Text("Save", style: TextStyle(color: Colors.white, fontSize: 22))
                ),
                width: MediaQuery.of(context).size.width/2,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context, [widget.prevList,currentCameraPosition]); //pass old route back
              },
              child: Container(
                color: Colors.red,
                height: 50,
                child: Center(
                  child: Text("Cancel", style: TextStyle(color: Colors.white, fontSize: 22))
                ),
                width: MediaQuery.of(context).size.width/2,
              ),
            )
          ],
        ),
    );
  }
}