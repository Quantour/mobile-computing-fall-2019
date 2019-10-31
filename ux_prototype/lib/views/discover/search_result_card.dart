

import 'package:flutter/material.dart';
import 'package:ux_prototype/data_models/route.dart';
import 'package:ux_prototype/ui_elements/image_scroller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class SearchResultCardWidget extends StatelessWidget {

  final void Function() onTap;
  final String heroTag;
  final HikingRoute route;
  final int user_idx;

  SearchResultCardWidget({this.onTap, this.heroTag, @required this.route, this.user_idx});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
     stream: Firestore.instance.collection('user').snapshots(),
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
                  Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: ImageScrollerWidget(
                      imageBuilder: () => route.images,
                      heroTag: this.heroTag==null?UniqueKey().toString():this.heroTag,
                    )
                  ),
                  Text("${snapshot.data.documents[user_idx].data['username']}", style: Theme.of(context).textTheme.title),
                  Text("Expertise : ${snapshot.data.documents[user_idx].data['expertise']}"),
                  Text("Difficulty : ${snapshot.data.documents[user_idx].data['difficulty']}"),
                  Text("Region : ${snapshot.data.documents[user_idx].data['region']}"),
                ],
              ),
            ),
          ),
        );
     },
   );
  }
}


