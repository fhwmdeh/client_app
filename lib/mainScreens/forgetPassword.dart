//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';



class forgetpassword extends StatefulWidget {
  static const String idScreen = "forget";

  @override
  _forgetpasswordState createState() => _forgetpasswordState();
}

class _forgetpasswordState extends State<forgetpassword> {

  TextEditingController resetTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:
        Column(
          children: [
            Container(
              height: 350,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12) , bottomRight: Radius.circular(12)),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(255, 28, 190, 204) ,
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7,0.7),
                    )
                  ]
              ),
              child:
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Reset Password" ,
                          style:  TextStyle(fontSize: 30 , color: Color.fromARGB(255, 28, 190, 204) , fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 10.0,),
                        Icon(Icons.password ,color: Color.fromARGB(255, 28, 190, 204), size: 40,),


                      ],)

                    ]),
              ) ,
            ),

            SizedBox(height: 50.0,),
            TextFormField(
              cursorColor: Color.fromARGB(255, 28, 190, 204,),
              controller: resetTextEditingController,
              keyboardType: TextInputType.emailAddress,
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'samouTalabat@gmail.com',
                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0), ),
              ),
            ),


            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child:ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 28, 190, 204),
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),

                  ),
                  onPressed: ()async{
                   /* FirebaseAuth.instance.sendPasswordResetEmail(email:resetTextEditingController.text).then((value) => {
                      Navigator.pop(context)
                    });*/

                  }, child: Text("Reset Password", style: TextStyle(fontSize: 25 , fontWeight: FontWeight.bold)) ),
            ),



          ],
        )
    );
  }
}