import 'package:Wanderlust/data_models/location.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Wanderlust/data_models/route.dart';
import 'package:Wanderlust/util.dart';
import 'package:Wanderlust/views/discover/discover_search_parameter.dart';
import 'package:Wanderlust/views/discover/filter_drawer.dart';
import 'package:Wanderlust/views/discover/search_result_card.dart';
import 'package:Wanderlust/views/discover_detail/discover_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Wanderlust/views/edit_page/edit_page.dart';
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
        heroTag: UUID(),
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HikeEditPage()),
          );
          //_onInputNewRoute(newRoute);
        },
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
     return StreamBuilder<QuerySnapshot>(
     stream: Firestore.instance.collection('route').snapshots(),
     builder: (context, snapshot) {
        if (!snapshot.hasData) return _buildWithRoutes(context, null);
/*
        //for debug:
        return FutureBuilder(
          future: HikingRoute.fromID("test"),
          builder: (context, snapshot) {
            if (snapshot.hasData)
              return _buildWithRoutes(context, [snapshot.data]);
            else
              return _buildWithRoutes(context, null);
          }
        );
*/
        List<HikingRoute> routes = [];
       
        int numDocuments = snapshot.data.documents.length;
        for(int i = 0; i < numDocuments;i++){
            var doc = snapshot.data.documents[i];
            if(doc.data["avgTime"] <= searchParameter.maxMeter && doc.data["avgTime"] >= searchParameter.minMeter &&
              doc.data["avgDifficulty"] >= searchParameter.minDifficultyRating &&
              doc.data["avgRating"] >= searchParameter.minExperienceRating &&
              doc.data["title"].contains(searchParameter.searchTerm)){

                List<Location> route = [];
                var docRoute = doc.data["route"];
                for(int j = 0; j < docRoute.length; j++){
                  route.add(Location(docRoute[j]['latitude'],docRoute[j]['longitude']));
                }

                List<String> images = [];
                var docImages = doc.data["images"];
                for(int j = 0; j < docImages.length; j++){
                  images.add(docImages[j]);
                }
                Map<String,Map<String,double>> ratings ={};
                var docRatings = doc.data["ratings"];
                docRatings.forEach((k,v) => {
                  ratings[k] = {'experienceRating' : v['experienceRating'], 'difficultyRating' : v['difficultyRating']}
                });

                routes.add(HikingRoute.packInfoToObject(doc.data["routeID"], doc.data["userID"], doc.data["title"], route,
                 doc.data["timestamp"] as int, doc.data["description"], doc.data["tipsAndTricks"], images, doc.data["avgRating"],
                 doc.data["avgDifficulty"], doc.data["avgTime"], doc.data["nearestCity"], doc.data["country"], doc.data["steepness"], ratings));
            }
        }
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
    HikingRoute.uploadRoute(route.userID, route.title, route.route, route.timestamp, route.description, route.tipsAndTricks, route.images);
  }
}

