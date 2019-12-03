
//Map<String, User> _localMirroredData = Map();

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/**
 * User has following (public) data
 * userID: String
 * profilePicture: String (URL to Image)
 * name: String
 * expertise: int (from 1 to 5)
 */
class User {
  //User._(String id): userID = id;

  /*final String userID;
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
  */

  //neccessary to let it in the code, so the UI displays the data right,
  //just let it be with mockup data until ou have implemented it
//  String get   profilePicture => "https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80";
  String get profilePicture {
    Future<User> curUser() async {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      return User(user.displayName,user.uid);
    }
    String ret = "";
    curUser().then((value){
      Firestore.instance.collection("user").document(value.ID).get().then((DocumentSnapshot ds) async {
        if(ds.exists) ret = ds['profileURL']; 
      });
    });
    return ret;
  }
  //mockup needed for UI until implemented
  static User get currentUser {
    Future<User> curUser() async {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      return User(user.displayName,user.uid);
    }
    User ret;
    curUser().then((value){
      ret = User(value.name, value.ID);
    });
    return ret;
  }

  //This function is neccessary, so that the User can be loaded and shown
  //for route information widget(creator of the route)
  //Just let it be with mockup data for this time until you implemented it
  static Future<User> fromID(String i) {
    Firestore.instance.collection("user").document(i).get().then((DocumentSnapshot ds) async {
        if(!ds.exists) return Future.value(null);
        else {
          return Future.value(User(ds["userID"],ds["username"]));
        }
    });
  }

  /*
   * This Method can update the profile picture of a User!
   */
  static Future<void> updateProfilePicture(String userID, String pictureURL) {
    var a = Firestore.instance.collection("user").document(userID); 
    a.updateData({'pictureURL' : pictureURL });
    return Future.value();
  }

  String name;
  String ID;
  User(this.name,this.ID);

  String get getID{
    return ID;
  }
  String get getName{
    return name;
  }

  static bool get isLoggedIn {
    return _login_status;
  }

  //<REMOVE THIS> for UI debug purposes
  static bool _login_status = true;
  static set isLoggedIn(bool status) => _login_status = status;
  //</REMOVE THIS>
}


