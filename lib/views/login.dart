import 'package:csse/views/my_bottom_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart' as prefix0;
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  double imgSize = 150;
  TextEditingController _controller = TextEditingController();
  var _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _verificationId = "";
  String _phoneNumber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(left: 10.0, right: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                child: Image.asset('assets/img/logo.png'),
                height: imgSize,
                width: imgSize,
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: SizedBox(
                        child: Text(
                          "+94",
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
                                return _phoneValidator(value);
                              },
                              keyboardType: TextInputType.number,
                              controller: _controller,
                              decoration: InputDecoration(
                                  labelText: "Phone Number".toUpperCase(),
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
                      "Login".toUpperCase(),
                      style: TextStyle(fontSize: 16.0),
                    ),
                    color: Colors.black,
                    textColor: Colors.white,
                    onPressed: () async{
                      setState(() {
                        if (_formKey.currentState.validate()) {
                          debugPrint("..............press..................");
                          _verifyPhoneNumber();
//                         Navigator
//                          .pushReplacement(context, MaterialPageRoute(
//                           builder: (context)=> MyBottomNavigationBar()
//                         ));
                        }
                      });
                    },
                  ),
                ),
              ),
              Container(
                child: Text("Login with your phone number"),
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

  void _verifyPhoneNumber() async{

    debugPrint("####################################################");
    debugPrint("####################phone number $_phoneNumber################################");
    debugPrint("####################################################");
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneCredential) {
      _auth.signInWithCredential(phoneCredential);
      debugPrint("************************************");
      debugPrint("**************credientials**********************");
      prefix0.debugPrint("recived phone auth credentials $phoneCredential");
      debugPrint("************************************");
      debugPrint("************************************");
    };

    final PhoneVerificationFailed phoneVerificationFailed =
        (AuthException authException) {
      debugPrint(
          'Phone number verification failed. Code: ${authException.code}.'
          ' Message: ${authException.message}');
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      debugPrint('Please check your phone for the verification code.$verificationId');
            _verificationId = verificationId;
        };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
    };

    await _auth.verifyPhoneNumber(
        phoneNumber: _phoneNumber,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verificationCompleted,
        verificationFailed: phoneVerificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);

  }

  void signInWithPhoneNumber()async{
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: _verificationId,
//      smsCode: _smsController.text,
    );
    final FirebaseUser user =
    (await _auth.signInWithCredential(credential)).user;
    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    setState(() {
    if (user != null) {
//    _message = 'Successfully signed in, uid: ' + user.uid;
    } else {
//    _message = 'Sign in failed';
    }
    });
  }

}
