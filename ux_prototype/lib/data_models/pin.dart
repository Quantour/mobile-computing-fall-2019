
import 'package:ux_prototype/data_models/location.dart';

Map<String, Pin> _localMirroredData = Map();

enum PinType {
  picturePoint, 
  fountain, 
  restroom, 
  restaurant, 
  restingPlace
}

class Pin {

  Pin._(String id): pinID = id;

  final String      pinID;
  Location get      location => Location(45.521543, -122.677443);
  List<String> get  images => [];
  Set<PinType> get  types => <PinType>[PinType.restingPlace, PinType.restroom].toSet();

  static Future<Pin> fromID(String pinID) {
    if (_localMirroredData.containsKey(pinID))
      return Future.delayed(Duration(seconds: 3), ()=>_localMirroredData[pinID]);
    Pin p = Pin._(pinID);
    _localMirroredData[pinID] = p;
    return Future.delayed(Duration(seconds: 3), ()=>p);
  }

  //TODO: implement properly with server communication
  static List<Pin> fromArea(Location location, int radius) {
    return <Pin>[
      //...
    ];
  }

}