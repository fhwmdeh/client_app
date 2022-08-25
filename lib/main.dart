
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users/mainScreens/mainScreen.dart';
import 'package:users/mainScreens/splashscreen.dart';

import 'info_handler/app_info.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp(
      myApp(
    child:
    ChangeNotifierProvider(
      create: (context) => AppInfo(),
      child: MaterialApp(
        theme: ThemeData(
          primaryColor: Colors.black45,

        ),
        home: mysplashscreen(),

        debugShowCheckedModeBanner: false,

      ),
    ),
  ));
}


class myApp extends StatefulWidget {
  final Widget ? child;
  myApp({this.child});

  static void restartApp(BuildContext context){

    context.findAncestorStateOfType<_myAppState>()!.restartApp();
  }

  @override
  State<myApp> createState() => _myAppState();
}

class _myAppState extends State<myApp> {

  Key key  = UniqueKey();
  void restartApp(){
    setState(() {
      key = UniqueKey();
    });
  }
  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child!,
    );
  }
}




