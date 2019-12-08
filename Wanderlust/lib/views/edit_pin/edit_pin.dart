import 'package:Wanderlust/cloud_image.dart';
import 'package:Wanderlust/data_models/pin.dart';
import 'package:Wanderlust/views/edit_pin/edit_pin_loc_data_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../data_models/location.dart';
import '../../data_models/user.dart';

class PinEditPage extends StatefulWidget {
  final bool isNew;
  final Location locationSuggestion;
  final Pin oldPin;

  PinEditPage({this.oldPin, this.locationSuggestion}) : isNew = (oldPin == null) {
    //Either it is a new or an old route
    assert(!(oldPin!=null && locationSuggestion!=null));
  }


  @override
  _PinEditPageState createState() {
    _PinEditPageState state = _PinEditPageState();
    state.types = <PinType,Pair<String,bool>>{
      PinType.fountain :    Pair("fountain",false),
      PinType.picturePoint: Pair("picture",false),
      PinType.restaurant:   Pair("restaurant",false),
      PinType.restingPlace: Pair("resting place",false),
      PinType.restroom:     Pair("restroom",false),
    };
    if (!isNew) {
      for (PinType t in oldPin.types) {
        state.types[t].second = true;
      }
    }
    return state;
  }
}


class Pair<T,U> {
  T first;
  U second;
  Pair(this.first,this.second);
}

class _PinEditPageState extends State<PinEditPage> {
  //List of local Files for uploading images or strings -> URL to uploadedimage
  List<NetwOrFileImg> images = [];

  //List of types
  Map<PinType, Pair<String, bool>> types;

  //Controller for textfields
  TextEditingController descriptionController;

  Location pinLocation;

  @override
  void initState() {
    //initialize controller
    descriptionController = TextEditingController();
    if (!widget.isNew) {
      pinLocation = widget.oldPin.location;
    }

    super.initState();
  }

  Future<void> _onSave(BuildContext context) async {
    try {

      //calculate typeset
      Set<PinType> typeset = Set();
      for (PinType t in types.keys) {
        if (types[t].second) {
          typeset.add(t);
        }
      }

      String description = descriptionController.text;

      //upload all images to the cloud and delete removed ones
      List<String> urls;
      if (widget.isNew) {
        urls = await uploadCloudImages(images);
      } else {
        urls = await updateCloudImages(widget.oldPin.images, images);
      }

      print("sg1");

      //update pin/upload pin
      Pin editResult;
      if (widget.isNew){
        print("sg1a" + (pinLocation==null).toString());
        editResult = await Pin.uploadPin(pinLocation, typeset, description, urls);
        print("sg1b");
      } else {
        print("sg2a");
        await Pin.updatePin(widget.oldPin.pinID, typeset, description, urls);
        print("sg2b");
        editResult = Pin(widget.oldPin.pinID, pinLocation, urls, Pin.typenoFromSet(typeset), description);
        print("sg2c");
      }

      Navigator.pop(context, editResult);

    } catch (e) {
      
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            actions: <Widget>[
              FlatButton(
                child: Text("Ok", style: TextStyle(color: Theme.of(context).accentColor),),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
            content: Text("There was an error while uploading/updating the pin!\n"+e.toString()),
          );
        }
      );
    }

  }

  //Shows the User a dialog to pick a new image for the route
  void _showNewImageDialog(BuildContext context) {
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
          );
        }
      );
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
                  "Please log in or register to ${widget.isNew ? "create a new pin" : "edit a pin"}!"),
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
    return FutureBuilder(
      future: User.isLoggedIn,
      builder: (context, loginSnapshot) {
        bool loginstatus = false;
        if (loginSnapshot.hasData)
          loginSnapshot = loginSnapshot.data;

        if (!loginstatus) return buildWhenUserNotLoggedIn(context);

        return Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                //----->Types<-----
                Container(height: 30,),
                Text("Type(s)", style: TextStyle(fontSize: 20)),
                for (Pair<String, bool> t in this.types.values) 
                  Column(
                    children: <Widget>[
                      Container(height: 7,),
                      CheckboxListTile(
                        title:Text(t.first),
                        value: t.second,
                        onChanged: (bool value) {
                          setState(() {t.second=value;});
                        },
                      ),
                    ],
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
                              builder: (context) => EditPinLocInfoPage(this.pinLocation,(l) {
                                this.pinLocation = l;
                              })
                            ));
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width*0.7,
                            height: 50,
                            color: Theme.of(context).accentColor.withAlpha(150),
                            child: Center(
                              child: Text("set pin location", style: TextStyle(fontSize: 20),),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                //------>show map when is old pin<-----
                if (!widget.isNew)
                  Container(
                    margin: EdgeInsets.only(top: 25),
                    height: 300,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: pinLocation.toLatLng(),
                        zoom: 13
                      ),
                      markers: Set<Marker>.from(<Marker>[
                        Marker(
                          markerId: MarkerId("markerOfPinLocation"),
                          position: pinLocation.toLatLng()
                        )
                      ]),
                    ),
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
                        onTap: ()=>_onSave(context),
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

      },
    );

  }
}
