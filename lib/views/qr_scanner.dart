import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csse/auth/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_mobile_vision/qr_camera.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class QrScanner extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _QrScanner();
  }

}

class _QrScanner extends State<QrScanner>{
  String _busRef;
  String _turnId = "";
  bool _isValid = false;
  bool _isStarted = false;
  String _text = "Scan Passengers QR Code";
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
    validateTurn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan Code"),),
      body: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.7,
            child: _isValid?Container(
              child: QrCamera(
                qrCodeCallback: (code){
                  validateCode(code).then((bool val){
                  if(val){
                    addNewPassenger(code);
                  }
                    Navigator.pop(context);
                    _showAlert(val);
                  });
                },
              ),
            ):
            Container(
            )
            ,
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text(
                        _text,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.grey.shade500
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<bool> validateCode(String code) async{
    final DocumentSnapshot snapshot = await Firestore.instance
        .collection("rides").document(code).get();
    if (snapshot == null || !snapshot.exists) {
      return false;
    }else if(snapshot.data['status']=="previous"|| snapshot.data['status']=="cancelled"){
      return false;
    }
    _isStarted = snapshot.data['status'] == "ongoing";
    return true;
  }

  void _showAlert(bool res){
    String title = "Great";
    String content = "New Passenger was added";
    if(_isStarted){
      title = "GoodBye";
      content = "Thank you. Come Again";
    }else if(!res){
      title = "Whoops";
      content = "Invalid token.Please recheck and read";
    }
    showMyDialog(title, content);
  }
  void showMyDialog(String title,String content){
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title,style: TextStyle(fontWeight: FontWeight.bold),),
          content: Text(content),
        )
    );
  }

  void validateTurn()async{

     var snapshot = await Firestore.instance.collection("turns")
         .where('bus',isEqualTo: _busRef)
         .where('status',isEqualTo: 'ongoing')
         .limit(1)
         .getDocuments();
     List<DocumentSnapshot> docs = snapshot.documents;

     if(snapshot.documents.length == 0){
       setState(() {
         _isValid = false;
         _text = "Please update turn information";
       });
       Alert(
         context: context,
         type: AlertType.error,
         title: "Invalid turn Information",
         desc: "Please update your turn information.",
         buttons: [
           DialogButton(
             child: Text(
               "Ok",
               style: TextStyle(color: Colors.white, fontSize: 20),
             ),
             onPressed: () => Navigator.pop(context),
             width: 120,
           )
         ],
       ).show();
     }
     else{
       DocumentSnapshot documentSnapshot = docs.first;
       _turnId = documentSnapshot.documentID;
       setState(() {
         _isValid = true;
       });
     }
  }

  void addNewPassenger(String code)async{
    _isValid = false;
    if(!_isStarted){
      DocumentReference ref = Firestore.instance.collection('rides').document(code);

      var list = List<DocumentReference>();

      list.add(ref);
      await Firestore.instance.collection('turns').document(_turnId).updateData({
        "passengers":FieldValue.arrayUnion(list),
      });
      await Firestore.instance.collection('rides').document(code).updateData({
        "status":"ongoing",
        "startTime": DateTime.now(),
        "bus":_busRef
      });
    }
    else{
      await Firestore.instance.collection('rides').document(code).updateData({
        "status":"previous",
        "endTime": DateTime.now()
      });
    }

  }
}