

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Color color;
  final void Function() onPressed;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Widget child;
  const CustomButton({this.margin = const EdgeInsets.fromLTRB(40, 10, 40, 10), this.child, this.color, this.onPressed, this.padding, this.text, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color = this.color==null?Theme.of(context).accentColor:this.color;
    return Container(
      padding: this.padding==null?const EdgeInsets.all(0):this.padding,
      child: RaisedButton(
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(18.0),
            side: BorderSide(color: color, width: 4)
        ),
        padding: this.margin,
        child: Row(
          children: <Widget>[
            Text(
              this.text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16
              )
            ),
            if (this.child != null)
              this.child
          ],
        ),
        onPressed: this.onPressed,
      ),
    );
  }
}