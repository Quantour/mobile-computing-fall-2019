import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ux_prototype/data_models/route.dart';
import 'package:ux_prototype/views/discover/filter_drawer.dart';
import 'package:ux_prototype/views/discover/search_result_card.dart';
import 'package:ux_prototype/views/discover_detail/discover_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_bar.dart';
import 'search_text_input.dart';

class SearchScreenWidget extends StatefulWidget {
  
  SearchScreenWidget({Key key}) : super(key: key);

  @override
  State<SearchScreenWidget> createState() => _SearchScreenWidgetState();
}

class _SearchScreenWidgetState extends State<SearchScreenWidget> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String routeName = 'hike';

  String hikeName;
  String description;
  String region;

//  int number_routes = 3;

  @override
  Widget build(BuildContext context) {
     return StreamBuilder<QuerySnapshot>(
     stream: Firestore.instance.collection('user2').snapshots(),
     builder: (context, snapshot) {
       int number_routes = snapshot.data.documents[0].data['number'];
       if (!snapshot.hasData) return LinearProgressIndicator();
    return Scaffold(
      key: _scaffoldKey,
      drawer: FilterDrawer(),

      body: CustomScrollView(
        slivers: <Widget>[

          DiscoverAppBar(
            controller: SearchTextInputFieldController(
              onFilterPressed: () {
                //shows onput fields for filtering 
                _scaffoldKey.currentState.openDrawer();
              },
              onSearchRequest: (String input) {

              },
              searchSuggestionBuilder: (String input) {
                return <String>[for(var i = 0; i < 10; i++) "$i"];
              }
            )
          ),

          SliverList(
            delegate: SliverChildListDelegate(
              
              <Widget>[
                
                for (var i = 0; i < number_routes; ++i)
                  SearchResultCardWidget(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DiscoverDetail(
                            route: HikingRoute.fromID("$i ROUTE"),
                            heroTag: "$i ROUTE"
                          ),
                        ),
                      );
                    },
                    heroTag: "$i ROUTE",
                    route: HikingRoute.fromID("$i ROUTE"),
                    user_idx: i
                  )
              ]

            ),
          )

        ],
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          //          Firestore.instance.collection("user").document().setData({'username' : "Paul", 'expertise' : 5, 'difficulty' : 9.8, 'region' : "Italy"});
          //          var currentLocation = location.getLocation();
          //Firestore.instance.collection("test").document(snapshot.data.documents[1].documentID).setData({'name' : 'userABC' });
          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                elevation: 16,
                child: Container(
                  height: 400.0,
                  width: 360.0,
                  child: ListView(
                    children: <Widget>[
                      SizedBox(height: 20),
                      Center(
                        child: Text(
                          "Add hiking route",
                          style: TextStyle(fontSize: 24, color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 10.0)),
                        Text('Hike Name'),

                        TextField(
                          onSubmitted:(route){
                            routeInput(route);
                            hikeName = routeName;
                          },
                        ),
                        Padding(padding: EdgeInsets.only(top: 20.0)),
                        Text('Description'),
                        TextField(
                          onSubmitted:(route){
                            routeInput(route);
                            description = routeName;
                        },
                      ),
                      Padding(padding: EdgeInsets.only(top: 20.0)),
                      Text('Region'),

                      TextField(
                        onSubmitted:(route){
                          routeInput(route);
                          region = routeName;
                          Firestore.instance.collection("hike").document().setData({'route' : hikeName, 'description' : description, 'region' : region});
                          Firestore.instance.collection("user2").document(snapshot.data.documents[0].documentID).updateData({'number' : number_routes+1});
                         // number_routes += 1;
                        },
                      )

                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
    }
   );
  }
  void routeInput(String route) {
    setState(() {
      routeName = route;
      //Firestore.instance.collection("hike").document().setData({'username' : route, 'expertise' : 5, 'difficulty' : 9.8, 'region' : "Italy"});
    });
  }
}

