

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ux_prototype/data_models/route.dart';
import 'package:ux_prototype/ui_elements/image_scroller.dart';
import 'package:ux_prototype/ui_elements/route_info.dart';
import 'package:ux_prototype/util.dart';

import '../../data_models/route.dart';


class SearchResultCardWidget extends StatelessWidget {

  final void Function() onTap;
  final String heroTag;
  final Future<HikingRoute> route;

  SearchResultCardWidget({this.onTap, this.heroTag, @required this.route});

  @override
  Widget build(BuildContext context) {
    return InkWell(
          onTap: this.onTap!=null?this.onTap:(){},
          child: Container(
            padding: EdgeInsets.fromLTRB(10.0, 3.0, 10.0, 3.0),
            child: Card(
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 5.0,
              child: FutureBuilder<HikingRoute>(
                future: route,
                builder: (context, snapshot) {

                  //RouteInfo widgets shows appropiate loading/error message
                  if (snapshot.connectionState != ConnectionState.done
                     || snapshot.hasError)
                  return RouteInfo(route: route, extended: false);

                  //this is returned when future is completed with data and no error
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget> [


                      //<Image Scroller>
                      Container(
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: ImageScrollerWidget(
                          imageBuilder: () => snapshot.data.images,
                          heroTag: this.heroTag==null?UUID():this.heroTag,
                        )
                      ),
                      //<Body of route info>
                      RouteInfo(route: route, extended: false,),

                      
                    ],
                  );
                }
              ),
            ),
          ),
        );
  }
}


