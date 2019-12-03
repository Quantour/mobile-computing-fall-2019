


import 'dart:io';

import 'package:Wanderlust/cloud_image.dart';
import 'package:Wanderlust/data_models/user.dart';
import 'package:Wanderlust/ui_elements/profile_picture.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import '../../data_models/auth.dart';

class ProfilePic extends StatefulWidget {
  ProfilePic({this.storage});
  final FirebaseStorage storage;

  @override
  _ProfilePicDialog createState() => _ProfilePicDialog();
}

class _ProfilePicDialog extends State<ProfilePic> {
  //const _ProfilePicDialog({Key key}) : super(key: key);
  static const double _padding = 15;
  static const double _avRadiusFactor = 0.2;

  File _image;
  String _uploadedFileURL;



  dialogContent(BuildContext context) {
    return FutureBuilder<FirebaseUser>(
        future: Provider.of<AuthService>(context).getUser(),
        builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {

            FirebaseUser currentUser = snapshot.data;
            UserUpdateInfo userUpdateInfo = new UserUpdateInfo();

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
                currentUser.email,
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
                        onProfilePictureChange(context);
                        /*ImagePicker.pickImage(source: ImageSource.gallery).then((file) async {
                          try {
                            if (await file.exists()) {
                              _image = file;
                              await uploadFile();
                              /*final StorageReference storageReference = FirebaseStorage().ref().child("/profile_picture/${_image.path}");
                              //final StorageReference storageReference = widget.storage.ref().child('text').child('foo${_image.path}');
                              final StorageUploadTask uploadTask = storageReference.putFile(_image);
                              await uploadTask.onComplete;
                              print('File Uploaded');
                              final String url = await storageReference.getDownloadURL();
                              _uploadedFileURL = url;
                              print('File Downloaded');*/
                              /*storageReference.getDownloadURL().then((fileURL) {
                                _uploadedFileURL = fileURL;

                              }); */

                              userUpdateInfo.photoUrl = _uploadedFileURL;
                              currentUser.updateProfile(userUpdateInfo);
                              //url = await uploadCloudImage(file);

                              //url = "https://cdn3.f-cdn.com/contestentries/1376995/30494909/5b566bc71d308_thumb900.jpg";
                              //userUpdateInfo.photoUrl = url;
                              //currentUser.updateProfile(userUpdateInfo);
                              //await User.updateProfilePicture(User.currentUser.getID, url);
                            }

                          } catch (e) {}
                        });*/

                        //String url = "https://cdn3.f-cdn.com/contestentries/1376995/30494909/5b566bc71d308_thumb900.jpg";
                        //url = "https://cdn.guidingtech.com/media/assets/WordPress-Import/2012/10/Smiley-Thumbnail.png";
                        userUpdateInfo.photoUrl = _uploadedFileURL;
                        currentUser.updateProfile(userUpdateInfo);
                        //Navigator.pop(context);


                      },
                      child: Text("Change profile picture", style: TextStyle(color: Theme.of(context).accentColor)),
                    ),
                    FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                        userUpdateInfo.photoUrl = _uploadedFileURL;
                        currentUser.updateProfile(userUpdateInfo);
                      },
                      child: Text("ok", style: TextStyle(color: Theme.of(context).accentColor)),
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
                child: ProfilePictureWidget(url: currentUser.photoUrl),
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
          } else {
            // show loading indicator
            return LoadingCircle();
          }
        }

          );
  }
  Future uploadFile() async {

    final StorageReference storageReference = FirebaseStorage().ref().child("/profile_picture/${_image.path}");
    //final StorageReference storageReference = widget.storage.ref().child('text').child('foo${_image.path}');
    final StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    print('File Uploaded');
    final String url = await storageReference.getDownloadURL();
    _uploadedFileURL = url;
    print('File Downloaded');
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

  void onProfilePictureChange(BuildContext context){
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text("Do you want to open the gallery or the camera?"),
          actions: <Widget>[
            FlatButton(
              child: Text("gallery"),
              onPressed: () {
                ImagePicker.pickImage(source: ImageSource.gallery).then((file) async {
                  try {
                    if (await file.exists()) {
                      _image = file;
                      await uploadFile();
                    }
                  } catch (e) {}
                });
                Navigator.pop(context);

                },
            ),
            FlatButton(
              child: Text("camera"),
              onPressed: () {
                Navigator.pop(context);
                ImagePicker.pickImage(source: ImageSource.camera).then((file) async {
                  try {
                    if (await file.exists()) {
                      _image = file;
                      await uploadFile();

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
}

class LoadingCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: CircularProgressIndicator(),
        alignment: Alignment(0.0, 0.0),
      ),
    );
  }
}










void onProfilePictureTap(BuildContext context) {
  assert(User.isLoggedIn);

  showDialog(
    context: context,
    builder: (context) {
      return ProfilePic();
    }
  );
  

}