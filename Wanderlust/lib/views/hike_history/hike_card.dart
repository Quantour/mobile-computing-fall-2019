import 'package:Wanderlust/data_models/hike.dart';
import 'package:Wanderlust/data_models/location.dart';
import 'package:Wanderlust/data_models/route.dart';
import 'package:Wanderlust/ui_elements/route_map.dart';
import 'package:Wanderlust/views/discover_detail/discover_detail.dart';
import 'package:Wanderlust/views/edit_page/edit_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HikeCard extends StatefulWidget {
  HikeCard({Key key,@required this.hike}) : super(key: key);

  final Hike hike;

  @override
  _HikeCardState createState() => _HikeCardState();
}

class _HikeCardState extends State<HikeCard> {

  @override
  Widget build(BuildContext context) {
    return Container(
       padding: EdgeInsets.fromLTRB(10.0, 3.0, 10.0, 3.0),
       child: Card(
         clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5.0,
          margin: const EdgeInsets.all(10),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[

                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    
                    //<---- Timestamp ----->
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Icon(Icons.calendar_today),
                        Container(width: 5,),
                        Text("${widget.hike.start.month}/${widget.hike.start.day}/${widget.hike.start.year}")
                      ],
                    ),


                    //<---- Duration ----->
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Icon(Icons.timer),
                        Container(width: 5,),
                        Builder(
                          builder: (context) {
                            Duration diff = widget.hike.duration;
                            int hours = diff.inHours;
                            Duration secDiff = diff - Duration(hours: hours);
                            int minutes = secDiff.inMinutes;
                            String txt = "${minutes}min";
                            if (hours > 0)
                              txt = "${hours}h $txt";
                            return Text(txt);
                          },
                        )
                      ],
                    ),


                  ],
                ),
                
                
                Container(height: 10),

                //<---- Map of route -----> 
                Container(
                  padding: const EdgeInsets.only(top: 15, bottom: 15),
                  height: MediaQuery.of(context).size.width*0.7,
                  child: RouteMap(
                    route: widget.hike.routeID==null?Future.value(null):HikingRoute.fromID(widget.hike.routeID),
                    myLocationEnabled: false,
                    initialCameraPosition: CameraPosition(
                      target: Location.average(widget.hike.actualRoute).toLatLng(),
                      //Todo: figure out proper zoom
                      zoom: 12
                    ),
                    additionalPolylines: <Polyline>[
                      Polyline(
                        polylineId: PolylineId("actualRouteFromHistory"),
                        endCap: Cap.roundCap,
                        geodesic: true,
                        jointType: JointType.round,
                        color: Color.fromRGBO(244,81,30, 1),
                        width: 5,
                        points: widget.hike.actualRoute.map((l)=>l.toLatLng()).toList()
                      )
                    ],
                  ),
                ),              

                //<---- See more / less details button -----> 
                Center(
                  child: GestureDetector(
                    onTap: () {
                      if (widget.hike.routeID!=null) {
                        
                        //open detail page to this route!
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DiscoverDetail(
                              route: HikingRoute.fromID(widget.hike.routeID),
                              heroTag: "${widget.hike.routeID} Detail page from history"
                            ),
                          ),
                        );

                      } else {

                        //save thiis route and share with other people
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HikeEditPage(routeSuggestion: widget.hike.actualRoute)),
                        );
                        //TODO save the uploaded route in this hike

                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Color.fromRGBO(244,81,30,1)),
                        borderRadius: widget.hike.routeID==null?BorderRadius.circular(26):BorderRadius.circular(13)
                      ),
                      height: widget.hike.routeID==null?(52):26,
                      width: MediaQuery.of(context).size.width*0.6,
                      child: Center(
                        child: Builder(
                          builder: (context) {
                            String txt;
                            if (widget.hike.routeID==null)
                              txt = "Share this route\nwith other people!";
                            else
                              txt = "Show details to this route";
                            return Text(txt, 
                              style: TextStyle(color: Color.fromRGBO(244,81,30,1)),
                              textAlign: TextAlign.center,
                            );
                          }
                        )
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
       ),
    );
  }

}