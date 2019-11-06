

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ux_prototype/data_models/route.dart';
import 'package:ux_prototype/ui_elements/image_scroller.dart';
import 'package:ux_prototype/ui_elements/route_info.dart';


class SearchResultCardWidget extends StatelessWidget {

  final void Function() onTap;
  final String heroTag;
  final HikingRoute route;

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget> [
                  //<Image Scroller>
                  Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: ImageScrollerWidget(
                      imageBuilder: () => route.images,
                      heroTag: this.heroTag==null?UniqueKey().toString():this.heroTag,
                    )
                  ),
                  //<Body of route info>
                  RouteInfo(route: route, extended: false,),
                ],
              ),
            ),
          ),
        );
  }
}


