import 'package:Wanderlust/ui_elements/waves_background.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../data_models/auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _password;
  String _email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          //WavesBackground(3, MediaQuery.of(context).size),
          WavesBackground(),
          SingleChildScrollView(
            child: Form(
              key: _formKey,

            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.width * 0.05,
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.15),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.width * 0.4,
                    child: Image.asset("assets/images/logo_500.png",
                        fit: BoxFit.contain),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.width * 0.15,
                ),

                //Username
                Container(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text("Email", style: TextStyle(color: Colors.white,fontSize: 24)),
                ),
                Container(
                  width: MediaQuery.of(context).size.width*0.83,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: Colors.white
                  ),
                  child: TextFormField(
                    onSaved: (value) => _email = value,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 22,
                        color: Colors.black
                    ),
                  ),
                ),


                //Password
                Container(
                  padding: EdgeInsets.only(bottom: 10, top: 40),
                  child: Text("Password", style: TextStyle(color: Colors.white,fontSize: 24)),
                ),
                Container(
                  width: MediaQuery.of(context).size.width*0.83,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: Colors.white
                  ),
                  child: TextFormField(
                    onSaved: (value) => _password = value,
                    //keyboardType: TextInputType.emailAddress,
                    obscureText: true,
                    style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 22,
                        color: Colors.black
                    ),
                  ),
                ),

                //Login and go back button
                Container(
                  width: MediaQuery.of(context).size.width*0.83,
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Row(

                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30),
                                topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
                            color: Colors.white
                        ),
                        child: FlatButton(
                          child: Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15,)),
                          onPressed: (){Navigator.pop(context);},
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(topRight: Radius.circular(30), bottomRight: Radius.circular(30),
                                  topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)),
                              color: Colors.white
                          ),
                          child: FlatButton(
                            child: Text("Login", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                            onPressed: () async {
                              // save the fields..
                              final form = _formKey.currentState;
                              form.save();

                              // Validate will return true if is valid, or false if invalid.
                              if (form.validate()) {
                                try {
                                  FirebaseUser result =
                                  await Provider.of<AuthService>(context).loginUser(
                                      email: _email, password: _password);
                                  print(result);
                                  Navigator.pop(context);
                                } on AuthException catch (error) {
                                  return _buildErrorDialog(context, error.message);
                                } on Exception catch (error) {
                                  return _buildErrorDialog(context, error.toString());
                                }
                              }
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
          )
        ],
      ),
    );
  }
  Future _buildErrorDialog(BuildContext context, _message) {
    return showDialog(
      builder: (context) {
        return AlertDialog(
          title: Text('Error Message'),
          content: Text(_message),
          actions: <Widget>[
            FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ],
        );
      },
      context: context,
    );
  }
}
