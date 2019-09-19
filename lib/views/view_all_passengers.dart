import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csse/auth/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewAllPassengers extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _ViewAllPassengersState();
  }

}

class _ViewAllPassengersState  extends State<ViewAllPassengers>{
  String _busRef="";
  BaseAuth _auth = Auth();

  @override
  void initState() {
    super.initState();
    _auth.currentUser().then((FirebaseUser user){
      Firestore.instance.collection("inspectors").document(user.uid).get()
          .then((DocumentSnapshot documentSnapshot){
        setState(() {
          _busRef = documentSnapshot.data['bus'];
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Passengers List"),
      ),
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: passengerCollection(),
      ),
    );
  }
  Widget passengerCollection(){
    return Container(
      child: StreamBuilder(
          stream: Firestore.instance.collection("rides").where("bus",isEqualTo: _busRef).orderBy('status',descending: false).snapshots(),
          builder: (context, snapshot){
            if(!snapshot.hasData)
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
            else{
              return ListView.builder(
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
              Center(child: Container(padding: EdgeInsets.only(top: 7),child: Text("Status: ${status[0].toUpperCase()}${status.substring(1)}",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.grey.shade500)),)),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(child: Text("Start Time",style: TextStyle(fontWeight: FontWeight.bold),)),
                      Container(padding:EdgeInsets.fromLTRB(10, 7,0,7),child: Text("$startDate $startTime",style: TextStyle(color: Colors.grey.shade500)),),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      endDate != "" ?
                      Container(child: Text("End Time",style: TextStyle(fontWeight: FontWeight.bold),))
                          :Container(),
                      endDate != "" ?
                      Container(padding:EdgeInsets.fromLTRB(10, 7,0,7),child: Text(endDate,style: TextStyle(color: Colors.grey.shade500),),)
                          :Container(),
                    ],
                  )
                ],
              )
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