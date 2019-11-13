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
  final CameraPosition initialCameraPosition;
  final Function(CameraPosition) onCameraMove;

  const RouteMap ({@required this.route, Key key, this.onMapCreated, this.additionalPolylines, this.myLocationEnabled, this.initialCameraPosition, this.onCameraMove}) : super(key: key);

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

          //Hiking route can be null, if User starts a hike without setting a route before,
          
          return Container(
            child: GoogleMap(
              myLocationEnabled: myLocationEnabled,
              onCameraMove: onCameraMove,
              onMapCreated: onMapCreated,
              initialCameraPosition: initialCameraPosition!=null?initialCameraPosition:CameraPosition(
                target: r!=null?r.location.toLatLng():LatLng(0, 0),
                zoom: 14.0
                //TODO: figure out proper zoom depending on route
              ),
              //draw route onto map
              polylines: Set.from(<Polyline>[
                //actual hiking route drawed ontop of the map
                if (r!=null)
                  Polyline(
                    polylineId: PolylineId("route"),
                    points: r.route.map((p) => p.toLatLng()).toList(),
                    color: Theme.of(context).accentColor,
                    geodesic: true,
                    jointType: JointType.round,
                    endCap: Cap.roundCap,
                    startCap: Cap.roundCap,
                    width: 5
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