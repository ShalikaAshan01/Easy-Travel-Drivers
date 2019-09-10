import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CurrentPassengers extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CurrentPassengersState();
  }
}

class _CurrentPassengersState extends State<CurrentPassengers> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: buildList(),
    );
  }

  Widget buildList() {
    return StreamBuilder(
        stream: Firestore.instance.collection('bus').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Center(child: CircularProgressIndicator()),
                    Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Text("Loading...",style: TextStyle(fontWeight: FontWeight.bold),),
                    )
                  ],
                ));
          }
          return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemExtent: 130.0,
            itemBuilder: (context, index) {
              return _buildListItem(context, snapshot.data.documents[index]);
            },
          );
        });
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    String _name = "Shalika Ashan";
    String _endPoint = "Colombo";
    String _startPoint = "Avissawella";
    String _seats = "Seats: 02";
    String _date = "12:12:21 AM";
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Card(
            child: Container(
              decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: Colors.blueAccent,width: 4.0))
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.topRight,
                      padding: EdgeInsets.only(bottom: 5.0,right: 8.0),
                      child: Text(
                        _seats,
                        style: TextStyle(color: Colors.lightBlue),
                      ),
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                          _name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20
                          )),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                            "$_startPoint to $_endPoint",
                            style: TextStyle(
                                fontSize: 22.0,
                              fontWeight: FontWeight.w900,
                              color: Colors.green
                            )
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomLeft,
                      padding: EdgeInsets.only(bottom: 5.0,right: 8.0),
                      child: Text(
                        _date,
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
                  ],
                ),
              ),
            )
//      ),
      ),
    );

//    return ListTile(
//      title: Row(
//        children: <Widget>[
//          Expanded(
//            child: Text(document['name']),
//          ),
//          Container(
//            child: Text(document['votes'].toString()),
//          )
//        ],
//      ),
//      onTap: (){
//        Firestore.instance.runTransaction((transactions)async {
//          DocumentSnapshot freshSnap =
//              await transactions.get(document.reference);
//          await transactions.update(freshSnap.reference,{
//            'votes':freshSnap['votes'] + 1
//          });
//        });
//      },
//    );
  }
}
