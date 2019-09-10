import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csse/views/home.dart';
import 'package:csse/views/my_bottom_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_mobile_vision/qr_camera.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class QrScanner extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _QrScanner();
  }

}

class _QrScanner extends State<QrScanner>{
  final String busRef = "ZLlJvSZM24uJqr2fXNn4";
  String turnId = "";
  bool isValid = false;
  bool isStarted = false;
  String text = "Scan Passengers QR Code";

  @override
  void initState() {
    super.initState();
    PermissionHandler().checkPermissionStatus(PermissionGroup.camera)
    .then((PermissionStatus permission){
      if(permission != PermissionStatus.granted){
        PermissionHandler().shouldShowRequestPermissionRationale(PermissionGroup.camera)
            .then((bool val){
           if(!val){
             Alert(
               context: context,
               title: "Access to camera denied",
               desc: "Allow access to the camera services for this App using the device settings.After Enabling please restart the app",
               buttons: [
                 DialogButton(
                   child: Text(
                     "Ok",
                     style: TextStyle(color: Colors.white, fontSize: 20),
                   ),
                   onPressed: () => PermissionHandler().openAppSettings(),
                   width: 120,
                 )
               ],
             ).show();
           }
        });
      }
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
            height: 600.0,
            child: isValid?Container(
              child: QrCamera(
                qrCodeCallback: (code){
//                Navigator.pushReplacement(context,
//                    MaterialPageRoute(builder: (context)=>MyBottomNavigationBar()));
                  validateCode(code).then((bool val){
//                    isValid = false
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
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text(
                      text,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      color: Colors.grey.shade500
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
        .collection("ride").document(code).get();
    if (snapshot == null || !snapshot.exists) {
      return false;
    }else if(snapshot.data['status']=="completed"){
      return false;
    }
    isStarted = snapshot.data['status'] == "started";
    return true;
  }

  void _showAlert(bool res){
    String title = "Great";
    String content = "New Passenger was added";
    if(!res){
      title = "Whoops";
      content = "Invalid token.Please recheck and read";
    }else if(isStarted){
      title = "GoodBye";
      content = "Thank you. Come Again";
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

     var snapshot = await Firestore.instance.collection("turn")
         .where('bus',isEqualTo: busRef)
//         .where('bus',isEqualTo: '/bus/$busRef')
         .orderBy("start_time", descending: true)
         .limit(1)
         .getDocuments();
     List<DocumentSnapshot> docs = snapshot.documents;

     DocumentSnapshot documentSnapshot = docs.first;

     turnId = documentSnapshot.documentID;

     final now = DateTime.now();
     final date = documentSnapshot.data['start_time'].toDate();
     if(now.difference(date).inHours >24 || documentSnapshot.data["status"] == "completed"){
//       Navigator.pop(context);
     setState(() {
       isValid = false;
       text = "Please update turn information";
     });
//       showMyDialog("Invalid turn Information", "Please update your turn information");
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
     }else{
       setState(() {
         isValid = true;
       });
     }
  }

  void addNewPassenger(String code)async{

    if(!isStarted){
      DocumentReference ref = Firestore.instance.collection('ride').document(code);

      var list = List<DocumentReference>();

      list.add(ref);
      await Firestore.instance.collection('turn').document(turnId).updateData({
        "passengers":FieldValue.arrayUnion(list)
      });
      await Firestore.instance.collection('ride').document(code).updateData({
        "status":"started",
        "start_time": DateTime.now()
      });
    }
    else{
      await Firestore.instance.collection('ride').document(code).updateData({
        "status":"completed",
        "end_time": DateTime.now()
      });
    }

  }
}