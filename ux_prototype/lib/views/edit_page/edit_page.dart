
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

  HikeEditPage({this.oldroute}):isNew=(oldroute==null);

  @override
  _HikeEditPageState createState() {
    _HikeEditPageState state = _HikeEditPageState();
    if (isNew) {

    } else {
      state.images = [for (String url in oldroute.images) _NetwOrFileImg(url: url)];
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
  bool get isFile => file!=null;
  bool get isNetw => url!=null;
  Image get image {
    if (isFile)
      return Image.file(file);
    else if (isNetw)
      return Image.network(url);
    else return Image.memory(kTransparentImage);
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
              ImagePicker.pickImage(
                source: ImageSource.gallery
              ).then((file) async {
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
              ImagePicker.pickImage(
                source: ImageSource.camera
              ).then((file) async {
                if (await file.exists())
                  setState(() {
                    images.add(_NetwOrFileImg(file: file));
                  });
              });
            },
          )
        ],
      )
    );

  }

  //Shows the User a specific image and if the user wants to keep the image or rather delete it
  void _showImageDialog(BuildContext context, _NetwOrFileImg img) {
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
                      image: img.image.image //Image provider of image widget created from _NetwOrFileImg img
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
                        Navigator.of(context, rootNavigator: true).pop();
                        setState(() {
                          images.remove(img);
                        });
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


  Widget buildImagePicker() {
    return Builder(
      builder: (context) {
        const double number_of_colums = 4;
        double widthOfGridElement = MediaQuery.of(context).size.width/number_of_colums; 
        //build list of widgets which are going to be displayed in a grid view
        List<Widget> gridItems= [
          for (_NetwOrFileImg img in images)
            InkWell(
              onTap: () => _showImageDialog(context, img), //display image and give user chance to delete it
              child: Container(
                width: widthOfGridElement,
                height: widthOfGridElement,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: img.image.image
                  )
                ),
              ),
            ),
          InkWell(
            onTap: () => _showNewImageDialog(context), //pick new image
            child: Container(
              width: widthOfGridElement,
              height: widthOfGridElement,
              child: Center(
                child: Icon(Icons.add, size: 40, color: Colors.white,),
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

  /*
  Widget buildImagePicker(BuildContext context) {
    return Container(
      color: Colors.grey,
      height: MediaQuery.of(context).size.height*0.3,
      padding: EdgeInsets.all(10),
      child: GridView.count(
        primary: false,
        padding: const EdgeInsets.all(20),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 4,
        children: <Widget>[
          for (_NetwOrFileImg img in images)
            GestureDetector(
              onTap: () {
                _showImageDialog(context, img);
              },
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    //load image from network or read as local file
                    image: img.image.image
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
                child: Icon(Icons.add, size: 40,),
              ),
            ),
          )
        ],
      ),
    );
  }*/

  Widget buildWhenUserNotLoggedIn(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height*0.3,
            ),
            Center(
              child: Icon(Icons.error, size: 40, color: Theme.of(context).accentColor,),
            ),
            Container(height: 20,),
            Center(
              child: Text("Please log in or register to ${widget.isNew?"create a new route":"edit a route"}!"),
            ),
            Center(
              child: FlatButton(
                child: Text("close", style: TextStyle(color: Theme.of(context).accentColor),),
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
    if (!User.isLoggedIn)
      return buildWhenUserNotLoggedIn(context);

    

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height*0.3,
                color: Colors.green,
              ),
              buildImagePicker()
            ],
          ),
      ),
      
    );

  }
  
}