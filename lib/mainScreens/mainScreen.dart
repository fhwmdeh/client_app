import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:users/main.dart';
import 'package:users/mainScreens/rate_driver_screen.dart';
import 'package:users/mainScreens/searchScreen.dart';
import 'package:users/mainScreens/select_active_driver.dart';
import 'package:users/mainScreens/select_nearest_active_driver_screen%20(5).dart';
import 'package:users/models/directionDetailsInfo.dart';
import 'package:users/models/user_model_drawer.dart';
import 'package:users/wedgets/my_drawer.dart';
import 'package:users/wedgets/progressDialog.dart';

import '../assistants/assistants_method.dart';
import '../assistants/geofire_assistant.dart';
import '../global/global.dart';
import '';
import '../info_handler/app_info.dart';
import '../models/active_nearby_available_drivers.dart';
import '../wedgets/pay_fare_amount_dialog.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class mainScreen extends StatefulWidget {


  @override
  State<mainScreen> createState() => _mainScreenState();
}

class _mainScreenState extends State<mainScreen> {

  GoogleMapController? newGoogleMapController;

  Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> skey = GlobalKey<ScaffoldState>();
  double searchLocationContainerHeight = 220.0;
  double waitingResponseFromDriverContainerHeight = 0;
  double assignedDriverInfoContainerHeight = 0;

  Position? userCurrentPosition;
  var geolocator = Geolocator();

  LocationPermission? _locationPermission;
  double bottompaddingOffMap = 0;

