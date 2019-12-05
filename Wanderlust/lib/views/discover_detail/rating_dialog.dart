


import 'package:Wanderlust/data_models/rating.dart';
import 'package:Wanderlust/data_models/user.dart';
import 'package:Wanderlust/ui_elements/rating.dart';
import 'package:flutter/material.dart';

class _RatingDialog extends StatefulWidget {
  final String routeID;
  final void Function() closeDialog;
  _RatingDialog(this.routeID, this.closeDialog, {Key key}) : super(key: key);

  @override
  __RatingDialogState createState() => __RatingDialogState();
}

class __RatingDialogState extends State<_RatingDialog> {
  static const double _padding = 15;
  static const double _avRadiusFactor = 0.2;

  double experienceRating = 3.0;
  double difficultyRating = 3.0;

  bool _setOldRating = false;
  bool _forceShowLoading = false;

  Widget loadContent(BuildContext context) {
    return Container(
      height: 300,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
    
  }

  //builds content given previous rating
  //if there is no previous rating, rating is null
  Widget dialogContent(BuildContext context, Rating rating) {
    bool isNew = (rating==null);
    String cancelText;
    String okText;
    void Function() onCancel;
    void Function() onOk;
    const timeoutDur = const Duration(seconds: 3);
    
    if (isNew) {
      cancelText = "Cancel";
      okText = "Ok";
      onOk = () async {
        Rating r = Rating(
          difficultyRating: difficultyRating,
          experienceRating: experienceRating,
          routeID: widget.routeID,
          userID: (await User.currentUser).getID
        );
        setState(() {
          _forceShowLoading = true;
        });
        try {
          await Rating.uploadRating(r).timeout(timeoutDur);
        } catch (e) {} 
        
        widget.closeDialog();
      };
      onCancel = () {
        widget.closeDialog();
      };
    } else {
      //is not new
      if (!_setOldRating) {
        _setOldRating = true;
        //Calling setState not neccessary because those
        //values are usesed later in the code and
        //furthermore setState may not be calles
        //while building the UI
        experienceRating = rating.experienceRating;
        difficultyRating = rating.difficultyRating;
      }

      cancelText = "Delete Rating";
      okText = "Update Rating";
      onOk = () async {
        Rating r = Rating(
          difficultyRating: difficultyRating,
          experienceRating: experienceRating,
          routeID: widget.routeID,
          userID: (await User.currentUser).getID
        );
        setState(() {
          _forceShowLoading = true;
        });
        try {
          await Rating.updateRating(r).timeout(timeoutDur);
        } catch (e) {} 
        
        widget.closeDialog();
      };
      onCancel = () async {
        setState(() {
          _forceShowLoading = true;
        });
        try {
          await Rating.deleteRating(rating.routeID, rating.userID).timeout(timeoutDur);
        } catch (e) {}
        widget.closeDialog();
      };
    }

    return Column(
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
                onPressed: onCancel,
                child: Text(cancelText, style: TextStyle(color: Theme.of(context).accentColor)),
              ),
              FlatButton(
                onPressed: onOk,
                child: Text(okText, style: TextStyle(color: Theme.of(context).accentColor)),
              ),
            ],
          ),
        ),
      ],
    );
  }




  Widget dialogFrame(BuildContext context) {
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
          child: FutureBuilder<User>(
            future: User.currentUser,
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return loadContent(context);
              User currentUser = snapshot.data;
              print(currentUser.getID);
              return FutureBuilder<bool>(
                future: Rating.existRating(widget.routeID, currentUser.getID),
                builder: (context, snapshot) {
                  if (_forceShowLoading)
                    return loadContent(context);
                  
                  if (!snapshot.hasData)
                    return loadContent(context);
                  bool existRat = snapshot.data;
                  if (!existRat)
                    return dialogContent(context, null);
                  return FutureBuilder(
                    future: Rating.getRating(widget.routeID, currentUser.getID),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return loadContent(context);
                      Rating rating = snapshot.data;
                      return dialogContent(context, rating);
                    },
                  );
                },
              );
            }
          )
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
      child: dialogFrame(context),
    );
  }

}



Future<void> showRatingDialog(String routeID, BuildContext context) async {
  assert(await User.isLoggedIn);

  void Function() closeDialog = () {
    Navigator.pop(context);
  };
  await showDialog(
    context: context,
    builder: (context) {
      return _RatingDialog(routeID, closeDialog);
    }
  );

}


