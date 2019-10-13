
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ux_prototype/data_models/route.dart';
import 'package:ux_prototype/ui_elements/image_scroller.dart';

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
                )
              ],
            ),
          ),
        ].reversed.toList(),
      ),
    );
  }

}

