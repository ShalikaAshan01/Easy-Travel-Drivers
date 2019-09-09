import 'package:flutter/cupertino.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan Code"),),
      body: Column(
        children: <Widget>[
          Container(
            height: 600.0,
            child: QrCamera(
              qrCodeCallback: (code) {
                debugPrint(code);
                _showAlert(code);
              },
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text(
                      "Scan Passengers QR Code",
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
  void _showAlert(String code){
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("QR code Detected"),
          content: Text(code),
        )
    );
  }
}