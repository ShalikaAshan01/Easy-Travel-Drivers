import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csse/views/home.dart';
import 'package:csse/views/map.dart';
import 'package:csse/views/qr_scanner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix1;

class MyBottomNavigationBar extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _NavigationBarState();
  }

}

class _NavigationBarState extends State<MyBottomNavigationBar>{
  //TODO add bus id
  final String busRef = "r1zQyo9NkcKj7cqkv91X";
  int _selectedIndex = 0;
  bool validTurn = true;
  DocumentReference turnRef;
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static  List<Widget> _widgetOptions = <Widget>[
    Home()
    ,
    MyMap(),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
  ];

  @override
  void initState() {
    super.initState();
    checkTurn();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Easy Travel Drivers"),
        actions: <Widget>[
          PopupMenuButton(
            itemBuilder: (BuildContext context){
              return [
                PopupMenuItem(
                  child:GestureDetector(
                    onTap: (){
                      setState(() {
                        showAlert();
                      });
                    },
                    child: Container(
                      child: Row(
                        children: <Widget>[
                          Text(validTurn ? "Update Turn" : "Add New Turn")
                        ],
                      ),
                    ),
                  ),
                )
              ];
            },
          )
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            title: Text('Business'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            title: Text('School'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => QrScanner()));
        },
        label: Text("Scan"),
        icon: Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void showAlert(){
    // set up the button
    checkTurn();
    Widget yesButton = FlatButton(
      child: Text("Yes",style: TextStyle(color: Colors.green),),
      onPressed: () {
        Widget simpleDialog = SimpleDialog(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Center(child: CircularProgressIndicator()),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Please wait...",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              )
            ]);
        setState(() {
          Navigator.pop(context);
          if(validTurn){
            showDialog(context: context, builder: (context) {
              return simpleDialog;
            });
            Firestore.instance.collection('turns').document(turnRef.documentID)
                .updateData({
              "endTime":DateTime.now(),
              "status":"completed",
            }).then((_){
              Navigator.pop(context);
              validTurn = false;
            });
          }else{
            showDialog(context: context, builder: (context) {
              return simpleDialog;
            });
            Firestore.instance.collection('turns').add({
              "bus":busRef,
              "startTime":DateTime.now(),
              "status":"started",
              "passengers": []
            }).then((DocumentReference docRef){
              Navigator.pop(context);
              turnRef = docRef;
              validTurn = true;
            });
          }
        });
      },
    );
    Widget noButton = FlatButton(
      child: Text("No",style: TextStyle(color: Colors.redAccent)),
      onPressed: () {
        setState(() {
          Navigator.pop(context);
        });
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(validTurn?"Finish Turn":"Add New Turn"),
      content: Text(validTurn?"Are you sure you want to finish this turn?":"Are you sure you want to add new turn?"),
      actions: [
        noButton,
        yesButton
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void checkTurn(){
    Firestore.instance.collection("turns")
        .where('bus',isEqualTo: busRef)
        .where('status',isEqualTo: 'started')
        .limit(1).getDocuments().then((QuerySnapshot snapshot){
          debugPrint(snapshot.documents.length.toString());
          if(snapshot.documents.length == 0){
            validTurn = false;
          }else{
            validTurn = true;
            turnRef = snapshot.documents.removeLast().reference;
          }
    });
  }
}