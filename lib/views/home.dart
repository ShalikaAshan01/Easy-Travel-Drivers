import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  //TODO:get bus id
  final String busRef = "ZLlJvSZM24uJqr2fXNn4";
  bool isLoading = true;
  DocumentSnapshot passengersSnapshot;
  Stream<QuerySnapshot> streamSnapshot;

  @override
  Widget build(BuildContext context) {
    return Container(
      child:
//      isLoading
//      ?
//      Center(child: CircularProgressIndicator(),)
//      :
          _buildView(),
    );
  }

  @override
  void initState() {
    super.initState();
//    getPassengers();
  }

  void getPassengers() async {
    streamSnapshot = Firestore.instance
        .collection('turn')
        .where('bus', isEqualTo: busRef)
        .orderBy("start_time", descending: true)
        .limit(1)
        .snapshots();
//        .getDocuments();
//      passengersSnapshot = _snapshot.documents.first;
//      isLoading = false;
  }

  Widget _buildView() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('turn')
          .where('bus', isEqualTo: busRef)
          .orderBy("start_time", descending: true)
          .limit(1)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          DocumentSnapshot documentSnapshot = snapshot.data.documents[0];
          return _buildList(documentSnapshot);
        }
        return Center(
          child: Text("Loading..."),
        );
      },
    );
  }

  Widget _buildList(DocumentSnapshot document) {
    var passengers = document['passengers'];

    return ListView.builder(
      itemCount: passengers.length,
      itemExtent: 130.0,
      itemBuilder: (BuildContext context, int position) {
        DocumentReference ref = passengers[position];
        return _buildListItem(ref);
      },
    );
  }

  Widget getPassengerName(DocumentReference documentReference) {
    return StreamBuilder(
        stream: documentReference.snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(snapshot.hasData){
            String name = snapshot.data['first_name'] + " " + snapshot.data['last_name'];
            return Text(
                name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0
              ),
            );
          }
          return Text("");
        });
  }

  Widget _buildListItem(DocumentReference ref) {
    return StreamBuilder(
        stream: ref.snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data;
            String startPoint = data['start_point'];
            String endPoint = data['end_point'];
            String time = DateFormat.Hms().format(data['start_time'].toDate());
            String ticketAmount = data['ticket_amount'].toString();

            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: Card(
                  child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        left:
                            BorderSide(color: Colors.blueAccent, width: 4.0))),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.topRight,
                        padding: EdgeInsets.only(bottom: 5.0, right: 8.0),
                        child: Text(
                          "LKR $ticketAmount",
                          style: TextStyle(color: Colors.lightBlue),
                        ),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        child: getPassengerName(data['passenger']),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text("$startPoint to $endPoint",
                              style: TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.green)),
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomLeft,
                        padding: EdgeInsets.only(bottom: 5.0, right: 8.0),
                        child: Text(
                          time,
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
          }
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
        });
  }

  Widget oldBuildList() {
    return StreamBuilder(
        stream: Firestore.instance.collection('turn').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
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
          return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemExtent: 130.0,
            itemBuilder: (context, index) {
              return _oldBuildListItem(context, snapshot.data.documents[index]);
            },
          );
        });
  }

  Widget _oldBuildListItem(BuildContext context, DocumentSnapshot document) {
    String _name = "Shalika Ashan";
    String _endPoint = "Colombo";
    String _startPoint = "Avissawella";
    String _seats = passengersSnapshot.documentID;
    String _date = "12:12:21 AM";
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Card(
          child: Container(
        decoration: BoxDecoration(
            border:
                Border(left: BorderSide(color: Colors.blueAccent, width: 4.0))),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Container(
                alignment: Alignment.topRight,
                padding: EdgeInsets.only(bottom: 5.0, right: 8.0),
                child: Text(
                  _seats,
                  style: TextStyle(color: Colors.lightBlue),
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                child: Text(_name,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text("$_startPoint to $_endPoint",
                      style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.green)),
                ),
              ),
              Container(
                alignment: Alignment.bottomLeft,
                padding: EdgeInsets.only(bottom: 5.0, right: 8.0),
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
