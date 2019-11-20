


import 'package:Wanderlust/data_models/user.dart';
import 'package:Wanderlust/ui_elements/rating.dart';
import 'package:flutter/material.dart';

class _RatingDialog extends StatefulWidget {
  _RatingDialog({Key key}) : super(key: key);

  @override
  __RatingDialogState createState() => __RatingDialogState();
}

class __RatingDialogState extends State<_RatingDialog> {
  static const double _padding = 15;
  static const double _avRadiusFactor = 0.2;

  double experienceRating = 3.0;
  double difficultyRating = 3.0;

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            top:  MediaQuery.of(context).size.width*_avRadiusFactor + _padding,
            bottom: _padding,
            left: _padding,
            right: _padding,
          ),
          margin: EdgeInsets.only(top: MediaQuery.of(context).size.width*_avRadiusFactor),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(_padding),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              /*Text(
                "text",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16.0),*/
              /*Text(
                "description",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),*/

              //SLIDER------------------------------------------------------


              Padding(
                padding: const EdgeInsets.only(left: 8,  top: 8),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text("my experience", style: Theme.of(context).textTheme.subtitle),
                    ),
                    ExperienceRatingWidget(rating: experienceRating, useColumn: true),
                  ],
                ),
              ),
              Slider(
                value: experienceRating,
                onChanged: (val) {
                  setState(() {
                    experienceRating = val;
                  });
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
                      child: Text("difficulty", style: Theme.of(context).textTheme.subtitle),
                    ),
                    DifficultyRatingWidget(rating: difficultyRating, useColumn: true),
                  ],
                ),
              ),
              Slider(
                value: difficultyRating,
                onChanged: (val) {
                  setState(() {
                    difficultyRating = val;
                  });
                },
                min: 1.0,
                max: 5.0,
                divisions: 4,
              ),


              //</Slider>----------------------------------------------------


              SizedBox(height: 24.0),
              Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Cancel", style: TextStyle(color: Theme.of(context).accentColor)),
                    ),
                    FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Ok", style: TextStyle(color: Theme.of(context).accentColor)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: _padding,
          right: _padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width*_avRadiusFactor*2,
                height: MediaQuery.of(context).size.width*_avRadiusFactor*2,
                child: Icon(
                  Icons.directions_walk,
                  size: MediaQuery.of(context).size.width*_avRadiusFactor*2,
                  color: Theme.of(context).accentColor,  
                ),
              ),
            ],
          ),
          /*child: CircleAvatar(
            backgroundColor: Colors.blueAccent,
            radius: _avRadius,
            child: Center(child: ProfilePictureWidget(url: User.currentUser.profilePicture)),
          ),*/
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

}



void showRatingDialog(String hikeID, BuildContext context) {
  assert(User.isLoggedIn);

  showDialog(
    context: context,
    builder: (context) {
      return _RatingDialog();
    }
  );

}


