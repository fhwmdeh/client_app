import 'package:flutter/material.dart';
import 'package:users/mainScreens/splashscreen.dart';

import '../global/global.dart';
import '../mainScreens/about_screen.dart';
import '../mainScreens/profile_screen.dart';
import '../mainScreens/trips_history_screen.dart';

class myDrwer extends StatefulWidget {

  String ? name;
  String ? email;
  myDrwer({
    this.name,
    this.email,
  });


  @override
  State<myDrwer> createState() => _myDrwerState();
}

class _myDrwerState extends State<myDrwer> {


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          //drwer Header
          Container(
            height: 165,
            color: Colors.grey,
            child: DrawerHeader(
              decoration: BoxDecoration(color: Colors.white),
              child: Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 16,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.name.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        widget.email.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 12.0,),

          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (c)=> TripsHistoryScreen()));
            },
            child: const ListTile(
              leading: Icon(Icons.history , color: Colors.black,),
              title: Text(
                  "History",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (c)=> ProfileScreen()));
            },
            child: const ListTile(
              leading: Icon(Icons.person , color: Colors.black,),
              title: Text(
                "Visit Profile",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (c)=> AboutScreen()));
            },
            child: const ListTile(
              leading: Icon(Icons.info , color: Colors.black,),
              title: Text(
                "About",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: (){
              fAuth.signOut();
              Navigator.push(context, MaterialPageRoute(builder: (context) => mysplashscreen(),));
            },
            child: const ListTile(
              leading: Icon(Icons.logout , color: Colors.black,),
              title: Text(
                "Sign Out",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
