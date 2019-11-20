import 'dart:math';
import 'package:Wanderlust/views/login/login.dart';
import 'package:Wanderlust/views/signin/signin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Wanderlust/ui_elements/custom_button.dart';
import 'package:Wanderlust/ui_elements/profile_picture.dart';
import 'package:Wanderlust/ui_elements/rating.dart';
import 'package:Wanderlust/views/discover/discover_search_parameter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_picture_dialog.dart';


import '../../data_models/user.dart';

class FilterDrawer extends StatefulWidget {

  final DiscoverSearchParameter searchParameter;
  final void Function() updateNotifier;

  FilterDrawer(this.searchParameter, this.updateNotifier);

  @override
  State<StatefulWidget> createState() {
    return _FilterDrawerState();
  }
}

class _FilterDrawerState extends State<FilterDrawer> {

  TextEditingController minKmController;
  TextEditingController maxKmController;

  @override
  void initState() {
    super.initState();
    minKmController = TextEditingController();
    minKmController.text = (widget.searchParameter.minMeter.toDouble()/1000.0).toString();
    maxKmController = TextEditingController();
    maxKmController.text = (widget.searchParameter.maxMeter.toDouble()/1000.0).toString();
  }

  

  Widget buildWithUser(BuildContext context, User currentUser) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(90), bottomRight: Radius.circular(0))
            ),
            clipBehavior: Clip.hardEdge,
            elevation: 8,
            margin: EdgeInsets.all(0),
            child: Container(
              decoration: BoxDecoration(
                //color: Theme.of(context).accentColor,
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  stops: [0,0.7],
                  colors: [
                    Color.fromRGBO(244,81,30,1),  //orange, #f4511e
                    Color.fromRGBO(109,76,65,1)  //brown, #6d4c41
                  ]
                )
              ),
              child: SafeArea(
                child: Builder(builder: (context) {
                  var w = min(MediaQuery.of(context).size.width*0.2,MediaQuery.of(context).size.height*0.2);
                  //When logged in
                  if (User.isLoggedIn)
                    return Column(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          width: w,
                          height: w,
                          margin: EdgeInsets.all(10),
                          child: ProfilePictureWidget(url: currentUser.profilePicture, onPress: ()=>onProfilePictureTap(context),),
                        ),
                        Text(currentUser.getName, style: Theme.of(context).textTheme.title),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CustomButton(
                            text: "Logout",
                            color: Color.fromRGBO(244,81,30,1),
                            onPressed: () {
                              //TODO Logout
                              //For UI debug purposes:
                              setState(() {
                               User.isLoggedIn = false; 
                              });
                            }
                          )
                        )
                      ],
                    );
                  else
                    //When not logged in
                    return Column(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          width: w,
                          height: w,
                          margin: EdgeInsets.all(10),
                          child: ProfilePictureWidget(url: null, placeholderAsset: "assets/images/logo_500.png",),
                        ),
                        //Text("", style: Theme.of(context).textTheme.title),
                        CustomButton(
                          text: "Sign up",
                          color: Color.fromRGBO(244,81,30,1),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => SignInPage()
                            ));
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                          child: CustomButton(
                            text: "  Login  ",
                            color: Color.fromRGBO(244,81,30,1),
                            onPressed: () {
                              //TODO log in
                              //For UI debug purposes:
                              setState(() {
                               User.isLoggedIn = true; 
                              });
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) => LoginPage()
                              ));
                            }
                          )
                        )
                      ],
                    );
                }),
              )
            ),
          ),

          //Filter functionality

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
                          controller: minKmController,
                          keyboardType: TextInputType.number,
                          onChanged: (txt) {
                            setState(() {
                              double minKm = double.tryParse(txt);
                              if (minKm == null) return; //TODO implement error msg
                              widget.searchParameter.minMeter = (minKm*1000).floor();
                            });
                            widget.updateNotifier();
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          decoration: InputDecoration(labelText: "max. km"),
                          keyboardType: TextInputType.number,
                          controller: maxKmController,
                          onChanged: (txt) {
                            setState(() {
                              double maxKm = double.tryParse(txt);
                              if (maxKm == null) return; //TODO implement error msg
                              widget.searchParameter.maxMeter = (maxKm*1000).floor();
                            });
                            widget.updateNotifier();
                          },
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
                ExperienceRatingWidget(rating: widget.searchParameter.minExperienceRating, useColumn: true),
              ],
            ),
          ),
          Slider(
            value: widget.searchParameter.minExperienceRating,
            onChanged: (val) {
              setState(() {
                widget.searchParameter.minExperienceRating = val;
              });
              widget.updateNotifier();
            },
            min: 1.0,
            max: 5.0,
            divisions: 4,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 8),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text("min. difficulty rating", style: Theme.of(context).textTheme.subtitle),
                ),
                DifficultyRatingWidget(rating: widget.searchParameter.minDifficultyRating, useColumn: true),
              ],
            ),
          ),
          Slider(
            value: widget.searchParameter.minDifficultyRating,
            onChanged: (val) {
              setState(() {
                widget.searchParameter.minDifficultyRating = val;
              });
              widget.updateNotifier();
            },
            min: 1.0,
            max: 5.0,
            divisions: 4,
          ),
        ],
      )
    );
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          
          if (!snapshot.hasData) {
            User.isLoggedIn = false;
            return buildWithUser(context, null);
          }

          // ignore: missing_return
          List<DocumentSnapshot> firebaseUsers = snapshot.data.documents; //[0].data['region'];

          List<Map<String,dynamic>> list = new List();

          list = firebaseUsers.map((DocumentSnapshot hike){
            return hike.data;
          }).toList(); //Makes all entries to List<Map<String,dynamic>>

          String query = 'Saga'; //Input userID by user.

          String ID;
          String name;
          for(Map<String,dynamic> users in list){
            String userIDTemp = users['userID'].toString();
            if(userIDTemp == query){
              ID = userIDTemp;
              name = users["name"].toString();
              break;
            } else {
              name = 'No name found';
              ID =   'No ID found';
            }
          }

          User currentUser = User(name,ID);
          return buildWithUser(context, currentUser);
        }

    );
  }
}

