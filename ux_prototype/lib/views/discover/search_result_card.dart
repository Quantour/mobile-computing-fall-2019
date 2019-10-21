

import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:ux_prototype/data_models/route.dart';
import 'package:ux_prototype/ui_elements/image_scroller.dart';
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
              //<Ratings length and user info>
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ExperienceRatingWidget(rating: route.avgRating),
                      DifficultyRatingWidget(rating: route.avgDifficulty)
                    ],
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            route.length<1000
                              ?Text("${route.length} meter")
                              :Text("${route.length.toDouble().toStringAsFixed(1)} km"),
                            Icon(Icons.gesture)
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            route.length<1000
                              ?Text("${route.steepness} meter")
                              :Text("${route.steepness.toDouble().toStringAsFixed(1)} km"),
                            Icon(Icons.show_chart)
                          ],
                        )
                      ],
                    )
                  ),
                ],
              ),

              FutureBuilder(
                    future: User.fromID(route.userID),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasError)
                          return Container();
                        else
                          return Row(children: <Widget>[
                            /* FadeInImage.memoryNetwork(
                                placeholder: kTransparentImage,
                                image: images[index],
                                fit: BoxFit.cover,
                              ) */
                            Container(
                              child: Stack(
                                fit: StackFit.passthrough,
                                children: <Widget>[
                                  ClipOval(
                                    child: Image.asset(
                                      "assets/images/blank_profile_picture.png",
                                      fit: BoxFit.cover
                                    )
                                  ),
                                  ClipOval(
                                    child: FadeInImage.memoryNetwork(
                                      placeholder: kTransparentImage,
                                      image: snapshot.data.profilePicture,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ],
                              ),
                              height: 30,
                              width: 30,
                            ),
                            Text(snapshot.data.name)
                          ]);
                      } else {
                        return Container();
                      }
                    },
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