
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:users/assistants/requestAssistant.dart';
import 'package:users/configMap.dart';
import 'package:users/global/global.dart';
import 'package:users/info_handler/app_info.dart';
import 'package:users/models/directionDetailsInfo.dart';
import 'package:users/models/user_model_drawer.dart';
import 'package:http/http.dart' as http;

import '../models/directions.dart';
import '../models/trips_history_model.dart';

class AssistantsMethods{

  static Future<dynamic> searchAddressForGeographicCoOrdinate(Position position , context )async{
    String humanReadableAddress="" ;
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    var  requestResponse = await RequestAssistant.recieveRequest(apiUrl);
    if(requestResponse!="failed"){
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];

      Directions userPickupAddress= Directions();
      userPickupAddress.locationlatitude = position.latitude ;
      userPickupAddress.locationlongitude = position.longitude;
      userPickupAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context , listen: false).updatePickupLocationAddress(userPickupAddress);

    }
    return humanReadableAddress;
  }
  static void readCurrentOnlineInfo()async{
    currentFirebaseUser = fAuth.currentUser;
    DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users").child(currentFirebaseUser!.uid);
    userRef.once().then((snap){
      if(snap.snapshot.value !=null){
       userModelCurrentInfo = userModel.fromSnapShot(snap.snapshot);
       print("name = " + userModelCurrentInfo!.name.toString());
       print("email = " + userModelCurrentInfo!.email.toString());
      }
    });
  }
  static Future<DirectionDetailsInfo?>obtainOrginToDistinationDirectionDetails(LatLng origionPosition , LatLng distinationPosition)async{
    String urlOrginToDistinationDirectionDetails =
 "https://maps.googleapis.com/maps/api/directions/json?origin=${origionPosition.latitude},${origionPosition.longitude} &destination=${distinationPosition.latitude},${distinationPosition.longitude}&key=$mapKey";
  var resDirectionApi = await RequestAssistant.recieveRequest(urlOrginToDistinationDirectionDetails);

  if(resDirectionApi == "failed"){
    return null;
  }
  DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points = resDirectionApi["routes"][0]["overview_polyline"]["points"];
    directionDetailsInfo.distance_text = resDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value = resDirectionApi["routes"][0]["legs"][0]["distance"]["value"];
    directionDetailsInfo.duration_text= resDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value= resDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;

  }

  static double calculateFairAmountFromOriginToDestinatation(DirectionDetailsInfo directionDetailsInfo){

    double timeTraveledFairPerMinute = (directionDetailsInfo.duration_value! / 60)* 3.5;
    double destanceTraveledFairPerKm = (directionDetailsInfo.duration_value! / 1000)*3.5;
    double totalFairAmount  = timeTraveledFairPerMinute + destanceTraveledFairPerKm;

    return double.parse(totalFairAmount.toStringAsFixed(1));


  }


  static sendNotificationToDriverNow(String deviceRegistrationToken, String userRideRequestId, context) async
  {
    String destinationAddress = userDropOffAddress;

    Map<String, String> headerNotification =
    {
      'Content-Type': 'application/json',
      'Authorization': cloudMessagingServerToken,
    };

    Map bodyNotification =
    {
      "body":"Destination Address: \n$destinationAddress.",
      "title":"New Trip Request"
    };

    Map dataMap =
    {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "rideRequestId": userRideRequestId
    };

    Map officialNotificationFormat =
    {
      "notification": bodyNotification,
      "data": dataMap,
      "priority": "high",
      "to": deviceRegistrationToken,
    };

    var responseNotification = http.post(
      Uri.parse("https://fcm.googleapis.com/fcm/send"),
      headers: headerNotification,
      body: jsonEncode(officialNotificationFormat),
    );
  }
  //retrieve the trips KEYS for online user
  //trip key = ride request key
  static void readTripsKeysForOnlineUser(context)
  {
    FirebaseDatabase.instance.ref()
        .child("All Ride Request")
        .orderByChild("userName")
        .equalTo(userModelCurrentInfo!.name)
        .once()
        .then((snap)
    {
      if(snap.snapshot.value != null)
      {
        Map keysTripsId = snap.snapshot.value as Map;

        //count total number trips and share it with Provider
        int overAllTripsCounter = keysTripsId.length;
        Provider.of<AppInfo>(context, listen: false).updateOverAllTripsCounter(overAllTripsCounter);

        //share trips keys with Provider
        List<String> tripsKeysList = [];
        keysTripsId.forEach((key, value)
        {
          tripsKeysList.add(key);
        });
        Provider.of<AppInfo>(context, listen: false).updateOverAllTripsKeys(tripsKeysList);

        //get trips keys data - read trips complete information
        readTripsHistoryInformation(context);
      }
    });
  }

  static void readTripsHistoryInformation(context)
  {
    var tripsAllKeys = Provider.of<AppInfo>(context, listen: false).historyTripsKeysList;

    for(String eachKey in tripsAllKeys)
    {
      FirebaseDatabase.instance.ref()
          .child("All Ride Request")
          .child(eachKey)
          .once()
          .then((snap)
      {
        var eachTripHistory = TripsHistoryModel.fromSnapshot(snap.snapshot);

        if((snap.snapshot.value as Map)["status"] == "ended")
        {
          //update-add each history to OverAllTrips History Data List
          Provider.of<AppInfo>(context, listen: false).updateOverAllTripsHistoryInformation(eachTripHistory);
        }
      });
    }
  }

}