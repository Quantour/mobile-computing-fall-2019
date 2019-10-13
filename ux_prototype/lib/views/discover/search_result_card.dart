

import 'package:flutter/material.dart';
import 'package:ux_prototype/data_models/route.dart';
import 'package:ux_prototype/ui_elements/image_scroller.dart';

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
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.2,
                child: ImageScrollerWidget(
                  imageBuilder: () => route.images,
                  heroTag: this.heroTag==null?UniqueKey().toString():this.heroTag,
                )
              ),
              Text("near Seoul", style: Theme.of(context).textTheme.title),
              Text("Hallo Werltw"),
              Text("Hallo Werlt3"),
              Text("Hallo Werlt4"),
            ],
          ),
        ),
      ),
    );
  }

}