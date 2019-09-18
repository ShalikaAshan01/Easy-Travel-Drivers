import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth {
  Future<FirebaseUser> signInWithPhoneNumber(AuthCredential credential);
  Future<FirebaseUser> currentUser();
  Future<void> signOut();

  }
class Auth implements BaseAuth {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Future<FirebaseUser> signInWithPhoneNumber(AuthCredential credential) async{
    AuthResult authResult= await _auth.signInWithCredential(credential);
    return authResult.user;
  }
  Future<FirebaseUser> currentUser() async{
    return await _auth.currentUser();
  }
  Future<void> signOut()async{
    await _auth.signOut();
  }
}