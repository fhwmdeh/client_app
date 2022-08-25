import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class userModel{
  String ?phone;
  String ?name;
  String ?email;
  String ?id;

  userModel({
    this.phone,
    this.email,
    this.id,
    this.name,
});

  userModel.fromSnapShot(DataSnapshot snap){
    phone = (snap.value as dynamic)["phone"];
    name = (snap.value as dynamic)["name"];
    email = (snap.value as dynamic)["email"];
    id = snap.key;

  }
}