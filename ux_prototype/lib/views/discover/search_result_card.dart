

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ux_prototype/data_models/route.dart';
import 'package:ux_prototype/ui_elements/image_scroller.dart';
import 'package:ux_prototype/ui_elements/route_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class SearchResultCardWidget extends StatelessWidget {

  final void Function() onTap;
  final String heroTag;
  final HikingRoute route;
  final int user_idx;

  SearchResultCardWidget({this.onTap, this.heroTag, @required this.route, this.user_idx});

  @override
  Widget build(BuildContext context) {
    bool extendView = true;
    return StreamBuilder<QuerySnapshot>(
     stream: Firestore.instance.collection('hike').snapshots(),
     builder: (context, snapshot) {
       if (!snapshot.hasData) return LinearProgressIndicator();
    
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
                  
                  Text("   ${snapshot.data.documents[user_idx].data['route']}" + "  (${snapshot.data.documents[user_idx].data['region']})", style: Theme.of(context).textTheme.title),
                  RouteInfo(route: route, extended: false,),
                  //Text("Expertise : ${snapshot.data.documents[user_idx].data['expertise']}"),
                  Text("   ${snapshot.data.documents[user_idx].data['description']}"),
//                  Text("   Region : ${snapshot.data.documents[user_idx].data['region']}"),
                  
                ],
              ),
            ),
          ),
        );
     },
   );
  }
}


