import 'dart:async';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:csse/auth/auth.dart';
import 'package:csse/utils/permissions.dart';
import 'package:csse/views/home.dart';
import 'package:csse/views/map.dart';
import 'package:csse/views/profile.dart';
import 'package:csse/views/qr_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter/services.dart';

class MyBottomNavigationBar extends StatefulWidget{
  final BaseAuth auth;
  final VoidCallback onSignOut;
  MyBottomNavigationBar({this.auth, this.onSignOut});
  @override
  State<StatefulWidget> createState() {
    return _NavigationBarState();
  }

}

class _NavigationBarState extends State<MyBottomNavigationBar>{
  String _busRef="";
  int _selectedIndex = 0;
  bool _validTurn = false;
  DocumentReference _turnRef;
  Permissions _permissions = Permissions();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool isOnline = true;

  static  List<Widget> _widgetOptions = <Widget>[
    Home(),
    MyMap(),
    Profile(),
  ];

  @override
  void initState() {
    super.initState();

    ///check connection
    initConnectivity();
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      await _updateConnectionStatus().then((bool isConnected) => setState(() {
        isOnline = isConnected;
        if (!isConnected) {
          Alert(
            context: context,
            title: "Whoops",
            desc:
            "Slow or no internet connection. Please check internet connection",
            buttons: [
              DialogButton(
                child: Text(
                  "Ok",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  AppSettings.openWIFISettings();
                },
                width: 120,
              )
            ],
          ).show();
        }
      }));
    });

    ///Check permissions

    _permissions.checkCameraPermission()
    .then((PermissionStatus permissionStatus){
      if(permissionStatus != PermissionStatus.granted){
        if(_permissions.isAndroid()){
          _permissions.checkRationaleCameraPermission()
              .then((bool has) async {
                if(!has){
                  permissionAlert("camera");
                }else{
                  _permissions.requestCameraPermission();
                }
          });
        }
        else{
          _permissions.requestCameraPermission();
        }
      }
    });
    _permissions.checkLocationPermission()
    .then((PermissionStatus permissionStatus){
      if(permissionStatus != PermissionStatus.granted){
        if(_permissions.isAndroid()){
          _permissions.checkRationaleLocationPermission()
              .then((bool has) async {
                if(!has){
                  permissionAlert("location");
                }else{
                  _permissions.requestLocationPermission();
                }
          });
        }
        else{
          _permissions.requestLocationPermission();
        }
      }
    });

    widget.auth.currentUser().then((FirebaseUser user){

      if(user != null){
        Firestore.instance.collection('inspectors').document(user.uid).get()
            .then((DocumentSnapshot  documentSnapshot){
          if(documentSnapshot.data['status']=="inactive"){
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context){
                  return AlertDialog(
                    title: Text("Unauthorized Account"),
                    content: Text("Please activate your account"),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("OK",style: TextStyle(color: Colors.redAccent,),),
                        onPressed: (){
                          _signOut();
                          Navigator.pop(context);
                        },
                      )
                    ],
                  );
                }
            );
          }else {
            setState(() {
              _busRef = documentSnapshot.data['bus'];
            });
            checkTurn();
          }
        });
      }

    });
  }
  void _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignOut();
    } catch (e) {
      print(e);
    }

  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
      return buildScaffold();
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
                      if (_busRef!=null && _busRef.isNotEmpty) {
                        Navigator.pop(context);
                        setState(() {
                          showAlert();
                        });
                      }else{
                        showDialog(
                          context: context,
                          builder: (context){
                            return AlertDialog(
                              title: Text("Access Denied"),
                              content: Text("You do not have permisson to do this action.Please contact agent"),
                            );
                          }
                        );
                      }
                    },
                    child: Container(
                      child: Row(
                        children: <Widget>[
                          Text(_validTurn ? "Update Turn" : "Add New Turn")
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
            icon: Icon(Icons.map),
            title: Text('Map'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            title: Text('Profile'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.redAccent,
        iconSize: 25,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w900),
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
          if(_validTurn){
            showDialog(context: context, builder: (context) {
              return simpleDialog;
            });
            Firestore.instance.collection('turns').document(_turnRef.documentID)
                .updateData({
              "endTime":DateTime.now(),
              "status":"previous",
            }).then((_){

              Firestore.instance.collection('rides')
              .where('bus',isEqualTo: _busRef)
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
              _validTurn = false;
            });
          }else{
            showDialog(context: context, builder: (context) {
              return simpleDialog;
            });
            
            Firestore.instance.collection('buses').document(_busRef).get()
            .then((DocumentSnapshot snapshot){
              String _routeNo = snapshot.data['route'];

              Firestore.instance.collection('turns').add({
                "bus":_busRef,
                "startTime":DateTime.now(),
                "status":"ongoing",
                "passengers": [],
                "route":_routeNo
              }).then((DocumentReference docRef){
                Navigator.pop(context);
                _turnRef = docRef;
                _validTurn = true;
              });

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
      title: Text(_validTurn?"Finish Turn":"Add New Turn"),
      content: Text(_validTurn?"Are you sure you want to finish this turn?":"Are you sure you want to add new turn?"),
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
          .where('bus',isEqualTo: _busRef)
          .where('status',isEqualTo: 'ongoing')
          .limit(1).getDocuments().then((QuerySnapshot snapshot){
        if(snapshot.documents.length == 0){
          setState(() {
            _validTurn = false;
          });
        }else{
          setState(() {
            _validTurn = true;
            _turnRef = snapshot.documents.removeLast().reference;
          });
        }
      });
  }

  void permissionAlert(String permissionType){

    String msg = "scan QR code";
    if(permissionType == "location")
      msg = "fetch current location";

    Alert(
      context: context,
      type: AlertType.error,
      title: "Permission Denied",
      desc: "Without $permissionType permission the app is unable to $msg",
      buttons: [
        DialogButton(
          child: Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () async {
            Navigator.pop(context);
            await PermissionHandler().openAppSettings();
          },
          width: 120,
        )
      ],
    ).show();
  }

  /// initialize connectivity checking
  /// Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return;
    }

    await _updateConnectionStatus().then((bool isConnected) => setState(() {
      isOnline = isConnected;
    }));
  }

  Future<bool> _updateConnectionStatus() async {
    bool isConnected;
    try {
      final List<InternetAddress> result =
      await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isConnected = true;
      }
    } on SocketException catch (_) {
      isConnected = false;
      return false;
    }
    return isConnected;
  }
  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }

}