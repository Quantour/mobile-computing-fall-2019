

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final void Function() onPressed;
  const CustomButton({this.onPressed, this.text, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: RaisedButton(
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(18.0),
            side: BorderSide(color: Color.fromRGBO(244,81,30,1), width: 4)
        ),
        padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
        child: Text(
          this.text,
          style: TextStyle(
            color: Color.fromRGBO(244,81,30,1),
            fontWeight: FontWeight.bold,
            fontSize: 16
          )
        ),
        onPressed: this.onPressed,
      ),
    );
  }
}