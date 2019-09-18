import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csse/auth/auth.dart';
import 'package:csse/views/home.dart';
import 'package:csse/views/login.dart';
import 'package:csse/views/map.dart';
import 'package:csse/views/profile.dart';
import 'package:csse/views/qr_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix1;

class MyBottomNavigationBar extends StatefulWidget{
  final BaseAuth auth;
  MyBottomNavigationBar({this.auth});
  @override
  State<StatefulWidget> createState() {
    return _NavigationBarState();
  }

}
enum AuthStatus{
  notSignedIn,
  signedIn
}

class _NavigationBarState extends State<MyBottomNavigationBar>{
  //TODO add bus id
  final String busRef = "r1zQyo9NkcKj7cqkv91X";
  DocumentReference ref;
  int _selectedIndex = 0;
  bool validTurn = true;
  DocumentReference turnRef;
  AuthStatus _authStatus = AuthStatus.notSignedIn;

  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static  List<Widget> _widgetOptions = <Widget>[
    Home(),
    MyMap(),
    Profile(),
  ];

  @override
  void initState() {
    super.initState();
    widget.auth.currentUser().then((FirebaseUser user){
      setState(() {
        _authStatus = user == null ? AuthStatus.notSignedIn: AuthStatus.signedIn;
      });
    });
    checkTurn();
    Firestore.instance
        .collection('buses')
        .document(busRef)
        .get()
        .then((DocumentSnapshot snapshot) {
      ref = snapshot.reference;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    if(_authStatus == AuthStatus.notSignedIn){
      return Login(auth: widget.auth,onSignedIn: _signedIn ,);
    }else{
      return buildScaffold();
    }
  }

  Widget buildScaffold(){
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
                ),
                PopupMenuItem(
                  child: GestureDetector(
                    onTap:(){
                      Navigator.pop(context);
                      _signOut();
                    },
                    child: Container(
                      child: Text("Sign out"),
                    ),
                  )
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

  void _signedIn(){
    setState(() {
      _authStatus = AuthStatus.signedIn;
    });
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
              "status":"previous",
            }).then((_){

              Firestore.instance.collection('rides')
              .where('bus',isEqualTo: ref)
              .where('status',isEqualTo: "ongoing")
              .getDocuments()
              .then((QuerySnapshot querySnapshot){
                var batch = Firestore.instance.batch();
                DocumentSnapshot doc;
                for(int i=0;i<querySnapshot.documents.length;i++){
                  doc = querySnapshot.documents[i];
                  batch.updateData(doc.reference, {
                    "status":"previous",
                    "endTime":DateTime.now()
                  });
                }

                batch.commit().then((_)=>Navigator.pop(context));

              });
              validTurn = false;
            });
          }else{
            showDialog(context: context, builder: (context) {
              return simpleDialog;
            });
            Firestore.instance.collection('turns').add({
              "bus":busRef,
              "startTime":DateTime.now(),
              "status":"ongoing",
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
        .where('status',isEqualTo: 'ongoing')
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
  void _signOut()async{
    try {
      await widget.auth.signOut();
      setState(() {
        _authStatus = AuthStatus.notSignedIn;
      });
    } on Exception catch (e) {
      print(e);
    }
  }
}