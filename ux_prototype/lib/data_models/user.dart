
Map<String, User> _localMirroredData = Map();

/**
 * User has following (public) data
 * userID: String
 * profilePicture: String (URL to Image)
 * name: String
 * expertise: int (from 1 to 5)
 */
class User {
  User._(String id): userID = id;

  final String userID;
  String get   profilePicture => "https://cdn.business2community.com/wp-content/uploads/2017/08/blank-profile-picture-973460_640.png";
  String get   name => "John Doe";  
  int get      expertise => 2;

  static User fromID(String userID) {
    if (_localMirroredData.containsKey(userID))
      return _localMirroredData[userID];
    User u = User._(userID);
    _localMirroredData[userID] = u;
    return u;
  }


}