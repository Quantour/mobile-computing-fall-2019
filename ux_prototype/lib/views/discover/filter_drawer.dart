import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ux_prototype/ui_elements/profile_picture.dart';
import 'package:ux_prototype/ui_elements/rating.dart';

import '../../data_models/user.dart';

class FilterDrawer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FilterDrawerState();
  }
}

class _FilterDrawerState extends State<FilterDrawer> {
  double _minRating = 1, _minDifficultyRating = 1;


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[

          Container(
            child: SafeArea(
              child: Builder(builder: (context) {
                var w = min(MediaQuery.of(context).size.width*0.2,MediaQuery.of(context).size.height*0.2);
                //When logged in
                if (User.currentUser != null)
                  return Column(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        width: w,
                        height: w,
                        margin: EdgeInsets.all(10),
                        child: ProfilePictureWidget(url: User.currentUser.profilePicture),
                      ),
                      Text(User.currentUser.name, style: Theme.of(context).textTheme.title),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                          child: Text("Logout"),
                          onPressed: () {
                            //Todo Logout
                          },
                        ),
                      )
                    ],
                  );
                else
                  return Column(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        width: w,
                        height: w,
                        margin: EdgeInsets.all(10),
                        child: ProfilePictureWidget(url: null),
                      ),
                      Text("", style: Theme.of(context).textTheme.title),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                          child: Text("Login or sign up"),
                          onPressed: () {
                            //Todo in
                          },
                        ),
                      )
                    ],
                  );
              }),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).accentColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 8),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text("min./max. distance", style: Theme.of(context).textTheme.subtitle),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 8.0),
                        child: TextField(
                          decoration: InputDecoration(labelText: "min. km"),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          decoration: InputDecoration(labelText: "max. km"),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8,  top: 8),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text("min. experience rating", style: Theme.of(context).textTheme.subtitle),
                ),
                ExperienceRatingWidget(rating: _minRating, useColumn: true),
              ],
            ),
          ),
          Slider(
            value: _minRating,
            onChanged: (val) {
              setState(() {
                _minRating = val;
              });
            },
            min: 1.0,
            max: 5.0
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 8),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text("min. difficulty rating", style: Theme.of(context).textTheme.subtitle),
                ),
                DifficultyRatingWidget(rating: _minDifficultyRating, useColumn: true),
              ],
            ),
          ),
          Slider(
            value: _minDifficultyRating,
            onChanged: (val) {
              setState(() {
                _minDifficultyRating = val;
              });
            },
            min: 1.0,
            max: 5.0
          ),
        ],
      )
    );
  }
}

