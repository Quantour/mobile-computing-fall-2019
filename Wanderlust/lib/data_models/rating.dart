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

  static Future<bool> existRating(String routeID, String userID) async {
    DocumentSnapshot ds = await Firestore.instance.collection("route").document(routeID).get();
    Map<String,Map<String,double>> ratings ={};
    var docRatings = ds["ratings"];
    docRatings.forEach((k,v) => {
      ratings[k] = {'experienceRating' : v['experienceRating'], 'difficultyRating' : v['difficultyRating']}
    });
    return ratings.containsKey(userID);
  }

  static Future<Rating> getRating(String routeID, String userID) async {
    DocumentSnapshot ds = await Firestore.instance.collection("route").document(routeID).get();
    Map ratings = ds['ratings'][userID];
    return Future.value(Rating(
      experienceRating: ratings['experienceRating'],
      difficultyRating: ratings['difficultyRating'],
      routeID: routeID,
      userID: userID
    ));
  }

  static Future<void> uploadRating(Rating rating) async {
    DocumentSnapshot ds = await Firestore.instance.collection("route").document(rating.routeID).get();
    Map ratings = ds['ratings'];
    ratings.addAll({rating.userID : {'experienceRating' : rating.experienceRating, 'difficultyRating' : rating.difficultyRating}});
    int cnt = 0; double sumExp = 0; double sumDiff = 0;
    ratings.forEach((k,v) => {
      cnt = cnt+1, sumExp = sumExp + v['experienceRating'], sumDiff = sumDiff + v['difficultyRating']
    });
    var a = Firestore.instance.collection("route").document(rating.routeID);
    a.updateData({'ratings' : ratings, 'avgRating' : (sumExp/cnt), 'avgDifficulty' : (sumDiff/cnt)});
    return Future.value();
  }

  static Future<void> updateRating(Rating rating) async {
    DocumentSnapshot ds = await Firestore.instance.collection("route").document(rating.routeID).get();
    Map ratings = ds['ratings'];
    ratings.addAll({rating.userID : {'experienceRating' : rating.experienceRating, 'difficultyRating' : rating.difficultyRating}});
    int cnt = 0; double sumExp = 0; double sumDiff = 0;
    ratings.forEach((k,v) => {
      cnt = cnt+1, sumExp = sumExp + v['experienceRating'], sumDiff = sumDiff + v['difficultyRating']
    });
    var a = Firestore.instance.collection("route").document(rating.routeID);
    a.updateData({'ratings' : ratings, 'avgRating' : (sumExp/cnt), 'avgDifficulty' : (sumDiff/cnt)});
    return Future.value();
  }

  static Future<void> deleteRating(String routeID, String userID) async {
    DocumentSnapshot ds = await Firestore.instance.collection("route").document(routeID).get();
    Map ratings = ds['ratings'];
    ratings.remove(userID);
    int cnt = 0; double sumExp = 0; double sumDiff = 0;
    ratings.forEach((k,v) => {
      cnt = cnt+1, sumExp = sumExp + v['experienceRating'], sumDiff = sumDiff + v['difficultyRating']
    });
    var a = Firestore.instance.collection("route").document(routeID);
    a.updateData({'ratings' : ratings, 'avgRating' : (sumExp/cnt), 'avgDifficulty' : (sumDiff/cnt)});
    return Future.value();
  }

}