  List<LatLng> plineCoOrdinatesList = [];
  Set<Polyline> polylineSet = {};
  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};
  String userName = "Your Name ";
  String userEmail = "Your Email ";

  bool openNavigationDrawer = true;
  bool activeNearbyDriverKeysLoaded = false;
  BitmapDescriptor? activeNearbyIcon;

  List<ActiveNearbyAvailableDrivers> onlineNearByAvailableDriversList=[];
  DatabaseReference ? refRideRequest;
  String driverRideStatus = "Driver is Coming";
  StreamSubscription<DatabaseEvent>? tripRideRequestInfoStreamSubscription;

  String userRideRequestStatus="";
  bool requestPositionInfo = true;




  checkIfPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  locateUserPosition() async {

    Position currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = currentPosition;
    LatLng LatLngPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    CameraPosition cameraPosition = CameraPosition(target: LatLngPosition, zoom: 14);
    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    String humanReadableAddress = await AssistantsMethods.searchAddressForGeographicCoOrdinate(userCurrentPosition!, context);
    print("this is you address : " + humanReadableAddress);
    userName = userModelCurrentInfo!.name!;
    userEmail = userModelCurrentInfo!.email!;
    initializeGeoFireListener();
    AssistantsMethods.readTripsKeysForOnlineUser(context);
  }

  @override
  void initState() {
    super.initState();
    checkIfPermissionAllowed();
  }
  saveRideRequestInformation(){
    //save The Ride Request Information

    refRideRequest = FirebaseDatabase.instance.ref().child("All Ride Request").push();

    var originLocation = Provider.of<AppInfo>(context, listen: false).userPickupLocation;
    var destinationLocation = Provider.of<AppInfo>(context, listen: false).userDropoffLocation;


    Map originLocationMap =
    {
      "latitude" : originLocation!.locationlatitude.toString(),
      "longitude" : originLocation.locationlongitude.toString(),

    };
    Map destinationLocationMap =
    {
      "latitude" : destinationLocation!.locationlatitude.toString(),
      "longitude" : destinationLocation.locationlongitude.toString(),

    };
    Map userInformationMap ={
      "origin" : originLocationMap,
      "destination" : destinationLocationMap,
      "time" : DateTime.now().toString(),
      "userName" : userModelCurrentInfo!.name,
      "userPhone" : userModelCurrentInfo!.phone,
      "originAddress" : originLocation.locationName,
      "destinationAddress" : destinationLocation.locationName,
      "driverId" : "waititng",

    };

    refRideRequest!.set(userInformationMap);

    tripRideRequestInfoStreamSubscription = refRideRequest!.onValue.listen((eventSnap) async
    {
      if(eventSnap.snapshot.value == null)
      {
        return;
      }

      if((eventSnap.snapshot.value as Map)["car-details"] != null)
      {
        setState(() {
          driverCarDetails = (eventSnap.snapshot.value as Map)["car-details"].toString();
        });
      }

      if((eventSnap.snapshot.value as Map)["driverPhone"] != null)
      {
        setState(() {
          driverPhone = (eventSnap.snapshot.value as Map)["driverPhone"].toString();
        });
      }

      if((eventSnap.snapshot.value as Map)["driverName"] != null)
      {
        setState(() {
          driverName = (eventSnap.snapshot.value as Map)["driverName"].toString();
        });
      }

      if((eventSnap.snapshot.value as Map)["status"] != null)
      {
        userRideRequestStatus = (eventSnap.snapshot.value as Map)["status"].toString();
      }

      if((eventSnap.snapshot.value as Map)["driverLocation"] != null)
      {
        double driverCurrentPositionLat = double.parse((eventSnap.snapshot.value as Map)["driverLocation"]["latitude"].toString());
        double driverCurrentPositionLng = double.parse((eventSnap.snapshot.value as Map)["driverLocation"]["longitude"].toString());

        LatLng driverCurrentPositionLatLng = LatLng(driverCurrentPositionLat, driverCurrentPositionLng);

        //status = accepted
        if(userRideRequestStatus == "accepted")
        {
          updateArrivalTimeToUserPickupLocation(driverCurrentPositionLatLng);
        }

        //status = arrived
        if(userRideRequestStatus == "arrived")
        {
          setState(() {
            driverRideStatus = "Driver has Arrived";
          });
        }

        ////status = ontrip
        if(userRideRequestStatus == "ontrip")
        {
          updateReachingTimeToUserDropOffLocation(driverCurrentPositionLatLng);
        }
        //status = ended
        if(userRideRequestStatus == "ended")
        {
          if((eventSnap.snapshot.value as Map)["fareAmount"] != null)
          {
            double fareAmount = double.parse((eventSnap.snapshot.value as Map)["fareAmount"].toString());

            var response = await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext c) => PayFareAmountDialog(
                fareAmount: fareAmount,
              ),
            );

            if(response == "cashPayed")
            {
              //user can rate the driver now
              if((eventSnap.snapshot.value as Map)["driverId"] != null)
              {
                String assignedDriverId = (eventSnap.snapshot.value as Map)["driverId"].toString();

                Navigator.push(context, MaterialPageRoute(builder: (c)=> RateDriverScreen(
                  assignedDriverId: assignedDriverId,
                )));

                refRideRequest!.onDisconnect();
                tripRideRequestInfoStreamSubscription!.cancel();
              }
            }
          }
        }

      }
    });

    onlineNearByAvailableDriversList = GeoFireAssistant.activeNearbyAvailableDriversList;
    searchNearestOnlineDrivers();

  }
  updateArrivalTimeToUserPickupLocation(driverCurrentPositionLatLng) async
  {
    if(requestPositionInfo == true)
    {
      requestPositionInfo = false;

      LatLng userPickUpPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

      var directionDetailsInfo = await AssistantsMethods.obtainOrginToDistinationDirectionDetails(
        driverCurrentPositionLatLng,
        userPickUpPosition,
      );

      if(directionDetailsInfo == null)
      {
        return;
      }

      setState(() {
        driverRideStatus =  "Driver is Coming :: " + directionDetailsInfo.duration_text.toString();
      });

      requestPositionInfo = true;
    }
  }

  updateReachingTimeToUserDropOffLocation(driverCurrentPositionLatLng) async
  {
    if(requestPositionInfo == true)
    {
      requestPositionInfo = false;

      var dropOffLocation = Provider.of<AppInfo>(context, listen: false).userDropoffLocation;

      LatLng userDestinationPosition = LatLng(
          dropOffLocation!.locationlatitude!,
          dropOffLocation.locationlongitude!
      );

      var directionDetailsInfo = await AssistantsMethods.obtainOrginToDistinationDirectionDetails(
        driverCurrentPositionLatLng,
        userDestinationPosition,
      );

      if(directionDetailsInfo == null)
      {
        return;
      }

      setState(() {
        driverRideStatus =  "Going towards Destination :: " + directionDetailsInfo.duration_text.toString();
      });

      requestPositionInfo = true;
    }
  }
  searchNearestOnlineDrivers()async
  {
    //no active driver available
    if(onlineNearByAvailableDriversList.length ==0){

      refRideRequest!.remove();
      //cancel the ride request
      setState(() {
        polylineSet.clear();
        markerSet.clear();
        circleSet.clear();
        plineCoOrdinatesList.clear();
      });
      Fluttertoast.showToast(msg: " No Online Nearest Drivers Available , Search Again After Sometime  , Restarting The App");

      Future.delayed(const Duration(milliseconds: 3000),(){
      SystemNavigator.pop();
      }
      );

      return;

    }
    await retrieveOnlineDriverInfo(onlineNearByAvailableDriversList);

    var response = await Navigator.push(context, MaterialPageRoute(builder: (context) => selectNearestActiveDriversSecreen(
        refRideRequest : refRideRequest),));

    if(response == "driverChoosed"){
      FirebaseDatabase.instance.ref().child("driver").child(chosenDriverId!).once().then((snap){
        if(snap.snapshot.value != null ){

          //send notification to that specific driver

          sendNotificationToDriverNow(chosenDriverId!);

          //Display Waiting Response UI from a Driver

          showWaitingResponseFromDriverUI();

          //Response from a Driver
          FirebaseDatabase.instance.ref()
              .child("driver")
              .child(chosenDriverId!)
              .child("newRideStatus")
              .onValue.listen((eventSnapshot)
          {
            //1. driver has cancel the rideRequest :: Push Notification
            // (newRideStatus = idle)
            if(eventSnapshot.snapshot.value == "idle")
            {
              Fluttertoast.showToast(msg: "The driver has cancelled your request. Please choose another driver.");

              Future.delayed(const Duration(milliseconds: 3000), ()
              {
                Fluttertoast.showToast(msg: "Please Restart App Now.");

                SystemNavigator.pop();
              });
            }


            //2. driver has accept the rideRequest :: Push Notification
            // (newRideStatus = accepted)
            if(eventSnapshot.snapshot.value == "accepted")
            {
              //design and display ui for displaying assigned driver information
              showUIForAssignedDriverInfo();
            }
          });
        }
        else{
          Fluttertoast.showToast(msg: "This Driver Is Not Exist");
        }

      });
    }
  }
  showUIForAssignedDriverInfo()
  {
    setState(() {
      waitingResponseFromDriverContainerHeight = 0;
      searchLocationContainerHeight = 0;
      assignedDriverInfoContainerHeight = 240;
    });
  }

  showWaitingResponseFromDriverUI()
  {
    setState(() {
      searchLocationContainerHeight = 0;
      waitingResponseFromDriverContainerHeight = 220;
    });
  }
  sendNotificationToDriverNow(String chosenDriverId)
  {
    //assign/SET rideRequestId to newRideStatus in
    // Drivers Parent node for that specific choosen driver
    FirebaseDatabase.instance.ref()
        .child("driver")
        .child(chosenDriverId)
        .child("newRideStatus")
        .set(refRideRequest!.key);

    //automate the push notification
    FirebaseDatabase.instance.ref()
        .child("driver")
        .child(chosenDriverId).child("token").once().then((snap){
          if(snap.snapshot.value != null){
            String deviceRegistrationToken = snap.snapshot.value.toString();

            //send Notification Now
            AssistantsMethods.sendNotificationToDriverNow(
                deviceRegistrationToken,
                refRideRequest!.key.toString(),
                context);
          }
          else
          {
            Fluttertoast.showToast(msg: "Please Choose Another Driver ");
            return;
          }
    });
  }
   //active driver available
  retrieveOnlineDriverInfo(List onlineNearDriversList)async{
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("driver");

    for(int i=0 ;i< onlineNearDriversList.length; i++)
    {
      await ref.child(onlineNearDriversList[i].driverId.toString()).once().then((dataSnapshot){
        var driverInfoKey = dataSnapshot.snapshot.value;
        driverList.add(driverInfoKey);


      });
    }
  }


  @override
  Widget build(BuildContext context) {

    createActiveNearByDriverIconMarker();

    return Scaffold(
      key: skey,
      drawer: myDrwer(
        name: userName,
        email: userEmail,

      ),
      body: Stack(children: [
        GoogleMap(
          padding: EdgeInsets.only(bottom: bottompaddingOffMap),
          mapType: MapType.normal,
          myLocationEnabled: true,
          zoomControlsEnabled: true,
          zoomGesturesEnabled: true,
          initialCameraPosition: _kGooglePlex,
          polylines: polylineSet,
          markers: markerSet,
          circles: circleSet,
          onMapCreated: (GoogleMapController controller) {
            _controllerGoogleMap.complete(controller);
            newGoogleMapController = controller;
            setState(() {
              bottompaddingOffMap = 220;
            });
            locateUserPosition();
          },
        ),

        //Drawer Button

        Positioned(
            top: 50,
            left: 22,
            child: GestureDetector(
              onTap: () {
                if (openNavigationDrawer) {
                  skey.currentState!.openDrawer();
                } else //restart Minimize app
                    {
                  SystemNavigator.pop();
                }
              },
              child: CircleAvatar(

                backgroundColor: Colors.white,
                child: Icon(
                  openNavigationDrawer ? Icons.menu : Icons.close,
                  color: Colors.black,),
              ),

            )
        ),

        //Search location Conrainer

        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: AnimatedSize(
            curve: Curves.easeIn,
            duration: const Duration(milliseconds: 120),
            child: Container(
              height: searchLocationContainerHeight,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  )
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 20),
                child: Column(children: [
                  //row from my location
                  Row(children: [
                    const Icon(Icons.add_location_alt_outlined, color: Colors
                        .black,),
                    const SizedBox(width: 12.0,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("From",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 15.0),),
                        Text(
                          Provider
                              .of<AppInfo>(context)
                              .userPickupLocation != null
                              ? Provider
                              .of<AppInfo>(context)
                              .userPickupLocation!
                              .locationName!
                              : "you Current Location"
                          ,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 15.0),),
                      ],
                    ),
                  ],),

                  const SizedBox(height: 10.0,),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.black45,
                  ),
                  const SizedBox(height: 10.0,),
                  GestureDetector(
                    onTap: () async {
                      var resFromSearchScreen = await Navigator.push(context,
                          MaterialPageRoute(
                              builder: (context) => SearchScreen()));
                      if (resFromSearchScreen == "obtainedDropoff") {
                        setState(() {
                          openNavigationDrawer = false;
                        });
                        //draw polyline
                        await drawPolylineFromSourceToDistination();
                      }
                    },
                    child: Row(children: [
                      const Icon(
                        Icons.add_location_alt_outlined, color: Colors.black,),
                      const SizedBox(width: 12.0,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("To",
                            style: const TextStyle(
                                color: Colors.black, fontSize: 15.0),),
                          Text(
                            Provider.of<AppInfo>(context).userDropoffLocation != null
                                ? Provider.of<AppInfo>(context).userDropoffLocation!.locationName!
                                : "Where To Go ",
                            style: const TextStyle(
                                color: Colors.black, fontSize: 15.0),),
                        ],
                      ),
                    ],),
                  ),
                  const SizedBox(height: 10.0,),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.black45,
                  ),
                  const SizedBox(height: 10.0,),

                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.black,
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: () {
                        if(Provider.of<AppInfo>(context , listen: false).userDropoffLocation != null){

                         saveRideRequestInformation();

                        }else{
                          Fluttertoast.showToast(msg: "Please Selecet A distination Locaion");
                        }

                      },
                      child: Text("Request A Ride", style: TextStyle(
                          fontSize: 25, fontWeight: FontWeight.bold))
                  ),
                ]),
              ),
            ),
          ),
        ),

        //ui for waiting response from driver
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: waitingResponseFromDriverContainerHeight,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: AnimatedTextKit(
                  animatedTexts: [
                    FadeAnimatedText(
                      'Waiting for Response\nfrom Driver',
                      duration: const Duration(seconds: 6),
                      textAlign: TextAlign.center,
                      textStyle: const TextStyle(fontSize: 30.0, color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    ScaleAnimatedText(
                      'Please wait...',
                      duration: const Duration(seconds: 10),
                      textAlign: TextAlign.center,
                      textStyle: const TextStyle(fontSize: 32.0, color: Colors.red, fontFamily: 'Canterbury'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        //ui for displaying assigned driver information
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: assignedDriverInfoContainerHeight,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //status of ride
                  Center(
                    child: Text(
                      driverRideStatus,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20.0,
                  ),

                  const Divider(
                    height: 2,
                    thickness: 2,
                    color: Colors.black54,
                  ),

                  const SizedBox(
                    height: 20.0,
                  ),

                  //driver vehicle details
                  Text(
                    driverCarDetails,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(
                    height: 2.0,
                  ),

                  //driver name
                  Text(
                    driverName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(
                    height: 20.0,
                  ),

                  const Divider(
                    height: 2,
                    thickness: 2,
                    color: Colors.black54,
                  ),

                  const SizedBox(
                    height: 20.0,
                  ),

                  //call driver button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: ()async
                      {
                      // callNumber;
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                      ),
                      icon: const Icon(
                        Icons.phone_android,
                        color: Colors.white,
                        size: 22,
                      ),
                      label: const Text(
                        "Call Driver",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
   //Draw polyline method
  Future<void> drawPolylineFromSourceToDistination() async {
    var sourcePosition = Provider
        .of<AppInfo>(context, listen: false)
        .userPickupLocation;
    var destinationPosition = Provider
        .of<AppInfo>(context, listen: false)
        .userDropoffLocation;

    var sourceLatLng = LatLng(
        sourcePosition!.locationlatitude!, sourcePosition.locationlongitude!);
    var destinationLatLng = LatLng(destinationPosition!.locationlatitude!,
        destinationPosition.locationlongitude!);
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            progressDialog(message: "please wait ... ",));

    var directionDetailsInfo = await AssistantsMethods.obtainOrginToDistinationDirectionDetails(sourceLatLng, destinationLatLng);

    setState(() {
      tripDirectionDetailsInfo = directionDetailsInfo;
    });

    Navigator.pop(context);

    print("this is the road");
    print(directionDetailsInfo!.e_points);


    PolylinePoints plinePoints = PolylinePoints();
    List<PointLatLng> decodedPlinePointsList = plinePoints.decodePolyline(
        directionDetailsInfo.e_points!);

    plineCoOrdinatesList.clear();

    if (decodedPlinePointsList.isNotEmpty) {
      decodedPlinePointsList.forEach((PointLatLng pointLatLng) {
        plineCoOrdinatesList.add(
            LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polylineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.blue,
        polylineId: const PolylineId("PolylineID"),
        jointType: JointType.round,
        points: plineCoOrdinatesList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      polylineSet.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if (sourceLatLng.latitude > destinationLatLng.latitude &&
        sourceLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng =
          LatLngBounds(southwest: destinationLatLng, northeast: sourceLatLng);
    } else if (sourceLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng =
          LatLngBounds(
              southwest: LatLng(
                  sourceLatLng.latitude, destinationLatLng.longitude),
              northeast: LatLng(
                  destinationLatLng.latitude, sourceLatLng.longitude));
    } else if (sourceLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng =
          LatLngBounds(
              southwest: LatLng(
                  destinationLatLng.latitude, sourceLatLng.longitude),
              northeast: LatLng(
                  sourceLatLng.latitude, destinationLatLng.longitude));
    }
    else {
      boundsLatLng =
          LatLngBounds(southwest: sourceLatLng, northeast: destinationLatLng);
    }
    newGoogleMapController!.animateCamera(
        CameraUpdate.newLatLngBounds(boundsLatLng, 65));
    Marker originMarker = Marker(
        markerId: MarkerId("OriginID"),
        infoWindow: InfoWindow(
            title: sourcePosition.locationName, snippet: "origin"),
        position: sourceLatLng,

    );
    Marker destinationMarker = Marker(
        markerId: MarkerId("DestinationID"),
        infoWindow: InfoWindow(
            title: destinationPosition.locationName, snippet: "Destination"),
        position: destinationLatLng,
        icon: BitmapDescriptor.defaultMarker
    );

    setState(() {
      markerSet.add(originMarker);
      markerSet.add(destinationMarker);
    });
    Circle originCircle = Circle(
      circleId: const CircleId("originID"),
      fillColor: Colors.lightBlueAccent,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: sourceLatLng,
    );
    Circle destinationCircle = Circle(
      circleId: const CircleId("DestinationID"),
      fillColor: Colors.red,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      circleSet.add(originCircle);
      circleSet.add(destinationCircle);
    });
  }
   //live moving location method
  initializeGeoFireListener()
  {
    Geofire.initialize("activeDrivers");

    Geofire.queryAtLocation(
        userCurrentPosition!.latitude, userCurrentPosition!.longitude, 20)!
        .listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack)
            {
        //whenever any driver become active/online
          case Geofire.onKeyEntered:
            ActiveNearbyAvailableDrivers activeNearbyAvailableDriver = ActiveNearbyAvailableDrivers();
            activeNearbyAvailableDriver.locationLatitude = map['latitude'];
            activeNearbyAvailableDriver.locationLongitude = map['longitude'];
            activeNearbyAvailableDriver.driverId = map['key'];
            GeoFireAssistant.activeNearbyAvailableDriversList.add(activeNearbyAvailableDriver);
            if(activeNearbyDriverKeysLoaded == true)
            {
              displayActiveDriversOnUsersMap();
            }
            break;

        //whenever any driver become non-active/offline
          case Geofire.onKeyExited:
            GeoFireAssistant.deleteOfflineDriverFromList(map['key']);
            displayActiveDriversOnUsersMap();
            break;

        //whenever driver moves - update driver location
          case Geofire.onKeyMoved:
            ActiveNearbyAvailableDrivers activeNearbyAvailableDriver = ActiveNearbyAvailableDrivers();
            activeNearbyAvailableDriver.locationLatitude = map['latitude'];
            activeNearbyAvailableDriver.locationLongitude = map['longitude'];
            activeNearbyAvailableDriver.driverId = map['key'];
            GeoFireAssistant.updateActiveNearbyAvailableDriverLocation(activeNearbyAvailableDriver);
            displayActiveDriversOnUsersMap();
            break;

        //display those online/active drivers on user's map
          case Geofire.onGeoQueryReady:
            activeNearbyDriverKeysLoaded = true;
            displayActiveDriversOnUsersMap();
            break;
        }
      }

      setState(() {});
    });
  }
  //active driver method

  displayActiveDriversOnUsersMap()
  {
    setState(() {
      markerSet.clear();
      circleSet.clear();

      Set<Marker> driversMarkerSet = Set<Marker>();

      for(ActiveNearbyAvailableDrivers eachDriver in GeoFireAssistant.activeNearbyAvailableDriversList)
      {
        LatLng eachDriverActivePosition = LatLng(eachDriver.locationLatitude!, eachDriver.locationLongitude!);

        Marker marker = Marker(
          markerId: MarkerId("driver"+eachDriver.driverId!),
          position: eachDriverActivePosition,
          icon: activeNearbyIcon!,
          rotation: 360,
        );

        driversMarkerSet.add(marker);
      }

      setState(() {
        markerSet = driversMarkerSet;
      });
    });
  }

  createActiveNearByDriverIconMarker()
  {
    if(activeNearbyIcon == null)
    {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car.png").then((value)
      {
        activeNearbyIcon = value;
      });
    }
  }

}