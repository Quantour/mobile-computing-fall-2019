import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ux_prototype/data_models/pin.dart';
import 'package:ux_prototype/data_models/route.dart';

import '../data_models/route.dart';

class RouteMap extends StatelessWidget {

  final Future<HikingRoute> route;
  final void Function(GoogleMapController) onMapCreated;
  final List<Polyline> additionalPolylines;
  final bool myLocationEnabled;

  const RouteMap ({@required this.route, Key key, this.onMapCreated, this.additionalPolylines, this.myLocationEnabled}) : super(key: key);

  Widget buildWithPins(BuildContext context, List<Pin> pins) {
    return FutureBuilder(
      future: route,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          //Data still loading
          return Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          //future done but with error
          return Container(
            child: Center(
              child: Column(
                children: <Widget>[
                  Center(
                    child: Icon(Icons.error),
                  ),
                  Center(
                    child: Text("Could not load route!"),
                  )
                ],
              )
            ),
          );
        } else {
          //future completed with data!
          HikingRoute r = snapshot.data;


          return Container(
            child: GoogleMap(
              myLocationEnabled: myLocationEnabled,
              onMapCreated: onMapCreated,
              initialCameraPosition: CameraPosition(
                target: r.location.toLatLng(),
                zoom: 14.0
                //TODO: figure out proper zoom depending on route
              ),
              //draw route onto map
              polylines: Set.from(<Polyline>[
                //actual hiking route drawed ontop of the map
                Polyline(
                  polylineId: PolylineId("route"),
                  points: r.route.map((p) => p.toLatLng()).toList(),
                  color: Theme.of(context).accentColor,
                  geodesic: true,
                  jointType: JointType.round,
                  endCap: Cap.roundCap,
                  startCap: Cap.roundCap
                )
              ]..addAll(additionalPolylines==null?[]:additionalPolylines)),
              //draw pins onto map
              markers: ((List<Pin> pins) {
                Set<Marker> markers = Set();

                //add midpoint of current route
                /*markers.add(Marker(
                  markerId: MarkerId("route_loc"),
                  position: r.location.toLatLng(),
                  //icon: BitmapDescriptor.fromAssetImage(configuration, assetName)
                ));*/

                //Add all the pins to Map
                for (Pin pin in pins)
                  markers.add(Marker(
                    markerId: MarkerId("pin${pin.pinID}"),
                    position: pin.location.toLatLng(),
                    //icon: ... 
                  ));

                return markers;
              })(pins)
              
            ),
          );


        }
      },
    );
    
  }


  @override
  Widget build(BuildContext context) {
    
    List<Pin> pins = [];

    //#####################################
    //##
    //TODO Fetch pins for this area, location from route: route.location
    //rewrite Pin.fromArea(Area)
    //#####################################


    return buildWithPins(context, pins);

  }
}