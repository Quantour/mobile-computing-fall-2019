
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

//build functionality for loading images

class ImageScrollerWidget extends StatefulWidget {
  final List<String> Function() imageBuilder;
  final String heroTag;

  ImageScrollerWidget({this.heroTag, this.imageBuilder});

  @override
  State<StatefulWidget> createState() {
    return _ImageScrollerWidgetState();
  }

}

class _ImageScrollerWidgetState extends State<ImageScrollerWidget> {
  
  @override
  Widget build(BuildContext context) {
    List<String> images = widget.imageBuilder();
    return Hero(
      tag: widget.heroTag==null?UniqueKey().toString():widget.heroTag,
      child: ListView.builder(
        padding: EdgeInsets.all(0),
        scrollDirection: Axis.horizontal,
        itemCount: images==null?0:images.length,
        itemBuilder: (BuildContext context, int index) {
          double conatinerWidth;
          if (images.length < 2)
            conatinerWidth = MediaQuery.of(context).size.width * 1;
          else
            conatinerWidth = MediaQuery.of(context).size.width * 0.8;
          double margin = 5.0;
          if (index == images.length-1) margin = 0;
          return Container(
            width: conatinerWidth,
            child: Card(
              margin: EdgeInsets.fromLTRB(0, 0, margin, 0),
              color: Colors.grey,
              child: Container(
                child: Stack(
                  fit: StackFit.passthrough,
                  children: <Widget>[
                    Center(child: CircularProgressIndicator()),
                    FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: images[index],
                      fit: BoxFit.cover,
                    )
                  ],
                )
              ),
            ),
          );
        },
      )
    );
  }
}

/*
class ImageScrollerWidget extends StatelessWidget {
  static const int FROM_ASSET = 0;
  static const int FROM_NETWORK = 1;
  final int _source;
  final List<String> _ressource;
  final Axis _scrollDirection;
  final String heroTag;

  ImageScrollerWidget(
    {Iterable<String> rsc,
     int          source = FROM_NETWORK,
     Axis scrollDirection = Axis.horizontal,
     this.heroTag})

    : _source = source,
      _ressource = rsc.toList(),
      _scrollDirection = scrollDirection {
    if (source != FROM_ASSET && source != FROM_NETWORK)
     throw ArgumentError("ImageScrollerWidget: source argument must be either 0 or 1");
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: ListView.builder(
        padding: EdgeInsets.all(0),
        scrollDirection: _scrollDirection,
        itemCount: _ressource.length,
        itemBuilder: (context, index) {
          Widget imgWidget;
          if (_source == FROM_ASSET)
            imgWidget = Image.asset(_ressource[index], fit: BoxFit.cover);
          else /*if (_source == FROM_NETWORK)*/
          //TODO Network-geladene Images funktionieren noch nicht
            imgWidget = Stack(
              fit: StackFit.expand,
              children: <Widget>[
                //Center(child: CircularProgressIndicator()),
                FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: _ressource[index],
                  fit: BoxFit.cover,
                )
              ]
            );
          double conatinerWidth;
          if (_ressource.length < 2)
            conatinerWidth = MediaQuery.of(context).size.width * 1;
          else
            conatinerWidth = MediaQuery.of(context).size.width * 0.8;
          double margin = 5.0;
          if (index == _ressource.length-1) margin = 0;
          return Container(
            //margin: EdgeInsets.all(0),
            width: conatinerWidth,
            child: Card(
              margin: EdgeInsets.fromLTRB(0, 0, margin, 0),
              color: Colors.grey,
              child: Container(
                //margin: EdgeInsets.all(0),
                child: imgWidget,
              ),
            ),
          );
        }
      ),
    );
  }

}*/