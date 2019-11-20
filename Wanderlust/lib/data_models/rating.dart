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
    return Future.delayed(Duration(seconds: 2), ()=>true);
  }

  static Future<Rating> getRating(String routeID, String userID) {
    return Future.delayed(Duration(seconds: 2), ()=>Rating(
      experienceRating: 2.0,
      difficultyRating: 3.0,
      routeID: "RID",
      userID: "UID"
    ));
  }

  static Future<void> uploadRating(Rating rating) {
    return Future.delayed(Duration(seconds: 2));
  }

  static Future<void> updateRating(Rating rating) {
    return Future.delayed(Duration(seconds: 2));
  }

  static Future<void> deleteRating(String routeID, String userID) {
    return Future.delayed(Duration(seconds: 2));
  }

}