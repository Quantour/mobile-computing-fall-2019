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
        title: Text("Hike History"),
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
          return FutureBuilder<List<Hike>>(
            future: Hike.getCurrentUserHistory(),
            builder: (context, snapshot) {
              //<------- no data yet ----->
              if (snapshot.connectionState!=ConnectionState.done)
                return Center(
                  child: CircularProgressIndicator(),
                );
              
              //<------- error  ----->
              if (!snapshot.hasData)
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
                        child: Text("Please log in or register to view your hike history!"),
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