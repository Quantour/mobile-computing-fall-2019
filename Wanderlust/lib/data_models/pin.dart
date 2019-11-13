
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Wanderlust/data_models/location.dart';

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

}