
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
  String get   profilePicture => "https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80";
  String get   name => "John Doe";  
  int get      expertise => 2;

  static Future<User> fromID(String userID) {
    if (_localMirroredData.containsKey(userID))
      return Future.delayed(Duration(seconds: 3),()=>_localMirroredData[userID]);
    User u = User._(userID);
    _localMirroredData[userID] = u;
    return Future.delayed(Duration(seconds: 3),()=>u);
  }

  static User get currentUser {
    return User._("Id");
  }

  static bool get isLoggedIn {
    return _login_status;
  }

  //<REMOVE THIS> for UI debug purposes
  static bool _login_status = true;
  static set isLoggedIn(bool status) => _login_status = status;
  //</REMOVE THIS>
}