import 'dart:math' as Math;

import 'package:flutter/cupertino.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const double _pi = 3.1415926535897932385;

double _degreesToRadians(double degree) {
  return degree * _pi / 180;
}

/**
 * The Location class holds latitude and longitude information
 * abaout an geographic position. it can also calculate the
 * distance between two geographic positions and calculates the
 * midpoint of a list of positions.
 */
class Location {
  final double latitude, longitude;
  Location(double latitude, double longitude): 
    this.latitude = latitude, this.longitude = longitude;

  //TODO: Check/test if correct or use library
  //source: https://stackoverflow.com/questions/837872/calculate-distance-in-meters-when-you-know-longitude-and-latitude-in-java
  /** Calculates distance of two coordinate points in meter */
  static int distance(Location a, Location b) {
    const double earthRadius = 6371000; //in meter
    double diffLat = _degreesToRadians(b.latitude -a.latitude);
    double diffLng = _degreesToRadians(b.longitude-a.longitude);
    
    double d =    Math.pow(Math.sin(diffLat/2), 2.0)
                + Math.cos(_degreesToRadians(a.latitude)) * Math.cos(_degreesToRadians(b.latitude))
                  * Math.pow(Math.sin(diffLng/2), 2.0);
    double c = 2 * Math.atan2(Math.sqrt(d), Math.sqrt(1-d));
    int meterDist = (earthRadius * c).round();
    return meterDist;
  }

  /** Calculates distance of two coordinate points in meter */
  int distanceTo(Location b) => Location.distance(this, b);

  //TODO: Check/test if correct or use library
  //source: http://www.geomidpoint.com/calculation.html
  static Location average(List<Location> locations) {
    if (locations == null) throw NullThrownError();
    //TODO: implement and test this method
    
    List<double> la = locations.map((p) => p.latitude).toList();
    List<double> lo = locations.map((p) => p.longitude).toList();
    return Location((la.reduce(Math.min) + la.reduce(Math.max))/2, (lo.reduce(Math.min) + lo.reduce(Math.max))/2);

    List<List<double>> radLatLong = locations.map(
      (l) => [_degreesToRadians(l.latitude), _degreesToRadians(l.longitude)]
    ).toList();

    List<double> xs = radLatLong.map(
      (c) => Math.cos(c[0]) + Math.cos(c[1])).toList();
    List<double> ys = radLatLong.map(
      (c) => Math.sin(c[0]) + Math.sin(c[1])).toList();
    List<double> zs = radLatLong.map(
      (c) => Math.sin(c[0])).toList();
    
    double sumX = xs.reduce((x1,x2)=>x1+x2);
    double avgX = sumX / xs.length;

    double sumY = ys.reduce((y1,y2)=>y1+y2);
    double avgY = sumY / ys.length;

    double sumZ = zs.reduce((z1,z2)=>z1+z2);
    double avgZ = sumZ / zs.length;

    double lon = Math.atan2(avgY, avgX);
    double hyp = Math.sqrt(avgX * avgX + avgY * avgY);
    double lat = Math.atan2(avgZ, hyp);

    lat = lat * 180/_pi;
    lon = lon * 180/_pi;

    return Location(lat,lon);
  }

  //Calculates the zoom level for the map, if the whole route is to be presented on the map
  //zoom level 0: Whole world map
  //zoom level n+1: doubles the length factor
  //Google map is designed to be 256 pixels wide/heigh, adjust for actual size
  static double calculateMapsZoomLevel(List<Location> route, Size mapSize) {
    //how much inwards space must there be on the map between outermost location
    //in route list and border of the map?
    const double FACTOR = 0.85;
    const double GLOBE_WIDTH = 256;

    //<Calculate zoom level to fit longitude bounds!>
    List<double> longitudes = route.map((l)=>l.longitude).toList();
    double minLng = longitudes.fold(longitudes[0], Math.min);
    double maxLng = longitudes.fold(longitudes[0], Math.max);
    double angleLng = maxLng - minLng;
    if (angleLng < 0) angleLng += 360;
    double lngZoom = Math.log(mapSize.width * 360.0 / angleLng / GLOBE_WIDTH) / Math.ln2;
    
    //<calculate zoom level to fit latitude bounds>
    List<double> latitudes = route.map((l)=>l.latitude).toList();
    double minLat = latitudes.fold(latitudes[0], Math.min);
    double maxLat = latitudes.fold(latitudes[0], Math.max);
    double midAngle = (maxLat+minLat)/2;
    //alpha is total angle distance of alpha AND beta to midangle
    double alpha  = maxLat-midAngle;
    //Projection screen is orthogonal to vector with angle midAngle
    //portion of horizontal scale:
    double yPortion = Math.sin(alpha*Math.pi/180) / 2;
    double latZoom = Math.log(mapSize.height / GLOBE_WIDTH / yPortion) / Math.ln2;
    
    //return min (max zoom) of both zoom levels
    double zoom = Math.min(lngZoom, latZoom);
    //"multiply" factor to zoom factor in *linear scale*
    //The following is this calculation simplified
    double adjustedZoom = (Math.log(FACTOR) / Math.ln2) + zoom;
    return adjustedZoom;
  }

  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }

  Coordinates toCoordinates() {
    return Coordinates(latitude, longitude);
  }

/*
  static LatLngBounds getLatLngBounds(List<Location> locations) {

    List<double> la = locations.map((p) => p.latitude).toList();
    List<double> lo = locations.map((p) => p.longitude).toList();
    double minLa = la.reduce(Math.min);
    double maxLa =  la.reduce(Math.max);
    double minLo = lo.reduce(Math.min);
    double maxLo =  lo.reduce(Math.max);
    
    return LatLngBounds(
      northeast: LatLng(maxLa, minLo),
      southwest: LatLng(minLa, maxLo)
    );

  }*/

}

