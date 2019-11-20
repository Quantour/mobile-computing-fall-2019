


import 'package:Wanderlust/cloud_image.dart';
import 'package:Wanderlust/data_models/user.dart';
import 'package:Wanderlust/ui_elements/profile_picture.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class _ProfilePicDialog extends StatelessWidget {
  const _ProfilePicDialog({Key key}) : super(key: key);
  static const double _padding = 15;
  static const double _avRadiusFactor = 0.2;

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
              Text(
                User.currentUser.getName,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              /*SizedBox(height: 16.0),
              Text(
                "description",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),*/
              SizedBox(height: 24.0),
              Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onProfilePictureChange(context);
                      },
                      child: Text("Change profile picture", style: TextStyle(color: Theme.of(context).accentColor)),
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
                child: ProfilePictureWidget(url: User.currentUser.profilePicture),
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







void onProfilePictureChange(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text("Do you want to open the gallery or the camera?"),
          actions: <Widget>[
            FlatButton(
              child: Text("gallery"),
              onPressed: () {
                Navigator.pop(context);
                ImagePicker.pickImage(source: ImageSource.gallery).then((file) async {
                  try {
                    if (await file.exists()) {
                      String url = await uploadCloudImage(file);
                      await User.updateProfilePicture(User.currentUser.getID, url);
                    }
                  } catch (e) {}
                });
              },
            ),
            FlatButton(
              child: Text("camera"),
              onPressed: () {
                Navigator.pop(context);
                ImagePicker.pickImage(source: ImageSource.camera).then((file) async {
                  try {
                    if (await file.exists()) {
                      String url = await uploadCloudImage(file);
                      await User.updateProfilePicture(User.currentUser.getID, url);
                    }
                  } catch (e) {}
                });
              },
            )
          ],
        );
      },
  );
}

void onProfilePictureTap(BuildContext context) {
  assert(User.isLoggedIn);

  showDialog(
    context: context,
    builder: (context) {
      return _ProfilePicDialog();
    }
  );
  

}