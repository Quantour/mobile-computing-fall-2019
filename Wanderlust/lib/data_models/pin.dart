
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Wanderlust/data_models/location.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum PinType {
  picturePoint, 
  fountain, 
  restroom, 
  restaurant, 
  restingPlace
}

class Pin {

  final String       pinID;
  final Location     location;
  final List<String> images;
  final String       description;
  final int typeno;

  Pin(this.pinID, this.location, this.images, this.typeno, this.description);

  Set<PinType> get types {
      List<PinType> typesList = [];
      if((this.typeno&1)!=0) typesList.add(PinType.picturePoint);
      if((this.typeno&2)!=0) typesList.add(PinType.fountain);
      if((this.typeno&4)!=0) typesList.add(PinType.restroom);
      if((this.typeno&8)!=0) typesList.add(PinType.restaurant);
      if((this.typeno&16)!=0) typesList.add(PinType.restingPlace);
      return typesList.toSet();
  }

  static int typenoFromSet(Set<PinType> types) {
    int ret = 0;
    types.forEach((element) => {
      if(element == PinType.picturePoint) ret = (ret+1),
      if(element == PinType.fountain)     ret = (ret+2),
      if(element == PinType.restroom)     ret = (ret+4),
      if(element == PinType.restaurant)   ret = (ret+8), 
      if(element == PinType.restingPlace) ret = (ret+16)
    });
    return ret;
  }

  //deltes pin from the database
  static Future<void> deletePin(String id) {
    Firestore.instance.collection('pin').document(id).delete();
    return Future.value();
  }

  /* This uploades a Pin and returns the corresponding pin info
  *  Furthermore it creates an unique pin ID for the Pin!
   */
  static Future<Pin> uploadPin(Location location, Set<PinType> types, String description, List<String> images) {
    int typeno = typenoFromSet(types);
    var a = Firestore.instance.collection("pin").document(); String docID = a.documentID;
    a.setData({'pinID' : docID, 'latitude' : location.latitude, 'longitude' : location.longitude, 'typeno' : typeno, 'images' : images, 'description' : description});
    return Future.value(Pin(docID, location, images, typeno, description));
  }

  /* This updates a Pin! Location cannot be changed
   */
  static Future<void> updatePin(String pinID, Set<PinType> types, String description, List<String> images) {
    int typeno = typenoFromSet(types);
    var a = Firestore.instance.collection("pin").document(pinID); 
    a.updateData({'typeno' : typeno, 'description' : description, 'images' : images });
    return Future.value();
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

    const bool _USE_DEFAULT_PINS = true;

    if (_USE_DEFAULT_PINS) {

      descriptors[PinType.fountain.index] = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
      descriptors[PinType.picturePoint.index] = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);
      descriptors[PinType.restaurant.index] = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      descriptors[PinType.restingPlace.index] = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
      descriptors[PinType.restroom.index] = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      descriptors[(-1)] = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta);

      return descriptors;

    }

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