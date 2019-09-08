import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_mobile_vision/qr_camera.dart';

class QrScanner extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _QrScanner();
  }

}

class _QrScanner extends State<QrScanner>{

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
          Container(
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