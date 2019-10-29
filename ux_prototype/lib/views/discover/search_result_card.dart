

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:ux_prototype/data_models/location.dart';
import 'package:ux_prototype/data_models/pin.dart';
import 'package:ux_prototype/data_models/route.dart';
import 'package:ux_prototype/ui_elements/image_scroller.dart';
import 'package:ux_prototype/ui_elements/profile_picture.dart';
import 'package:ux_prototype/ui_elements/rating.dart';
import 'package:ux_prototype/ui_elements/route_info.dart';
import 'package:ux_prototype/ui_elements/route_map.dart';

import '../../data_models/user.dart';

class SearchResultCardWidget extends StatelessWidget {

  final void Function() onTap;
  final String heroTag;
  final HikingRoute route;

  SearchResultCardWidget({this.onTap, this.heroTag, @required this.route});

  @override
  Widget build(BuildContext context) {
    bool extendView = true;
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
            children: <Widget>[
              //<Image Scroller>
              Container(
                height: MediaQuery.of(context).size.height * 0.2,
                child: ImageScrollerWidget(
                  imageBuilder: () => route.images,
                  heroTag: this.heroTag==null?UniqueKey().toString():this.heroTag,
                )
              ),
              //<Body of route info>
              RouteInfo(route: route, extended: false,)
            ],
          ),
        ),
      ),
    );
  }

}