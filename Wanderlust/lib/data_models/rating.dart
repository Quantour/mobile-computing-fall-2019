import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Rating {

  double experienceRating;
  double difficultyRating;
  String routeID;
  String userID;

  Rating({
    @required this.experienceRating,
    @required this.difficultyRating,
    @required this.routeID,
    @required this.userID
  });

  static Future<bool> existRating(String routeID, String userID) {
    Firestore.instance.collection("route").document(routeID).get().then((DocumentSnapshot ds) async {
      Map<String,Map> ratings = ds['ratings'];
      return Future.value(ratings.containsKey(userID));
    });
  }

  static Future<Rating> getRating(String routeID, String userID) {
    Firestore.instance.collection("route").document(routeID).get().then((DocumentSnapshot ds) async {
      Map ratings = ds['ratings'][userID];
      return Future.value(Rating(
        experienceRating: ratings['experienceRating'],
        difficultyRating: ratings['difficultyRating'],
        routeID: routeID,
        userID: userID
      ));
    });
    
  }

  static Future<void> uploadRating(Rating rating) {
    Firestore.instance.collection("route").document(rating.routeID).get().then((DocumentSnapshot ds) async {
      Map ratings = ds['ratings'][rating.userID];
      ratings['experienceRating'] = rating.experienceRating;
      ratings['difficultyRating'] = rating.difficultyRating;
    });
    return Future.value();
  }

  static Future<void> updateRating(Rating rating) {
    Firestore.instance.collection("route").document(rating.routeID).get().then((DocumentSnapshot ds) async {
      Map ratings = ds['ratings'][rating.userID];
      ratings['experienceRating'] = rating.experienceRating;
      ratings['difficultyRating'] = rating.difficultyRating;
    });
    return Future.value();
  }

  static Future<void> deleteRating(String routeID, String userID) {
    Firestore.instance.collection("route").document(routeID).get().then((DocumentSnapshot ds) async {
      Map<String,Map> ratings = ds['ratings'];
      ratings.remove(userID);
    });
    return Future.value();
  }

}