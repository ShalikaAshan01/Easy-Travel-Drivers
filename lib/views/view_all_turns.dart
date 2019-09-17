import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewAllTurns extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ViewAllTurnsState();
  }
}

class ViewAllTurnsState extends State<ViewAllTurns>{
  //TODO add bus id
  final String busRef = "r1zQyo9NkcKj7cqkv91X";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Turn List"),
      ),
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: turnsCollection(),
      ),
    );
  }

  Widget turnsCollection() {
    return Container(
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
              return ListView.builder(
                itemCount: snapshot.data.documents.length,
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
    if(status == "previous")
      status = "completed";
    if(document['endTime']!= null) {
      endTime = DateFormat.Hms().format(document['endTime'].toDate());
      endDate = DateFormat.yMMMd().format(document['endTime'].toDate());
      endTime = "$endTime";
      endDate = "$endDate $endTime";
    }
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(child: Text("Start Time",style: TextStyle(fontWeight: FontWeight.bold),)),
                      Container(padding:EdgeInsets.fromLTRB(10, 7,0,7),child: Text("$startDate $startTime",style: TextStyle(color: Colors.grey.shade500)),)
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      endDate != "" ?
                      Container(child: Text("End Time",style: TextStyle(fontWeight: FontWeight.bold),))
                          :Container(),
                      endDate != "" ?
                      Container(padding:EdgeInsets.fromLTRB(10, 7,0,7),child: Text(endDate,style: TextStyle(color: Colors.grey.shade500)),)
                          :Container(),
                    ],
                  )
                ],
              ),
              Center(child: Container(padding: EdgeInsets.only(top: 7),child: Text("Passengers: $passengers",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20.0)),)),
              Container(padding: EdgeInsets.only(top: 7),child: Text("Status: ${status[0].toUpperCase()}${status.substring(1)}",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.grey.shade500)),),
            ],
          ),
        ),
      ),
    );
  }
}