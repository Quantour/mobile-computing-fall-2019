
import 'package:Wanderlust/ui_elements/waves_background.dart';
import 'package:flutter/material.dart';

class AccountInfoPage extends StatefulWidget {
  AccountInfoPage({Key key}) : super(key: key);

  @override
  _AccountInfoPageState createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage> {
  @override
  Widget build(BuildContext context) {
    
    return Container(
      color: Colors.white,
      child: WavesBackground(3, MediaQuery.of(context).size),
      //child: WaveBackground(wave: Wave.random(MediaQuery.of(context).size)),
    );
    
  }
}









