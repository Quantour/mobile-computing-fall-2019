
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ux_prototype/data_models/route.dart';
import 'package:ux_prototype/ui_elements/custom_button.dart';
import 'package:ux_prototype/ui_elements/image_scroller.dart';
import 'package:ux_prototype/ui_elements/route_info.dart';

class DiscoverDetail extends StatefulWidget {
  final HikingRoute route;
  final String heroTag;

  DiscoverDetail({Key key, @required this.route, this.heroTag}) : super(key: key);

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
                backgroundColor: Theme.of(context).accentColor.withAlpha(200),
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Icon(Icons.arrow_back),
              )
            ),
          ),
          
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  child: ImageScrollerWidget(
                    imageBuilder: () => widget.route.images,
                    heroTag: widget.heroTag==null?UniqueKey().toString():widget.heroTag,
                  )
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: CustomButton(
                        text: "Start this route",
                        onPressed: () {
                          
                        },
                      ),
                    )
                  ],
                ),
                RouteInfo(route: widget.route, extended: true,)
              ],
            ),
          ),
        ].reversed.toList(),
      ),
    );
  }

}

