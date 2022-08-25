import 'dart:async';
import 'package:flutter/material.dart';
import 'package:users/assistants/assistants_method.dart';
import 'package:users/global/global.dart';
import 'package:users/mainScreens/loginScreen.dart';
import 'package:users/mainScreens/mainScreen.dart';


class mysplashscreen extends StatefulWidget {
  static const String idScreen = "splash";

  @override
  _mysplashscreenState createState() => _mysplashscreenState();
}

class _mysplashscreenState extends State<mysplashscreen> {

  startTimer(){
    fAuth.currentUser != null ? AssistantsMethods.readCurrentOnlineInfo(): null;
    Timer(
        Duration(seconds: 3 ), ()async{
      if(await fAuth.currentUser != null){

        currentFirebaseUser = fAuth.currentUser;

        Navigator.push(context, MaterialPageRoute(builder: ((context) => mainScreen())));

      }else{
        Navigator.push(context, MaterialPageRoute(builder: ((context) => signin())));
      }

    });
  }
  @override
  void initState(){

    super.initState();
    startTimer();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("images/logo2.png"),
        ],)),

    );
  }
}