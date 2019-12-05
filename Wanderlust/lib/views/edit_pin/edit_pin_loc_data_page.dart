
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:Wanderlust/util.dart';
import '../../data_models/location.dart' as Dat;
import 'package:geolocator/geolocator.dart';


class EditPinLocInfoPage extends StatefulWidget {
  final Dat.Location prevLoc;
  final void Function(Dat.Location) setLoc;
  EditPinLocInfoPage(this.prevLoc, this.setLoc, {Key key}) : super(key: key);

  @override
  _EditPinLocInfoPageState createState() => _EditPinLocInfoPageState(prevLoc);
}

class _EditPinLocInfoPageState extends State<EditPinLocInfoPage> {

  Dat.Location pos;
  CameraPosition currentCameraPosition = CameraPosition(target: LatLng(37.555031, 126.988863), zoom: 12);
  GoogleMapController mapController;
  final bool locateUserOnCreate;

  _EditPinLocInfoPageState(Dat.Location prevLoc) : locateUserOnCreate=(prevLoc==null) {
    pos = prevLoc;
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

  Widget buildGoogleMap(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: currentCameraPosition,
      compassEnabled: true,
      //myLocationButtonEnabled: true,
      myLocationEnabled: true,
      onCameraMove: (campos) => setState(() => currentCameraPosition=campos),
      onMapCreated: (con) {
        mapController=con;
        if (locateUserOnCreate)
          _locateUser();
      },
      markers: Set.from(<Marker>[
        Marker(
          markerId: MarkerId("currentCameraPosition"),
          position: currentCameraPosition.target,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
        ),
        if(this.pos!=null)
          Marker(
            markerId: MarkerId("prevPosMarker"),
            position: pos.toLatLng()
          )
      ])
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildGoogleMap(context),
      floatingActionButton: FloatingActionButton(
            heroTag: UUID(),
            onPressed: () => _locateUser(),
            child: Icon(Icons.location_searching),
      ),

      //<-----OK or dismiss---->
      bottomNavigationBar: Row(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                pos = Dat.Location(currentCameraPosition.target.latitude,currentCameraPosition.target.longitude);
                widget.setLoc(pos);
                Navigator.pop(context); //pass new route back
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
                widget.setLoc(widget.prevLoc);
                Navigator.pop(context); //pass old route back
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