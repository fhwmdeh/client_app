
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:users/mainScreens/loginScreen.dart';
import 'package:users/mainScreens/splashscreen.dart';
import 'package:users/wedgets/progressDialog.dart';

import '../global/global.dart';



class registerScreen extends StatefulWidget {
  static const String idScreen = "register";



  @override
  State<registerScreen> createState() => _registerScreenState();
}

class _registerScreenState extends State<registerScreen> {
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  validateForm() {
    if (nameTextEditingController.text.length < 2) {
      Fluttertoast.showToast(msg: "Name must be at least 2 characters");
    } else if (!emailTextEditingController.text.contains("@")) {
      Fluttertoast.showToast(msg: "Email is invalid");
    } else if (phoneTextEditingController.text.isEmpty) {
      Fluttertoast.showToast(msg: "phone number is required");
    } else if (passwordTextEditingController.text.length<6) {
      Fluttertoast.showToast(msg: "password must be at least 4 characters");
    }else{
      saveDriverInfoNow();
    }
  }

  saveDriverInfoNow() async{

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext c){
        return progressDialog(message: "signing up , please wait...",);

      },

    );
    final User? firebaseUser =(
        await fAuth.createUserWithEmailAndPassword(
            email:emailTextEditingController.text.trim(),
            password: passwordTextEditingController.text.trim(),
        ).catchError((msg){
          Navigator.pop(context);
          Fluttertoast.showToast(msg: "Error" + msg.toString());

        })
    ).user;

    if(firebaseUser !=null){

      Map usersMap ={
        "id" :firebaseUser.uid,
        "name" : nameTextEditingController.text.trim(),
        "email" : emailTextEditingController.text.trim(),
        "password" : passwordTextEditingController.text.trim(),
        "phone" : phoneTextEditingController.text.trim(),


      };

      DatabaseReference driverRef = FirebaseDatabase.instance.ref("users");
      driverRef.child(firebaseUser.uid).set(usersMap);
      currentFirebaseUser = firebaseUser;
      Fluttertoast.showToast(msg: "Account Has  Been Created");
      Navigator.push(context, MaterialPageRoute(builder: (c) => mysplashscreen()));

    }
    else{
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Account Has Not Been Created");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset("images/logo2.png"),
            SizedBox(height: 30.0,),
            Text("Register As User" , style: TextStyle(fontSize: 18.0 , fontWeight: FontWeight.bold),),
            SizedBox(height: 30.0,),
            TextField(
              controller: nameTextEditingController,
              keyboardType: TextInputType.name,
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'Name',
                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
              ),
            ),
            SizedBox(height: 10.0,),
            TextField(
              controller: emailTextEditingController,
              keyboardType: TextInputType.emailAddress,
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'Eamil Address',
                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
              ),
            ),
            SizedBox(height: 10.0,),
            TextField(
              controller: phoneTextEditingController,
              keyboardType: TextInputType.phone,
              autofocus: false,
              decoration: InputDecoration(
                hintText: '+97256800000',
                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
              ),
            ),
        SizedBox(height: 10,),
        TextField(
          controller: passwordTextEditingController,
          keyboardType: TextInputType.text,
          autofocus: false,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Password',
            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
          ),
        ),
            SizedBox(height: 30.0,),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 28, 190, 204),
                  padding: EdgeInsets.symmetric(horizontal: 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),

                ),
                onPressed: (){
                  validateForm();
                  },
                child: Text("Creat Account" , style: TextStyle(fontSize: 25 , fontWeight: FontWeight.bold)) ),
            TextButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => signin()));
            },
                child:
                Text("Already Have Account , Login" , style: TextStyle(color: Colors.black , fontWeight: FontWeight.bold),)),
        ]),
      ),
    );

    }
}
