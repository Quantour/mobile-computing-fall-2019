import 'dart:io';
import 'package:Wanderlust/cloud_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:Wanderlust/ui_elements/route_map.dart';
import 'package:Wanderlust/views/edit_page/edit_loc_data_page.dart';
import '../../data_models/location.dart';
import '../../data_models/route.dart';
import '../../data_models/user.dart';

class HikeEditPage extends StatefulWidget {
  final bool isNew;
  final HikingRoute oldroute;
  final List<Location> routeSuggestion;

  HikeEditPage({this.oldroute, this.routeSuggestion}) : isNew = (oldroute == null) {
    //Either it is a new or an old route
    assert(!(oldroute!=null && routeSuggestion!=null));
  }


  @override
  _HikeEditPageState createState() {
    _HikeEditPageState state = _HikeEditPageState();
    if (isNew) {
      if (routeSuggestion!=null&&routeSuggestion.length>0) {
        state.routeList.addAll(routeSuggestion);
        state.cameraPosition = CameraPosition(
          target: routeSuggestion.last.toLatLng(),
          zoom: 12
        );
      }
    } else {
      state.images = [
        for (String url in oldroute.images) NetwOrFileImg(url: url)
      ];
    }
    return state;
  }
}

class _HikeEditPageState extends State<HikeEditPage> {
  //List of local Files for uploading images or strings -> URL to uploadedimage
  List<NetwOrFileImg> images = [];

  //Controller for textfields
  TextEditingController titleController;
  TextEditingController descriptionController;
  TextEditingController tipsController;

  //Route info
  List<Location> routeList = [];
  //Camera pos of Maps, if you return to this page
  CameraPosition cameraPosition;

  @override
  void initState() {
    super.initState();
    //initialize controller
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    tipsController = TextEditingController();
    if (!widget.isNew) {
      titleController.text = widget.oldroute.title;
      descriptionController.text = widget.oldroute.description==null?"":widget.oldroute.description;
      tipsController.text = widget.oldroute.tipsAndTricks==null?"":widget.oldroute.tipsAndTricks;
    }
  }

  void _onSave(BuildContext context) {
    if (this.titleController.text==null||this.titleController.text=="") {
      showDialog(
        context: context,
        child: AlertDialog(
          content: Text("Please fill out the title before you save!"),
          actions: <Widget>[
            FlatButton(
              child: Text("Ok"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        )
      );
      return;
    }
    if (this.routeList == null||this.routeList.length<2) {
      showDialog(
        context: context,
        child: AlertDialog(
          content: Text("Please enter location information about the route before you save!"),
          actions: <Widget>[
            FlatButton(
              child: Text("Ok"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        )
      );
      return;
    }
    
    //TODO: Upload images and save route

    Navigator.pop(context);
  }

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
                      images.add(NetwOrFileImg(file: file));
                    });
                });
              },
            ),
            FlatButton(
              child: Text("camera"),
              onPressed: () {
                Navigator.pop(context);
                ImagePicker.pickImage(source: ImageSource.camera, )
                    .then((file) async {
                  if (await file.exists())
                    setState(() {
                      images.add(NetwOrFileImg(file: file));
                    });
                });
              },
            )
          ],
        ));
  }

  //Shows the User a specific image and if the user wants to keep the image or rather delete it
  void _showImageDialog(BuildContext context, NetwOrFileImg img) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => Scaffold(
        body: Container(
          color: Colors.black.withAlpha(200),
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

  Widget _buildImagePicker() {
    return Builder(
      builder: (context) {
        const int number_of_colums = 5;
        double widthOfGridElement =
            MediaQuery.of(context).size.width / number_of_colums;
        //build list of widgets which are going to be displayed in a grid view
        List<Widget> gridItems = [
          for (NetwOrFileImg img in images)
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
              decoration: BoxDecoration(color: Theme.of(context).accentColor.withAlpha(200)),
            ),
          )
        ];

        //put gridItems in matrix
        List<List<Widget>> grid = [];
        int row = 0; int col = 0;
        for (int i = 0; i < gridItems.length; i++) {
          if (grid.length <= row) grid.add([]);
          grid[row] = grid[row]..add(gridItems[i]);
          col++;
          if (col >= number_of_colums-1) {
            col = 0;
            row++;
          }
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
        padding: EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            //----->Title<-----
            Container(height: 30,),
            Text("Title", style: TextStyle(fontSize: 20)),
            Container(height: 7,),
            TextField(
              enabled: widget.isNew,
              controller: titleController,
              decoration: InputDecoration(fillColor: widget.isNew?Theme.of(context).accentColor.withAlpha(30):Colors.grey.withAlpha(30), filled: true),
            ),
            //----->Description<-----
            Container(height: 30,),
            Text("Description", style: TextStyle(fontSize: 20)),
            Container(height: 7,),
            TextField(
              controller: descriptionController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(fillColor: Theme.of(context).accentColor.withAlpha(30), filled: true),
            ),
            //----->Tips&Tricks<-----
            Container(height: 30,),
            Text("Tips & Tricks", style: TextStyle(fontSize: 20)),
            Container(height: 7,),
            TextField(
              controller: tipsController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(fillColor: Theme.of(context).accentColor.withAlpha(30), filled: true),
            ),
            //----->Images<-----
            Container(height: 30,),
            Text("Images", style: TextStyle(fontSize: 20)),
            Container(height: 10,),
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              child: Container(
                color: Color.fromRGBO(200, 200, 200, 1),
                child: _buildImagePicker()
              ),
            ),

            //----->put in route information<-----
            if (widget.isNew)
              Container(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: ClipRRect(
                    clipBehavior: Clip.hardEdge,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => EditLocInfoPage(this.routeList, this.cameraPosition)
                        )).then((data) {
                          this.routeList=data[0];
                          this.cameraPosition=data[1];
                        });
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width*0.7,
                        height: 50,
                        color: Theme.of(context).accentColor.withAlpha(150),
                        child: Center(
                          child: Text("Edit route information", style: TextStyle(fontSize: 20),),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            //------>show map when is old  route<-----
            if (!widget.isNew)
              Container(
                margin: EdgeInsets.only(top: 25),
                height: 300,
                child: RouteMap(route: Future.value(widget.oldroute),),
              ),
              
            
            //----->Save/Cancel<-----
            Container(height: 50,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ClipRRect(
                  clipBehavior: Clip.hardEdge,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  child: GestureDetector(
                    onTap: ()=>_onSave(context), //TODO onSave event
                    child: Container(
                      width: MediaQuery.of(context).size.width*0.3,
                      height: 50,
                      color: Colors.green,
                      child: Center(
                        child: Text("Save", style: TextStyle(fontSize: 20),),
                      ),
                    ),
                  ),
                ),

                ClipRRect(
                  clipBehavior: Clip.hardEdge,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  child: GestureDetector(
                    onTap: ()=>Navigator.pop(context),
                    child: Container(
                      width: MediaQuery.of(context).size.width*0.3,
                      height: 50,
                      color: Colors.red,
                      child: Center(
                        child: Text("Cancel", style: TextStyle(fontSize: 20),),
                      ),
                    ),
                  ),
                ),

              ]
            )
          ],
        ),
      ),
    );
  }
}
