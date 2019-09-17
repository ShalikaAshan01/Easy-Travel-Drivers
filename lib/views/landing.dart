import 'package:csse/views/login.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Landing extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _LandingState();
  }

}
const brightYellow = Color(0xFFFFD300);
const darkYellow = Color(0xFFFFB900);
class _LandingState extends State<Landing>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brightYellow,
      body: Column(
        children: [
          Flexible(
            flex: 8,
            child: FlareActor(
              'assets/flare/bus.flr',
              alignment: Alignment.center,
              fit: BoxFit.contain,
              animation: 'driving',
            ),
          ),
          Flexible(
            flex: 2,
            child: RaisedButton(
              color: darkYellow,
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
              child: Text(
                'Tap here to proceed',
                style: TextStyle(color: Colors.black54),
              ),
              onPressed: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context)=>Login())
              ),
            ),
          ),
        ],
      ),
    );
  }
}