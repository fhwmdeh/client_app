
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:users/mainScreens/forgetPassword.dart';
import 'package:users/mainScreens/registerScreen.dart';
import 'package:users/mainScreens/splashscreen.dart';
import '../global/global.dart';
import '../main.dart';
import '../wedgets/progressDialog.dart';



class signin extends StatefulWidget {

  static const String idScreen = "login";


  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<signin> {


  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();


  validateForm()
  {
    if(!emailTextEditingController.text.contains("@"))
    {
      Fluttertoast.showToast(msg: "Email address is not Valid.");
    }
    else if(passwordTextEditingController.text.isEmpty)
    {
      Fluttertoast.showToast(msg: "Password is required.");
    }
    else
    {
      loginUserNow();
    }
  }

  loginUserNow() async
  {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c)
        {
          return progressDialog(message: "Processing, Please wait...",);
        }
    );

    final User? firebaseUser = (
        await fAuth.signInWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim(),
        ).catchError((msg){
          Navigator.pop(context);
          Fluttertoast.showToast(msg: "Error: " + msg.toString());
        })
    ).user;

    if(firebaseUser != null)
    {
      DatabaseReference driversRef = FirebaseDatabase.instance.ref().child("users");
      driversRef.child(firebaseUser.uid).once().then((driverKey)
      {
        final snap = driverKey.snapshot;
        if(snap.value != null)
        {
          currentFirebaseUser = firebaseUser;
          Fluttertoast.showToast(msg: "Login Successful.");
          Navigator.push(context, MaterialPageRoute(builder: (c)=> mysplashscreen()));
        }
        else
        {
          Fluttertoast.showToast(msg: "No record exist with this email.");
          fAuth.signOut();
          Navigator.push(context, MaterialPageRoute(builder: (c)=>  mysplashscreen()));
        }
      });
    }
    else
    {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Error Occurred during Login.");
    }
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: SingleChildScrollView(
          child: Column(children: [
            SizedBox(height: 15,),
            Image.asset('images/logo2.png' , width: 300, height: 300,),
            SizedBox(height: 5,),
            Text("Login",  style: TextStyle(color: Color.fromARGB(255, 28, 190, 204) , fontWeight: FontWeight.bold , fontSize: 30),),
            SizedBox(height: 20,),
            TextFormField(
              controller: emailTextEditingController,
              keyboardType: TextInputType.emailAddress,
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'samouTalabat@gmail.com',
                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
              ),
            ),
            SizedBox(height: 5,),
            TextFormField(
              controller: passwordTextEditingController,
              autofocus: false,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Password',
                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child:ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 28, 190, 204),
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: (){
                    validateForm();
                  },
                  child: Text("login" , style: TextStyle(fontSize: 25 , fontWeight: FontWeight.bold))
              ),
            ),
            SizedBox(height: 5,),

            TextButton(
              child: Text(
                'Sign Up',
                style: TextStyle(color: Colors.black , fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (c) => registerScreen()));
              },
            ),
            SizedBox(height: 1,),

            TextButton(
              child: Text(
                'Forgot password?',
                style: TextStyle(color: Colors.black , fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: ((context) => forgetpassword())));
              },
            ),
          ],),
        ),
        )
    );
  }
  }
