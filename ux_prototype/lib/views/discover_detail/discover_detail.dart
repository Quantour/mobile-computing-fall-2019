
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ux_prototype/data_models/route.dart';
import 'package:ux_prototype/ui_elements/custom_button.dart';
import 'package:ux_prototype/ui_elements/image_scroller.dart';
import 'package:ux_prototype/ui_elements/route_info.dart';
import 'package:ux_prototype/util.dart';
import 'package:ux_prototype/views/current_hike/current_hike.dart';
import 'package:ux_prototype/views/edit_page/edit_page.dart';
import 'package:ux_prototype/views/master/master.dart';

class DiscoverDetail extends StatefulWidget {
  final Future<HikingRoute> route;
  final String heroTag;

  DiscoverDetail({Key key, @required this.route, this.heroTag})
   : super(key: key);

  @override
  State<DiscoverDetail> createState() {
    return _DiscoverDetailState();
  }
}

class _DiscoverDetailState extends State<DiscoverDetail> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          SafeArea(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: FloatingActionButton(
                heroTag: UUID(),
                backgroundColor: Theme.of(context).accentColor.withAlpha(200),
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Icon(Icons.arrow_back),
              )
            ),
          ),
          
          FutureBuilder(
            future: widget.route,
            builder: (c, snapshot) {
              //if hiking route not loaded or loaded woth error this shows appropiate message to user
              if (snapshot.connectionState != ConnectionState.done
                 || snapshot.hasError)
                return Container(
                  child: Center(
                    child: RouteInfo(route: widget.route, extended: false)
                  ),
                );

              //future is completed with data!
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height * 0.35,
                      child: ImageScrollerWidget(
                        imageBuilder: () => snapshot.data.images,
                        heroTag: widget.heroTag==null?UUID():widget.heroTag,
                      )
                    ),
                    SingleChildScrollView(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          CustomButton(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.all(8),
                            color: CurrentHike.isActive?Colors.grey:null,
                            text: "Start",
                            child: Icon(Icons.play_arrow, color: CurrentHike.isActive?Colors.grey:Theme.of(context).accentColor, size: 18,),
                            onPressed: () {
                              if (CurrentHike.isActive) {
                                showDialog(
                                  context: context,
                                  child: AlertDialog(
                                    content: Text("Please stop current active hike before starting a new one!"),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text("Ok"),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      )
                                    ],
                                  )
                                );
                              } else {
                                Navigator.pop(context);
                                CurrentHike.setActiveWithRoute(snapshot.data);
                                MasterView.navigate(MasterView.CURRENT_HIKE);
                              }
                            },
                          ),
                          CustomButton(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.all(8),
                            text: "Rate",
                            child: Icon(Icons.rate_review, color: Theme.of(context).accentColor, size: 18,),
                            onPressed: () {
                              
                            },
                          ),
                          CustomButton(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.all(8),
                            text: "Edit",
                            child: Icon(Icons.edit, color: Theme.of(context).accentColor, size: 18,),
                            onPressed: () {
                              widget.route.then((route){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => HikeEditPage(oldroute: route)),
                                );
                              });
                            },
                          )
                        ],
                      ),
                    ),
                    RouteInfo(route: widget.route, extended: true,)
                  ],
                ),
              );
            }
          )          
        ].reversed.toList(),
      ),
    );
  }

}

