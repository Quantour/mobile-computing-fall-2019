import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:Wanderlust/data_models/pin.dart';
import 'package:Wanderlust/data_models/route.dart';
import 'package:Wanderlust/data_models/location.dart';

import '../data_models/route.dart';

class RouteMap extends StatelessWidget {

  final Future<HikingRoute> route;
  final void Function(GoogleMapController) onMapCreated;
  final List<Polyline> additionalPolylines;
  final bool myLocationEnabled;
  final CameraPosition initialCameraPosition;
  final Function(CameraPosition) onCameraMove;
  final Function(Pin) onPinTap;

  const RouteMap ({
    @required this.route, 
    Key key, 
    this.onMapCreated, 
    this.additionalPolylines, 
    this.myLocationEnabled, 
    this.initialCameraPosition, 
    this.onCameraMove,
    this.onPinTap  
  }) : super(key: key);

  static final Map<int, BitmapDescriptor> defaultIcons = {
    PinType.fountain.index:     BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    PinType.picturePoint.index: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    PinType.restaurant.index:   BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
    PinType.restingPlace.index: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    PinType.restroom.index:     BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
    (-1):                       BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
  };



  Widget buildWithPins(BuildContext context, List<Pin> pins, Map<int, BitmapDescriptor> pinIcons) {
    FutureBuilder<HikingRoute> futureBuilder = FutureBuilder<HikingRoute>(
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
                List<Marker> markers = <Marker>[];

                //Add all the pins to Map
                for (Pin pin in pins) {
                  BitmapDescriptor image = pinIcons[-1];
                  if (pin.types.length==1)
                    image = pinIcons[pin.types.last.index];
                  
                  if (pin.types.length>0)
                    markers.add(Marker(
                      markerId: MarkerId("pin${pin.pinID}"),
                      position: pin.location.toLatLng(),
                      icon: image,
                      onTap: onPinTap==null?(){}:()=>onPinTap(pin)
                    ));

                }
                
                return markers.toSet();
              })(pins)
              
            ),
          );


        }
      },
    );
    return futureBuilder;
    
  }

  Future<List<Pin>> getPins() async {
      List<Pin> pins = [];
      QuerySnapshot querySnapshot = await Firestore.instance.collection("pin").getDocuments();
      var list = querySnapshot.documents;
      for(int i=0;i<list.length;i++){
        var doc = list[i];
        pins.add(new Pin(doc.data['pinID'],new Location(doc.data['latitude'],doc.data['longitude']), doc.data['images'],doc.data['typeno']));
      }
      return pins;
  }

  @override
  Widget build(BuildContext context) {

    //load images for pins async from local file system as asset images
    return FutureBuilder<Map<int, BitmapDescriptor>>(
      future: Pin.loadPinBitmapDescriptor(context),
      builder: (context, snapshot) {
        Map<int, BitmapDescriptor> pinIcons;
        if (snapshot.hasData)
          pinIcons = snapshot.data;
        else
          pinIcons = defaultIcons;

        //load pins async from server
        return FutureBuilder<List<Pin>>(
          future: getPins(),
          builder: (context, snapshot) {
            if (snapshot.hasData)
              return buildWithPins(context, snapshot.data, pinIcons);
            else
              return buildWithPins(context, [], pinIcons);
          },
        );
      }
    );
   
  }
}