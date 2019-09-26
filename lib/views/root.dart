import 'package:csse/auth/auth.dart';
import 'package:csse/views/my_bottom_navigation_bar.dart';
import 'package:flutter/cupertino.dart';

import 'login.dart';

class Root extends StatefulWidget{
  final BaseAuth auth;
  Root({Key key,this.auth}): super(key: key);
  @override
  State<StatefulWidget> createState() => _RootState();

}
enum AuthStatus {
  notSignedIn,
  signedIn,
}
class _RootState extends State<Root>{
  AuthStatus authStatus = AuthStatus.notSignedIn;

  initState() {
    super.initState();
    widget.auth.currentUser().then((userId) {
      setState(() {
        authStatus = userId != null ? AuthStatus.signedIn : AuthStatus.notSignedIn;
      });
    });
  }
  void _updateAuthStatus(AuthStatus status) {
    setState(() {
      authStatus = status;
    });
  }



  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.notSignedIn:
        return Login(
          auth: widget.auth,
          onSignedIn: () => _updateAuthStatus(AuthStatus.signedIn),
        );
      default:
        return MyBottomNavigationBar(
          auth: widget.auth,
            onSignOut: () => _updateAuthStatus(AuthStatus.notSignedIn)
        );
    }
  }
}