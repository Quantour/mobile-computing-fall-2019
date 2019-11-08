
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:transparent_image/transparent_image.dart';
import '../../data_models/route.dart';
import '../../data_models/user.dart';


class HikeEditPage extends StatefulWidget {
  final bool isNew;
  final HikingRoute oldroute;

  HikeEditPage({this.oldroute}):isNew=(oldroute==null);

  @override
  _HikeEditPageState createState() {
    _HikeEditPageState state = _HikeEditPageState();
    if (isNew) {
      state.images = [];
    } else {
      state.images = [for (String str in oldroute.images) str];
    }
    return state;
  }
}

class _HikeEditPageState extends State<HikeEditPage> {

  //List of local Files for uploading images or strings -> URL to uploadedimage
  List<dynamic> images;

  //Shows the User a dialog to pick a new image for the route
  void _showNewImageDialog(BuildContext context) {

    showDialog(
      context: context,
      child: AlertDialog(
        content: Text("Do you want to open the gallery or the camera?"),
        actions: <Widget>[
          FlatButton(
            child: Text("gallery"),
            onPressed: () {
              ImagePicker.pickImage(
                source: ImageSource.gallery
              ).then((file) {
                setState(() {
                  images.add(file);
                });
              });
            },
          ),
          FlatButton(
            child: Text("camera"),
            onPressed: () {
              ImagePicker.pickImage(
                source: ImageSource.camera
              ).then((file) {
                setState(() {
                  images.add(file);
                });
              });
            },
          )
        ],
      )
    );

  }

  //Shows the User a specific image and if the user wants to keep the image or rather delete it
  void _showImageDialog(BuildContext context, dynamic img) {
    showDialog(
      context: context,
      barrierDismissible: true,
      child: Dialog(
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            children: <Widget>[
              Center(
                child: Container(
                  height: MediaQuery.of(context).size.height*0.6,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.contain,
                      image: (img is String)?Image.network(img):( (img is File)?Image.file(img):kTransparentImage )
                    )
                  ),
                ),
              ),
              //Ok and Delete buttons for the image
              Center(
                child: Row(
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () {
                        //close Dialog
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      child: Text("OK", style: TextStyle(color: Colors.white),),
                      color: Colors.green,
                    ),
                    RaisedButton(
                      onPressed: () {
                        //close Dialog & remove img from list
                        images.remove(img);
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      child: Text("Delete", style: TextStyle(color: Colors.white),),
                      color: Colors.red
                    )
                  ],
                ),
              )
            ],  
          ),
        ),
      ),
    );
  } 

  Widget buildImagePicker(BuildContext context) {
    return Container(
      color: Colors.grey,
      padding: EdgeInsets.all(10),
      child: GridView.count(
        primary: false,
        padding: const EdgeInsets.all(20),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 3,
        children: <Widget>[
          for (dynamic img in images)
            GestureDetector(
              onTap: () {
                _showImageDialog(context, img);
              },
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    //load image from network or read as local file
                    image: (img is String)?Image.network(img):( (img is File)?Image.file(img):kTransparentImage ),
                  )
                ),
              ),
            ),

          GestureDetector(
            onTap: () {
              //pick new Image
              _showNewImageDialog(context);
            },
            child: Container(
              color: Colors.grey[200],
              child: Center(
                child: Icon(Icons.add, size: 15,),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildWhenUserNotLoggedIn(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height*0.3,
            ),
            Center(
              child: Icon(Icons.error, size: 20,),
            ),
            Container(height: 20,),
            Center(
              child: Text("Please log in or register to ${widget.isNew?"create a new route":"edit a route"}!"),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!User.isLoggedIn)
      return buildWhenUserNotLoggedIn(context);

    
    return Scaffold(
      body: Stack(
        children: <Widget>[
          SafeArea(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: FloatingActionButton(
                heroTag: "FloatingActionButton:edit_page",
                backgroundColor: Theme.of(context).accentColor.withAlpha(200),
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Icon(Icons.arrow_back),
              )
            ),
          ),
          SingleChildScrollView(
            child: Builder(
              builder: (c) {
                
                //if user is logged in they can not edit or create a new route
                if (!User.isLoggedIn)
                return Center(
                  child: Column(
                    children: <Widget>[
                      Center(
                        child: Icon(Icons.error, size: 20,),
                      ),
                      Container(height: 20,),
                      Center(
                        child: Text("Please log in or register to ${widget.isNew?"create a new route":"edit a route"}!"),
                      )
                    ],
                  ),
                );

                //user is logged in
                return Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(10),
                  child: SingleChildScrollView(
                    child: Column(
                    children: <Widget>[


                        buildImagePicker(context)


                      ],
                    ),
                  ),
                );

              },
            ),
          )
        ].reversed.toList(),
      ),
    );

  }
}