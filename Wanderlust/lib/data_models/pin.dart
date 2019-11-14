
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Wanderlust/data_models/location.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Map<String, Pin> _localMirroredData = Map();

enum PinType {
  picturePoint, 
  fountain, 
  restroom, 
  restaurant, 
  restingPlace
}

class Pin {

  final String      pinID;
  final Location    location;
  final List images;
  final int typeno;
  String docID;

  Pin(this.pinID, this.location, this.images, this.typeno);
  Set<PinType> get types {
      List typesList = [];
      if((this.typeno&1)!=0) typesList.add(PinType.picturePoint);
      if((this.typeno&3)!=0) typesList.add(PinType.fountain);
      if((this.typeno&7)!=0) typesList.add(PinType.restroom);
      if((this.typeno&15)!=0) typesList.add(PinType.restaurant);
      if((this.typeno&31)!=0) typesList.add(PinType.restingPlace);
      return typesList.toSet();
  }
/*
  static List<Pin> fromArea(double currentLatitude, double currentLongitude) {
    CollectionReference col = Firestore.instance.collection('pin');
    Query maxLatQuery = col.where('latitude', isLessThan: (currentLatitude+0.01));
    Query minLatQuery = maxLatQuery.where('latitude', isGreaterThan: (currentLatitude-0.01));
    Query maxLongQuery = minLatQuery.where('longitude', isLessThan: (currentLongitude+0.01));
    Query minLongQuery = maxLongQuery.where('longitude', isGreaterThan: (currentLongitude-0.01));
    return <Pin>[
      //...
    ];
  }
*/
  void addtoDatabase(){
    var a = Firestore.instance.collection("pin").document(); docID = a.documentID;
    a.setData({'pinID' : pinID, 'latitude' : location.latitude, 'longitude' : location.longitude, 'typeno' : typeno, 'images' : images});
  }

  void removefromDatabase(){
    Firestore.instance.collection('pin').document(docID).delete();
  }

  static final Map<int, String> pinAsssetPaths = {
    PinType.fountain.index:     "assets/images/pins/1.png",
    PinType.picturePoint.index: "assets/images/pins/2_medium.png",
    PinType.restaurant.index:   "assets/images/pins/3.png",
    PinType.restingPlace.index: "assets/images/pins/4.png",
    PinType.restroom.index:     "assets/images/pins/5.png",
    (-1):                       "assets/images/pins/6.png",
  };
  /**
   * Loads the Bitmap descriptor for the pins in the google map
   */
  static Future<Map<int, BitmapDescriptor>> loadPinBitmapDescriptor(BuildContext context) async {
    Map<int, BitmapDescriptor> descriptors = Map();
    
    //This loads the pins from assets
    //we dont use BitmapDescriptor.fromAssetImage because this 
    //throws no error if it cannot load the asset file which leads
    //the google map plugin to crash
    for (int type in PinType.values.map((t)=>t.index).toList()..add(-1)) {
      descriptors[type] = BitmapDescriptor.fromBytes(
        (await rootBundle.load(pinAsssetPaths[type])).buffer.asUint8List()
      );
    }
  
    return descriptors;
  }

}