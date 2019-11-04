import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ux_prototype/data_models/pin.dart';
import 'package:ux_prototype/data_models/route.dart';

class RouteMap extends StatelessWidget {
  final HikingRoute route;

  const RouteMap ({@required this.route, Key key}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return Container(
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: route.location.toLatLng(),
          zoom: 14.0
          //TODO: figure out proper zoom depending on route
        ),
        polylines: Set.from(<Polyline>[
          //actual hiking route drawed ontop of the map
          Polyline(
            polylineId: PolylineId("route"),
            points: route.route.map((p) => p.toLatLng()).toList(),
            color: Theme.of(context).accentColor,
            geodesic: true,
            jointType: JointType.round,
            endCap: Cap.roundCap,
            startCap: Cap.roundCap
          )
        ]),
        markers: Set.from(<Marker>[
          Marker(
            markerId: MarkerId("route_loc"),
            position: route.location.toLatLng(),
            //custom icon:
            //icon: BitmapDescriptor.fromAssetImage(configuration, assetName)
          ),
        //Add Pins as Markers on the Map
        ])..addAll(
          Pin
            .fromArea(route.location, route.length*4) //fromArea is not implemented yet
            .map((p) => Marker(
              markerId: MarkerId(p.pinID),
              position: p.location.toLatLng(),
              //icon: ... 
            ))
        ),
      ),
    );
  }
}