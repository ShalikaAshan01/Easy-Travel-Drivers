import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csse/auth/auth.dart';
import 'package:csse/views/view_all_passengers.dart';
import 'package:csse/views/view_all_turns.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Profile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProfileState();
  }
}

class _ProfileState extends State<Profile> {
  String _busRef = "";
  String _driver = "";
  String _regNo = "";
  int _routeNo = 0;
  int _totPassengers = 0;
  int _turns = 0;
  BaseAuth _auth = Auth();
  @override
  void initState() {
    super.initState();
    _auth.currentUser().then((FirebaseUser user){
      Firestore.instance.collection("inspectors").document(user.uid).get()
          .then((DocumentSnapshot documentSnapshot){
            if(mounted)
              setState(() {
                _busRef = documentSnapshot.data['bus'];
              });
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    if(_busRef== null || _busRef.isEmpty){
      return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(child: CircularProgressIndicator()),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Loading...",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            ],
          ));
    }
    return ListView(
      children: <Widget>[
        Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height * .2,
                  color: Colors.indigo.shade300,
                ),
                Container(
                  height: MediaQuery.of(context).size.height * .85,
                  color: Colors.white,
                )
              ],
            ),
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * .1,
                left: 20,
                right: 20,
              ),
              alignment: Alignment.topCenter,
              child: Container(
                height: 180.0,
                child: StreamBuilder(
                    stream: Firestore.instance
                        .collection('buses')
                        .document(_busRef)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: Text("Loading..."),
                        );
                      }
                      _driver = snapshot.data["driver"];
                      _regNo = snapshot.data["regNo"];
                      _routeNo = snapshot.data["route"];

                      Firestore.instance
                          .collection("turns")
                          .where('bus', isEqualTo: _busRef)
                          .getDocuments()
                          .then((QuerySnapshot snapshot) {
                            if(mounted) {
                              setState(() {
                                _turns = snapshot.documents.length;
                              });
                            }
                      });

                      Firestore.instance
                          .collection("rides")
                          .where('bus', isEqualTo: _busRef)
                          .getDocuments()
                          .then((QuerySnapshot snapshot) {
                          _totPassengers = snapshot.documents.length;
                      });

                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                        color: Colors.white,
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 30.0,
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  "$_regNo".toUpperCase(),
                                  style: Theme.of(context).textTheme.title,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Expanded(
                              child: Text(
                                "RouteNo :$_routeNo",
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "Mr. $_driver",
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              height: 70.0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: ListTile(
                                      title: Text(
                                        "$_totPassengers",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text("Passengers".toUpperCase(),
                                          textAlign: TextAlign.center),
                                    ),
                                  ),
                                  Expanded(
                                    child: ListTile(
                                      title: Text(
                                        "$_turns",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text("Turns".toUpperCase(),
                                          textAlign: TextAlign.center),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        elevation: 4.0,
                      );
                    }),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 280, left: 20, right: 20),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Turns", style: Theme.of(context).textTheme.title,),
                      FlatButton(
                        onPressed: (){
                          setState(() {
                            Navigator.push(context,
                                MaterialPageRoute(builder:(context)=>ViewAllTurns()));
                          });
                        },
                        child: Text("View All", style: TextStyle(color: Colors.blue),),
                      )
                    ],
                  ),
                  turnsCollection(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Passengers", style: Theme.of(context).textTheme.title,),
                      FlatButton(
                        onPressed: (){
                          setState(() {
                            Navigator.push(context,
                                MaterialPageRoute(builder:(context)=>ViewAllPassengers()));
                          });
                        },
                        child: Text("View All", style: TextStyle(color: Colors.blue),),
                      )
                    ],
                  ),
                  passengerCollection()
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget turnsCollection() {
    return Container(
      height: 160,
      child: StreamBuilder(
          stream: Firestore.instance
              .collection('turns')
              .where('bus', isEqualTo: _busRef)
              .orderBy('startTime',descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                  child: Text("Loading..."),
              );
            }else{
              _turns = snapshot.data.documents.length;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _turns,
                itemBuilder: (context,index){
                  return turnListItem(context,snapshot.data.documents[index]);
                },
              );
            }
          }),
    );
  }

  Widget turnListItem(BuildContext context,DocumentSnapshot document){
    var startTime = DateFormat.Hms().format(document['startTime'].toDate());
    var startDate = DateFormat.yMMMd().format(document['startTime'].toDate());
    var endTime = "";
    var endDate = "";
    var passengers = document['passengers'].length;
    var status = document['status'];
    if(status == "previous"){
      status = "completed";
    }
    if(document['endTime']!= null) {
      endTime = DateFormat.Hms().format(document['endTime'].toDate());
      endDate = DateFormat.yMMMd().format(document['endTime'].toDate());
      endTime = "$endTime";
      endDate = "$endDate $endTime";
    }
    return Container(
      width: 200,
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0)),
        elevation: 2.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(child: Text("Start Time",style: TextStyle(fontWeight: FontWeight.bold),)),
              Container(padding:EdgeInsets.fromLTRB(10, 7,0,7),child: Text("$startDate $startTime",style: TextStyle(color: Colors.grey.shade500)),),
              endDate != "" ?
              Container(child: Text("End Time",style: TextStyle(fontWeight: FontWeight.bold),))
              :Container(),
              endDate != "" ?
              Container(padding:EdgeInsets.fromLTRB(10, 7,0,7),child: Text(endDate,style: TextStyle(color: Colors.grey.shade500)),)
              :Container(),
              Container(padding: EdgeInsets.only(top: 7),child: Text("Passengers: $passengers",style: TextStyle(fontWeight: FontWeight.bold)),),
              Container(padding: EdgeInsets.only(top: 7),child: Text("Status: ${status[0].toUpperCase()}${status.substring(1)}",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.grey.shade500)),),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget passengerCollection(){
    return Container(
      height: 210,
      child: StreamBuilder(
        stream: Firestore.instance.collection("rides").where("bus",isEqualTo: _busRef).orderBy('status',descending: false).snapshots(),
        builder: (context, snapshot){
          if(!snapshot.hasData)
            return Container(child: Text("Loading..."),);
          else{
            return ListView.builder(
            scrollDirection: Axis.horizontal,
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context,index){
                return passengerListItem(context, snapshot.data.documents[index]);
              },
            );
          }
        }
      ),
    );
  }
  Widget passengerListItem(BuildContext context,DocumentSnapshot document){
    DocumentReference documentReference = Firestore.instance.collection('passengers').document(document.data['passenger']);

    var startTime = DateFormat.Hms().format(document['startTime'].toDate());
    var startDate = DateFormat.yMMMd().format(document['startTime'].toDate());

    var endTime = "";
    var endDate = "";
    if(document['endTime']!= null) {
      endTime = DateFormat.Hms().format(document['endTime'].toDate());
      endDate = DateFormat.yMMMd().format(document['endTime'].toDate());
      endTime = "$endTime";
      endDate = "$endDate $endTime";
    }

    var status = document.data['status'];
    if(status == "previous")
      status = "completed";


    return Container(
      width: 200,
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0)),
        elevation: 2.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  getPassengerName(documentReference),
                  Container(child: Text("LKR ${document.data['ticketAmount']}",
                  style: TextStyle(color: Colors.grey.shade500),),)
                ],
              ),),
              SizedBox(height: 10,),
              Center(child: Container(padding: EdgeInsets.only(top: 7),child: Text("${document.data['startPoint']} to ${document.data['endPoint']} ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),)),
              Container(child: Text("Start Time",style: TextStyle(fontWeight: FontWeight.bold),)),
              Container(padding:EdgeInsets.fromLTRB(10, 7,0,7),child: Text("$startDate $startTime",style: TextStyle(color: Colors.grey.shade500)),),
              endDate != "" ?
              Container(child: Text("End Time",style: TextStyle(fontWeight: FontWeight.bold),))
                  :Container(),
              endDate != "" ?
              Container(padding:EdgeInsets.fromLTRB(10, 7,0,7),child: Text(endDate,style: TextStyle(color: Colors.grey.shade500),),)
                  :Container(),
              Container(padding: EdgeInsets.only(top: 7),child: Text("Status: ${status[0].toUpperCase()}${status.substring(1)}",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.grey.shade500)),),
            ],
          ),
        ),
      ),
    );
  }
  Widget getPassengerName(DocumentReference documentReference) {
    return StreamBuilder(
        stream: documentReference.snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            String name =
                snapshot.data['firstName'] + " " + snapshot.data['lastName'];
            return Text(
              name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            );
          }
          return Text("");
        });
  }
}
