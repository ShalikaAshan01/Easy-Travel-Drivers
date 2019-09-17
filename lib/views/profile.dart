import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Profile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ProfileState();
  }
}

class ProfileState extends State<Profile> {
  //TODO add bus id
  final String busRef = "r1zQyo9NkcKj7cqkv91X";
  DocumentReference ref;
  String driver = "";
  String regNo = "";
  int routeNo = 0;
  int totPassengers = 0;
  int turns = 0;

  @override
  void initState() {
    super.initState();
    Firestore.instance
        .collection('buses')
        .document(busRef)
        .get()
        .then((DocumentSnapshot snapshot) {
      ref = snapshot.reference;
    });
  }
  @override
  Widget build(BuildContext context) {
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
                        .document(busRef)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: Text("Loading..."),
                        );
                      }
                      driver = snapshot.data["driver"];
                      regNo = snapshot.data["regNo"];
                      routeNo = snapshot.data["route"];

                      Firestore.instance
                          .collection("turns")
                          .where('bus', isEqualTo: busRef)
                          .getDocuments()
                          .then((QuerySnapshot snapshot) {
                        setState(() {
                          turns = snapshot.documents.length;
                        });
                      });

                      Firestore.instance
                          .collection("rides")
                          .where('bus', isEqualTo: ref)
                          .getDocuments()
                          .then((QuerySnapshot snapshot) {
                        setState(() {
                          totPassengers = snapshot.documents.length;
                        });
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
                                  "$regNo".toUpperCase(),
                                  style: Theme.of(context).textTheme.title,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Expanded(
                              child: Text(
                                "RouteNo :$routeNo",
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "Mr. $driver",
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
                                        "$totPassengers",
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
                                        "$turns",
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
                        onPressed: (){},
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
                        onPressed: (){},
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
              .where('bus', isEqualTo: busRef)
              .orderBy('startTime',descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                  child: Text("Loading..."),
              );
            }else{
              turns = snapshot.data.documents.length;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: turns,
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
      height: 200,
      child: StreamBuilder(
        stream: Firestore.instance.collection("rides").where("bus",isEqualTo: ref).orderBy('status',descending: true).snapshots(),
        builder: (context, snapshot){
          if(!snapshot.hasData)
            return Container(child: Text("Loading..."),);
          else{
          totPassengers = snapshot.data.documents.length;
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
    DocumentReference documentReference = document.data['passenger'];
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
              Container(padding: EdgeInsets.only(top: 7),child: Text("Status: ${document.data['status'][0].toUpperCase()}${document.data['status'].substring(1)}",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.grey.shade500)),),
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
