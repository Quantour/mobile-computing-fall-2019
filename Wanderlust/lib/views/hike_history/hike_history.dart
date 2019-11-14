import 'package:Wanderlust/data_models/hike.dart';
import 'package:Wanderlust/data_models/user.dart';
import 'package:Wanderlust/views/hike_history/hike_card.dart';
import 'package:flutter/material.dart';

class HikeHistory extends StatefulWidget {
  HikeHistory({Key key}) : super(key: key);

  @override _HikeHistoryState createState() => _HikeHistoryState();
}

class _HikeHistoryState extends State<HikeHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("Hike History"),
        )
      ),

      body: Builder(
        builder: (context) {
          //<------- Build this when User is not logged in and no history data can be shown ----->
          if (!User.isLoggedIn)
            return Center(
              child: Column(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height * 0.3,
                  ),
                  Center(
                    child: Icon(
                      Icons.error,
                      size: 40,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                  Container(
                    height: 20,
                  ),
                  Center(
                    child: Text(
                        "Please log in or register to view your hike history!"),
                  )
                ],
              ),
            );

          //<------- Build this when User IS logged in ----->
          //########################################################
          //##
          //##
          //TODO: use stream of firebase instead...
          //##
          //##
          //########################################################
          return StreamBuilder<List<Hike>>(
            stream: Hike.DEBUGgetCurrentUserHistory(),
            builder: (context, snapshot) {
              //<------- no data yet ----->
              if (!snapshot.hasData && !snapshot.hasError)
                return Center(
                  child: CircularProgressIndicator(),
                );
              
              //<------- error  ----->
              if (snapshot.hasError)
                return Center(
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height * 0.3,
                      ),
                      Center(
                        child: Icon(
                          Icons.error,
                          size: 40,
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                      Container(
                        height: 20,
                      ),
                      Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width*0.7,
                          child: Text("Please log in or register to view your hike history!", textAlign: TextAlign.center,)
                        ),
                      )
                    ],
                  ),
                );

              //<------- We have User history at this point ----->
              return ListView(
                children: snapshot.data.map((hike) => HikeCard(hike: hike)).toList(),
              );

            },
          );
        },
      ),
    );
  }

}