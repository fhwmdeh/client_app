import 'package:flutter/cupertino.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:users/models/directions.dart';

import '../global/global.dart';
import '../models/trips_history_model.dart';

class AppInfo extends ChangeNotifier{
  Directions ?userPickupLocation , userDropoffLocation;
  int countTotalTrips = 0;
  List<String> historyTripsKeysList = [];
  List<TripsHistoryModel> allTripsHistoryInformationList = [];

  num ? callNumber;

  void updatePickupLocationAddress(Directions userPickupAddress){
    userPickupLocation = userPickupAddress;
    notifyListeners();


  }
  void updateDropoffLocationAddress(Directions userDropoffAddress){
    userDropoffLocation = userDropoffAddress;
    notifyListeners();

  }
  updateOverAllTripsCounter(int overAllTripsCounter)
  {
    countTotalTrips = overAllTripsCounter;
    notifyListeners();
  }

  updateOverAllTripsKeys(List<String> tripsKeysList)
  {
    historyTripsKeysList = tripsKeysList;
    notifyListeners();
  }

 updateOverAllTripsHistoryInformation(TripsHistoryModel eachTripHistory)
  {
    allTripsHistoryInformationList.add(eachTripHistory);
    notifyListeners();
  }
  _callNumber(index) async{
    driverList[index]["driver"]["phone"]; //set the number here
    bool? res = await FlutterPhoneDirectCaller.callNumber(index);
  }

}