import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csse/auth/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Login extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback onSignedIn;
  Login({this.auth, this.onSignedIn});
  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  double _imgSize = 150;
  String _textFieldText = "Phone number";
  String _labelText = "+94";
  String _button = "login";
  String _text = "Login with your phone number";
  bool _isOTP = false;
  TextEditingController _controller = TextEditingController();
  var _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _verificationId = "";
  String _phoneNumber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(left: 10.0, right: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                child: Image.asset('assets/img/logo.png'),
                height: _imgSize,
                width: _imgSize,
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: SizedBox(
                        child: Text(
                          "$_labelText",
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 18.0),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 15, 8, 10),
                        child: Theme(
                          data: new ThemeData(
                            primaryColor: Colors.black,
                            primaryColorDark: Colors.black,
                          ),
                          child: Form(
                            key: _formKey,
                            child: TextFormField(
                              validator: (String value) {
                                if (!_isOTP) return _phoneValidator(value);
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              controller: _controller,
                              decoration: InputDecoration(
                                  labelText: "$_textFieldText".toUpperCase(),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  )),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 10, 8.0, 8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: MaterialButton(
                    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: Text(
                      "$_button".toUpperCase(),
                      style: TextStyle(fontSize: 16.0),
                    ),
                    color: Colors.black,
                    textColor: Colors.white,
                    onPressed: () async {
                      setState(() {
                        if (_formKey.currentState.validate()) {
                          if (!_isOTP) {
                            _verifyPhoneNumber();
                          } else {
                            signInWithPhoneNumber();
                          }
                        }
                      });
                    },
                  ),
                ),
              ),
              Container(
                child: Text("$_text"),
              )
            ],
          ),
        ),
      ),
    );
  }

  String _phoneValidator(String value) {
    if (value.isEmpty) return "Phone Number cannot be empty";
    if (value[0] == "0") value = value.substring(1);
    value = "+94$value";
    _phoneNumber = value;
    Pattern pattern = '^(?:[+0]9)?[0-9]{10}\$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) return "Enter a valid Phone Number";
    return null;
  }

  void _verifyPhoneNumber() async {
    showDialog(context: context, builder: (context) {
      return simpleDialog;
    });
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneCredential) async {
          FirebaseUser user = await widget.auth.signInWithPhoneNumber(phoneCredential);
          createUserDocument(user);
          Navigator.pop(context);
          widget.onSignedIn();
//          Navigator.pushReplacement(context,
//          MaterialPageRoute(builder: (context) => MyBottomNavigationBar()));
    };

    final PhoneVerificationFailed phoneVerificationFailed =
        (AuthException authException) {
          Navigator.pop(context);
          _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(authException.message),
        duration: Duration(seconds: 3),
      ));
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
          setState(() {
            _isOTP = true;
            _labelText = "e";
            _textFieldText = "OTP";
            _button = "Confirm";
            _text =
            "Please type the verification code sent to $_phoneNumber";
            _controller.clear();
            Navigator.pop(context);
          });
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Please check your phone for the verification code"),
        duration: Duration(seconds: 3),
      ));
      _verificationId = verificationId;
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
          Navigator.pop(context);
          _verificationId = verificationId;
    };

    await _auth.verifyPhoneNumber(
        phoneNumber: _phoneNumber,
        timeout: const Duration(seconds: 59),
        verificationCompleted: verificationCompleted,
        verificationFailed: phoneVerificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  void signInWithPhoneNumber() async {
    showDialog(context: context, builder: (context) {
      return simpleDialog;
    });
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: _verificationId,
      smsCode: _controller.text,
    );
    try {
      final FirebaseUser user = await widget.auth.signInWithPhoneNumber(credential);
      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);

        if (user != null) {

          //check already have doc
          createUserDocument(currentUser);
          setState(() {
            Navigator.pop(context);
//            Navigator.pushReplacement(context,
//                MaterialPageRoute(builder: (context) => MyBottomNavigationBar()));
          });
          widget.onSignedIn();
        } else {
          Navigator.pop(context);
          errorAlert("Sign in failed.Please Try Again");
        }

    } on Exception catch (e) {
      Navigator.pop(context);
      errorAlert("Invalid OTP");
    }
  }

  void errorAlert(String message) {
    Alert(
      context: context,
      type: AlertType.error,
      title: "Oops..!",
      desc: message,
      buttons: [
        DialogButton(
          child: Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            setState(() {
              String _textFieldText = "Phone number";
              String _labelText = "+94";
              String _button = "login";
              String _text = "Login with your phone number";
              bool _isOTP = false;
              _controller.clear();
              Navigator.pop(context);
            });
            },
          width: 120,
        )
      ],
    ).show();
  }

  void createUserDocument(FirebaseUser currentUser)async{
    DocumentSnapshot snapshot =await Firestore.instance.collection('inspectors').document(currentUser.uid).get();
    if(!snapshot.exists){
      await Firestore.instance.collection('inspectors').document(currentUser.uid)
          .setData({
        "bus":"",
        "phoneNumber":currentUser.phoneNumber,
        "status":"inactive"
      });
    }
  }

  Widget simpleDialog = SimpleDialog(
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(child: CircularProgressIndicator()),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "Please wait...",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          ],
        )
      ]);
}
