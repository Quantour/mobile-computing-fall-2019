import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ux_prototype/data_models/route.dart';
import 'package:ux_prototype/ui_elements/buttom_navigation.dart';
import 'package:ux_prototype/views/current_hike/current_hike.dart';
import 'package:ux_prototype/views/discover/filter_drawer.dart';
import 'package:ux_prototype/views/discover/search_result_card.dart';
import 'package:ux_prototype/views/discover_detail/discover_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_bar.dart';
import 'search_text_input.dart';

class SearchScreenWidget extends StatefulWidget {
  
  SearchScreenWidget({Key key}) : super(key: key);

  @override
  State<SearchScreenWidget> createState() {
    return _SearchScreenWidgetState();
  }
}

class _SearchScreenWidgetState extends State<SearchScreenWidget> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  
  @override
  Widget build(BuildContext context) {
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
                for (var i = 0; i < 2; ++i)
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
                    route: HikingRoute.fromID("$i ROUTE")
                  )
              ]

            ),
          )

        ],
      ),
      
      bottomNavigationBar: CommonNavBar(
        currentIndex: CommonNavBar.DISCOVER,
        onTap: (int index) {
          if (index == CommonNavBar.CURRENT_HIKE) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CurrentHike()),
            );
          }
        },
      ),
      
    );
  }

}
