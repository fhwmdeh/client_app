import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'mainScreen.dart';


class AboutScreen extends StatefulWidget
{
  @override
  State<AboutScreen> createState() => _AboutScreenState();
}




class _AboutScreenState extends State<AboutScreen>
{
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:Colors.black,
        title: Text(
          "About ",
        ),
      ),
      backgroundColor: Colors.white,
      body: ListView(

        children: [

          //image
           Container(
            height: 230,
            child: Center(
              child: Image.asset(
                "images/car_logo.png",
                width: 260,
              ),
            ),
          ),

          Column(
            children: [

              //company name
              const Text(
                "Talabat Samou'",
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              //about you & your company - write some info
              const Text(
                "This app has been developed by Fatmeh Alhawamsdeh, "
                "This app is Available for all Samou' People who need to take a ride."
                "Hope You Got The Benefit from this App ."
                "\n\ncontact us for more inforamtion ",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(
                height: 10,
              ),
              const SizedBox(
                height: 40,
              ),

              //close
              ElevatedButton(
                onPressed: ()
                {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => mainScreen()));
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                ),
                child: const Text(
                  "Close",
                  style: TextStyle(color: Colors.white),
                ),
              ),

            ],
          ),

        ],

      ),
    );
  }
}
