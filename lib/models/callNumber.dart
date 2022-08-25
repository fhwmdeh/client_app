import 'package:firebase_database/firebase_database.dart';

class callNumber{

  String ? driverNumber;
  callNumber({this.driverNumber});
  callNumber.fromSnapShot(DataSnapshot dataSnapshot){
          driverNumber = (dataSnapshot.value as Map)["driverPhone"];
  }

}