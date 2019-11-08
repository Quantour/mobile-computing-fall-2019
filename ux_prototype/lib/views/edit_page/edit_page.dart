import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:transparent_image/transparent_image.dart';
import '../../data_models/route.dart';
import '../../data_models/user.dart';

class HikeEditPage extends StatefulWidget {
  final bool isNew;
  final HikingRoute oldroute;

  HikeEditPage({this.oldroute}) : isNew = (oldroute == null);

  @override
  _HikeEditPageState createState() {
    _HikeEditPageState state = _HikeEditPageState();
    if (isNew) {
    } else {
      state.images = [
        for (String url in oldroute.images) _NetwOrFileImg(url: url)
      ];
    }
    return state;
  }
}

/*
 * Represents a Image which is either loaded from the network or choosen locally as a file
 */
class _NetwOrFileImg {
  _NetwOrFileImg({this.file, this.url});
  File file;
  String url;
  bool get isFile => file != null;
  bool get isNetw => url != null;
  ImageProvider get image {
    if (isFile)
      return FileImage(file);
    else if (isNetw)
      return NetworkImage(url);
    else
      return MemoryImage(kTransparentImage);
  }
}

class _HikeEditPageState extends State<HikeEditPage> {
  //List of local Files for uploading images or strings -> URL to uploadedimage
  List<_NetwOrFileImg> images = [];

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
                Navigator.pop(context);
                ImagePicker.pickImage(source: ImageSource.gallery)
                    .then((file) async {
                  if (await file.exists())
                    setState(() {
                      images.add(_NetwOrFileImg(file: file));
                    });
                });
              },
            ),
            FlatButton(
              child: Text("camera"),
              onPressed: () {
                Navigator.pop(context);
                ImagePicker.pickImage(source: ImageSource.camera)
                    .then((file) async {
                  if (await file.exists())
                    setState(() {
                      images.add(_NetwOrFileImg(file: file));
                    });
                });
              },
            )
          ],
        ));
  }

  //Shows the User a specific image and if the user wants to keep the image or rather delete it
  void _showImageDialog(BuildContext context, _NetwOrFileImg img) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => Scaffold(
        body: Container(
          padding: EdgeInsets.all(15),
          child: Center(
            child: Image(
              image: img.image,
              fit: BoxFit.contain,
            ),
          ),
        ),
        bottomNavigationBar: Row(
          children: <Widget>[
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 50,
                color: Colors.green,
                child: Center(
                  child: Text("Ok", style: TextStyle(color: Colors.white, fontSize: 22))
                ),
                width: MediaQuery.of(context).size.width/2,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                images.remove(img);
              },
              child: Container(
                color: Colors.red,
                height: 50,
                child: Center(
                  child: Text("Delete", style: TextStyle(color: Colors.white, fontSize: 22))
                ),
                width: MediaQuery.of(context).size.width/2,
              ),
            )
          ],
        ),
      )
    ));
  }
  /*void _showImageDialog(BuildContext context, _NetwOrFileImg img) {
    showDialog(
      context: context,
      child: Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
        ),
        elevation: 3.0,
        backgroundColor: Colors.transparent,
        child: Column(
          children: <Widget>[
            Image(
                  image: img.image,
                  fit: BoxFit.contain,
            )

          ],
        ),
      )
    );
  }
  void _showImageDialog(BuildContext context, _NetwOrFileImg img) {
    showDialog(
      context: context,
      barrierDismissible: true,
      child: Dialog(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              
              Container(
                child: Image(
                  image: img.image,
                  
                ),
              ),
              /*Container(
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.contain,
                    image: img.image //Image provider of image widget created from _NetwOrFileImg img
                  )
                ),
              ),*/
              //Ok and Delete buttons for the image
              Center(
                child: Row(
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () {
                        //close Dialog
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      child: Text(
                        "OK",
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.green,
                    ),
                    RaisedButton(
                        onPressed: () {
                          //close Dialog & remove img from list
                          Navigator.of(context, rootNavigator: true).pop();
                          setState(() {
                            images.remove(img);
                          });
                        },
                        child: Text(
                          "Delete",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.red)
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }*/

  Widget buildImagePicker() {
    return Builder(
      builder: (context) {
        const double number_of_colums = 4;
        double widthOfGridElement =
            MediaQuery.of(context).size.width / number_of_colums;
        //build list of widgets which are going to be displayed in a grid view
        List<Widget> gridItems = [
          for (_NetwOrFileImg img in images)
            InkWell(
              onTap: () => _showImageDialog(context, img), //display image and give user chance to delete it
              child: Container(
                width: widthOfGridElement,
                height: widthOfGridElement,
                decoration: BoxDecoration(
                    image:
                        DecorationImage(fit: BoxFit.cover, image: img.image)),
              ),
            ),
          InkWell(
            onTap: () => _showNewImageDialog(context), //pick new image
            child: Container(
              width: widthOfGridElement,
              height: widthOfGridElement,
              child: Center(
                child: Icon(
                  Icons.add,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              decoration: BoxDecoration(color: Theme.of(context).accentColor),
            ),
          )
        ];

        //put gridItems in matrix
        List<List<Widget>> grid = [];
        for (int i = 0; i < gridItems.length; i++) {
          int row = (i / (number_of_colums.floor())).floor();
          //int col = (i % (number_of_colums.floor()));
          if (grid.length <= row) grid.add([]);
          grid[row].add(gridItems[i]);
        }

        //display matrix
        return Column(
          children: <Widget>[
            for (List<Widget> row in grid)
              Row(
                children: row,
              )
          ],
        );
      },
    );
  }

  Widget buildWhenUserNotLoggedIn(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
            ),
            Center(
              child: Icon(
                Icons.error,
                size: 40,
                color: Theme.of(context).accentColor,
              ),
            ),
            Container(
              height: 20,
            ),
            Center(
              child: Text(
                  "Please log in or register to ${widget.isNew ? "create a new route" : "edit a route"}!"),
            ),
            Center(
              child: FlatButton(
                child: Text(
                  "close",
                  style: TextStyle(color: Theme.of(context).accentColor),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!User.isLoggedIn) return buildWhenUserNotLoggedIn(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              color: Colors.green,
            ),
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              child: Container(
                color: Color.fromRGBO(200, 200, 200, 1),
                child: buildImagePicker()
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}
