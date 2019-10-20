
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

  static Pin fromID(String pinID) {
    if (_localMirroredData.containsKey(pinID))
      return _localMirroredData[pinID];
    Pin p = Pin._(pinID);
    _localMirroredData[pinID] = p;
    return p;
  }

  static Set<Pin> fromArea(Location start, Location end) {
    return <Pin>[Pin.fromID("1"),Pin.fromID("2")].toSet();
  }

}