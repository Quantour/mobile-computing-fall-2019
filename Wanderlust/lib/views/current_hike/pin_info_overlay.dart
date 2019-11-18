

import 'package:Wanderlust/data_models/pin.dart';
import 'package:Wanderlust/ui_elements/image_scroller.dart';
import 'package:flutter/material.dart';

class PinInfoOverlay extends StatefulWidget {
  PinInfoOverlay({Key key, this.onDelete, this.onEdit}) : super(key: key);

  final void         Function(Pin pin) onDelete;
  //return edited pin or error is this window should close
  final Future<Pin> Function(Pin pin) onEdit;
  final _PinInfoOverlayState _state = _PinInfoOverlayState();

  Pin get currentPin => _state.pin;

  @override
  _PinInfoOverlayState createState() => _state;

  void show(Pin pin) {
    _state.setPin(pin);
  }

  void discard() {
    show(null);
  }
}

class _PinInfoOverlayState extends State<PinInfoOverlay> {
  Pin pin;
  static const Duration animation_duration = const Duration(milliseconds: 500);

  void setPin(Pin p) {
    setState(() {
      pin = p;
    });
  }

  Future<bool> _onPop() async {
    if (pin == null) {
      return true;
    } else {
      Future.delayed(animation_duration).then((evt) {
        setPin(null);
      });
      return false;
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      child: AlertDialog(
        content: Text("Are you sure you want to delete this pin?"),
        actions: <Widget>[
          FlatButton(
            child: Text("yes", style: TextStyle(color: Theme.of(context).accentColor),),
            onPressed: () {
              Navigator.pop(context);
              _onPop();
              if (widget.onDelete!=null)
                widget.onDelete(pin);
            }
          ),
          FlatButton(
            child: Text("no", style: TextStyle(color: Theme.of(context).accentColor),),
            onPressed: ()=>Navigator.pop(context),
          )
        ],
      )
    );
  }

  Widget _buildInfoBoxContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                onTap: _onPop, //dismiss this box
                child: Icon(Icons.close, size: 30, color: Theme.of(context).accentColor,),
              ),
              Row(
                children: <Widget>[
                  GestureDetector(//Delete
                    onTap: ()=>_showDeleteDialog(context),
                    child: Icon(Icons.delete, size: 20, color: Theme.of(context).accentColor,),
                  ),
                  SizedBox(width: 10,),
                  GestureDetector(//Edit
                    onTap: () {
                      if (widget.onEdit!=null)
                        widget.onEdit(pin)
                          .then((pin) {
                            if (pin == null)
                              _onPop();
                            else
                              setPin(pin);
                          })
                          .catchError((error) => _onPop());
                    }, 
                    child: Icon(Icons.edit, size: 20, color: Theme.of(context).accentColor,),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: <Widget>[
              if (pin.images.length>0)
                Container(
                  height: 200,
                  child: ImageScrollerWidget(
                    imageBuilder: ()=>pin.images,
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wrap(
                      children: pin.types.map((t) {
                        String txt;
                        switch (t) {
                          case PinType.fountain:
                            txt = "fountain"; break;
                          case PinType.picturePoint:
                            txt = "pictures"; break;
                          case PinType.restaurant:
                            txt = "restaurant"; break;
                          case PinType.restingPlace:
                            txt = "resting"; break;
                          case PinType.restroom:
                            txt = "restroom"; break;
                          default: 
                        }
                        return Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Chip(
                            backgroundColor: Theme.of(context).accentColor,
                            label: Text(txt, style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),),
                          ),
                        );
                      }).toList()
                    ),
                    SizedBox(height: 5,),
                    Text("Description", style: TextStyle(fontSize: 20),),
                    SizedBox(height: 8,),
                    if (pin.description == null || pin.description.length==0)
                      Text(
                        "There is no description for this pin so far. Be the first and let people know what to find here!",
                        style:  TextStyle(color: Colors.grey),
                      )
                    else
                      Text(pin.description)
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onPop,
      child: AnimatedPositioned(
        right: pin==null?(-MediaQuery.of(context).size.width):0,
        duration: animation_duration,
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 20, right: 20),
                child: Container(
                  width: MediaQuery.of(context).size.width*0.65,
                  height: MediaQuery.of(context).size.height-230,
                  child: Card(
                    margin: const EdgeInsets.all(0),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))
                    ),
                    elevation: 7,
                    clipBehavior: Clip.hardEdge,
                    child: AnimatedSwitcher(
                      duration: animation_duration,
                      child: pin==null?Container(
                        child: Center(
                          child: Text("No pin selected.\nthis should only show when debugging"),
                        ),
                      ):_buildInfoBoxContent(context),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}