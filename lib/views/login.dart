import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  double imgSize = 150;

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
                        child: Text("+94",style: TextStyle(fontWeight: FontWeight.w700,fontSize: 18.0),),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18,15,8,10),
                        child: Theme(
                          data: new ThemeData(
                            primaryColor: Colors.black,
                            primaryColorDark: Colors.black,
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                                labelText: "Phone Number".toUpperCase(),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                )),
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
                    onPressed: () {},
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
}
