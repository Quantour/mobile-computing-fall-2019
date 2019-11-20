class Rating {

  double experienceRating;
  double difficultyRating;
  String routeID;
  String userID;

  static Future<bool> existRating(String routeID, String userID) {
    return Future.value(false);
  }

  static Future<Rating> getRating(String routeID, String userID) {
    return Future.value(null);
  }

  static Future<void> createRating(Rating rating) {
    return Future.value();
  }

  static Future<void> deleteRating(String routeID, String userID) {
    return Future.value();
  }

}