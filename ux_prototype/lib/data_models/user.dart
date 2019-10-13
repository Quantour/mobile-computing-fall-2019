
//TODO: Implement fetch from Server for User Data
class User {

  static Map<String, User> _localMirroredData = Map();

  final String userID;

  User._(String id): userID = id;

  String get profilePicture => "https://cdn.business2community.com/wp-content/uploads/2017/08/blank-profile-picture-973460_640.png";

  String get name => "John Doe";  

  static User fromID(String userID) {
    if (_localMirroredData.containsKey(userID))
      return _localMirroredData[userID];
    User u = User._(userID);
    _localMirroredData[userID] = u;
    return u;
  }


}