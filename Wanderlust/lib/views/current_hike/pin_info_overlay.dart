

import 'package:Wanderlust/data_models/pin.dart';
import 'package:flutter/material.dart';

class PinInfoOverlay extends StatefulWidget {
  PinInfoOverlay({Key key}) : super(key: key);

  final _PinInfoOverlayState _state = _PinInfoOverlayState();

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

  Widget _buildInfoBoxContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: _onPop, //dismiss this box
            child: Icon(Icons.close, size: 30, color: Theme.of(context).accentColor,),
          )
        ],
      ),
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
                    child: pin==null?Container():_buildInfoBoxContent(context),
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