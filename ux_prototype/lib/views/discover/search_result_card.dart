

import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:ux_prototype/data_models/route.dart';
import 'package:ux_prototype/ui_elements/image_scroller.dart';
import 'package:ux_prototype/ui_elements/profile_picture.dart';
import 'package:ux_prototype/ui_elements/rating.dart';

import '../../data_models/user.dart';

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
              //<Image Scroller>
              Container(
                height: MediaQuery.of(context).size.height * 0.2,
                child: ImageScrollerWidget(
                  imageBuilder: () => route.images,
                  heroTag: this.heroTag==null?UniqueKey().toString():this.heroTag,
                )
              ),

              //<Body of Card>
              Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    //<Ratings length and user info>
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ExperienceRatingWidget(rating: route.avgRating, iconSize: 17, fontSize: 15,),
                            DifficultyRatingWidget(rating: route.avgDifficulty, iconSize: 17, fontSize: 15,),
                            //Profile Picture
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: FutureBuilder(
                                future: User.fromID(route.userID),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.done) {
                                    if (snapshot.hasError)
                                      return Container();
                                    else
                                      return Row(children: <Widget>[
                                        Container(
                                          child: ProfilePictureWidget(url:snapshot.data.profilePicture),
                                          height: 30,
                                          margin: EdgeInsets.only(right: 10),
                                        ),
                                        Text(snapshot.data.name)
                                      ]);
                                  } else {
                                    return Container(height: 30);
                                  }
                                },
                              ),
                            )
                          ],
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              //length of route
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  route.length<1000
                                    ?Text("${route.length} meter", style: TextStyle(fontSize: 12))
                                    :Text("${route.length.toDouble().toStringAsFixed(1)} km", style: TextStyle(fontSize: 12)),
                                  Icon(Icons.gesture, size: 19)
                                ],
                              ),
                              //steepness of route
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  route.steepness<1000
                                    ?Text("${route.steepness} meter", style: TextStyle(fontSize: 12))
                                    :Text("${route.steepness.toDouble().toStringAsFixed(1)} km", style: TextStyle(fontSize: 12)),
                                  Icon(Icons.show_chart, size: 19)
                                ],
                              ),
                              //avg time needed to complete
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Builder(
                                    builder: (context) {
                                      int hours = (route.avgTime/(60*60)).floor();
                                      int minutes = (route.avgTime%(60*60)).floor();
                                      String timestr = "$hours h";
                                      if (hours == 0) timestr = "$minutes min";
                                      else if (minutes != 0) timestr += " $minutes min";
                                      return Text(timestr, style: TextStyle(fontSize: 12));
                                    },
                                  ),
                                  Icon(Icons.timelapse, size: 19)
                                ],
                              ),
                              //nearest city
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text("${route.nearestCity}, ", style: TextStyle(fontSize: 12)),
                                  Text(
                                    route.country,
                                    style: TextStyle(fontSize: 9),
                                    textAlign: TextAlign.end,),
                                  Icon(Icons.map, size: 19)
                                ],
                              ),
                            ],
                          )
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                      child: Text(route.title, style: Theme.of(context).textTheme.title),
                    ),
                    Text(
                      route.description,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}