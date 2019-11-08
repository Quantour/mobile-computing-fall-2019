

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ux_prototype/data_models/route.dart';
import 'package:ux_prototype/data_models/user.dart';
import 'package:ux_prototype/ui_elements/profile_picture.dart';
import 'package:ux_prototype/ui_elements/rating.dart';
import 'package:ux_prototype/ui_elements/route_map.dart';

import '../data_models/route.dart';
import '../data_models/route.dart';

class RouteInfo extends StatelessWidget {
  final extended;
  final Future<HikingRoute> route;
  const RouteInfo({@required this.route, this.extended = false, Key key}) : super(key: key);


  Widget buildOverView(BuildContext context, HikingRoute route) {
    return Column(
      //TODO: Maybe add HeroWidget here
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
        //Title and Date, when created
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
              child: Text(route.title, style: Theme.of(context).textTheme.title),
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  DateTime time = DateTime.fromMillisecondsSinceEpoch(route.timestamp);
                  return Align(
                    alignment: Alignment.bottomRight,
                    child: Text("${time.month}/${time.day}/${time.year % 100}", textAlign: TextAlign.right,)
                  );
                },
              ),
            )
          ],
        ),
        Text(
          route.description,
          overflow: TextOverflow.ellipsis,
          maxLines: extended?100:2,
        ),
      //TODO: If extended View on data
      ]
    );
  }

  Widget buildExtended(BuildContext context, HikingRoute route) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[

        if (route.tipsAndTricks != null && route.tipsAndTricks != "")
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: Text("Tips & Tricks", style: Theme.of(context).textTheme.title),
        ),
        if (route.tipsAndTricks != null && route.tipsAndTricks != "")
        Text(
          route.tipsAndTricks,
          overflow: TextOverflow.ellipsis,
          maxLines: extended?100:2,
        ),
        SizedBox.fromSize(size: Size.fromHeight(40)),
        Container(
          height: 300,
          color: Color.fromRGBO(0, 0, 0, 0.15),
          child: Stack(
            children: <Widget>[
              //show when maps is loading
              Center(
                child: CircularProgressIndicator(),
              ),
              RouteMap(route: Future.value(route))
            ],
          )
        )

      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: route,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          //still waiting for data
          return Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          //future completed with error
          return Container(
            child: Center(
              child: Column(
                children: <Widget>[
                  Center(
                    child: Icon(Icons.error),
                  ),
                  Center(
                    child: Text("Error while loading route information!"),
                  )
                ],
              ),
            ),
          );
        } else {
          //future done with data!
          return //<Body of Card>
          Container(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                buildOverView(context, snapshot.data),
                if (extended)
                  buildExtended(context, snapshot.data)
              ],
            )
          ); 
        }
      }
    );
  }
}