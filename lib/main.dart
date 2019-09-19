import 'package:csse/auth/auth.dart';
import 'package:csse/views/landing.dart';
import 'package:csse/views/my_bottom_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool isFirst= false;

void main() async{
  await checkVeryFirstRun();
  runApp(
    MaterialApp(
    debugShowCheckedModeBanner: false,
//      home: MyBottomNavigationBar()
    home: isFirst == null || isFirst == true ? Landing():
        MyBottomNavigationBar(auth: Auth(),)
      ),
  );

}

checkVeryFirstRun()async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  isFirst = prefs.getBool('isFirst');
  await prefs.setBool('isFirst', false);
}