import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FilterDrawer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FilterDrawerState();
  }
}

class _FilterDrawerState extends State<FilterDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[

          DrawerHeader(
            child: Text('Add filter functionality to this'),
            decoration: BoxDecoration(
              color: Theme.of(context).accentColor,
            ),
          ),
          ListTile(
            title: Text('Item 1'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Item 2'),
            onTap: () {
              Navigator.pop(context);
            },
          ),

        ],
      )
    );
  }
}

