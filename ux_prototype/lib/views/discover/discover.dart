import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ux_prototype/data_models/route.dart';
import 'package:ux_prototype/views/discover/discover_search_parameter.dart';
import 'package:ux_prototype/views/discover/filter_drawer.dart';
import 'package:ux_prototype/views/discover/search_result_card.dart';
import 'package:ux_prototype/views/discover_detail/discover_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ux_prototype/views/edit_page/edit_page.dart';
import '../../data_models/route.dart';
import 'app_bar.dart';
import 'search_text_input.dart';

class SearchScreenWidget extends StatefulWidget {
  
  SearchScreenWidget({Key key}) : super(key: key);

  @override
  State<SearchScreenWidget> createState() => _SearchScreenWidgetState();
}

class _SearchScreenWidgetState extends State<SearchScreenWidget> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  
  final DiscoverSearchParameter searchParameter = DiscoverSearchParameter();

  Widget _buildWithRoutes(BuildContext context, List<HikingRoute> routes) {

    return Scaffold(
      key: _scaffoldKey,
      drawer: FilterDrawer(searchParameter, () {
        //called when searchParameter is updated
        setState((){});
      }),

      body: CustomScrollView(
        slivers: <Widget>[

          DiscoverAppBar(
            controller: SearchTextInputFieldController(
              onFilterPressed: () {
                //shows onput fields for filtering 
                _scaffoldKey.currentState.openDrawer();
              },
              onTextInputChanged: (String input) {
                setState(() {
                 searchParameter.searchTerm = input;
                });
              },
              searchSuggestionBuilder: (String input) {
                return <String>[for(var i = 0; i < 10; i++) "$i"];
              }
            )
          ),

          if (routes == null)
          SliverList(
            delegate: SliverChildListDelegate(<Widget> [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height*0.4,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ]),
          ),

          if (routes != null && routes.length == 0)
          SliverList(
            delegate: SliverChildListDelegate(<Widget> [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height*0.4,
                child: Center(
                  child: Builder(
                    builder: (context) {
                      if (searchParameter.searchTerm != null && searchParameter.searchTerm != "")
                        return Text("No results found for \"${searchParameter.searchTerm}\"! \nTry update your filters.");
                      return Text("No results found! \nTry update your filters.");
                    },
                  ),
                ),
              ),
            ]),
          ),

          if (routes != null && routes.length > 0)
            SliverList(
              delegate: SliverChildListDelegate(
                
                <Widget>[
                  
                  for (HikingRoute route in routes)
                    SearchResultCardWidget(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DiscoverDetail(
                              route: Future.value(route),
                              heroTag: "${route.routeID} ROUTE"
                            ),
                          ),
                        );
                      },
                      heroTag: "${route.routeID} ROUTE",
                      route: Future.value(route)
                    )
                ]

              ),
            )

        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "FloatingActionButton:discover",
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HikeEditPage()),
          );


          //#####################################
          //##
          //TODO Create input UI for new route here for -> _onInputNewRoute(newRoute)
          //##
          //#####################################
          //...
          //_onInputNewRoute(newRoute);

          /*
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
          */
        },
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
     return StreamBuilder<QuerySnapshot>(
     stream: Firestore.instance.collection('user2').snapshots(),
     builder: (context, snapshot) {
        if (!snapshot.hasData) return _buildWithRoutes(context, null);

        List<HikingRoute> routes = [];

        //#####################################
        //##
        //TODO create list of routes here
        //## use "searchParameter" attribute of this class!
        //##
        //#####################################

        //e.g. if (searchParameter.maxMeter...)

        //if list is empty "no results found!" is shown, otherwise an CircularProgressIndicator
        return _buildWithRoutes(context, routes);
    }
   );
  }

  /**
   * This uploades a new route to the cloude
   * it will ignore route.routeID and create a new one
   * (automatic key from firebase)
   */
  void _onInputNewRoute(HikingRoute route) {
    //#####################################
    //##
    //TODO Upload new route here
    //##
    //#####################################
  }
}

