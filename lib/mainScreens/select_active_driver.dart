import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import 'package:users/assistants/assistants_method.dart';
import 'package:users/global/global.dart';


class selectNearestActiveDriversSecreen extends StatefulWidget {

  DatabaseReference ? refRideRequest;
  selectNearestActiveDriversSecreen({this.refRideRequest});

  @override
  State<selectNearestActiveDriversSecreen> createState() => _selectNearestActiveDriversSecreenState();
}

class _selectNearestActiveDriversSecreenState extends State<selectNearestActiveDriversSecreen> {

  String fareAmount="" ;

  getFareAmountByCarType (int index ){
    if(tripDirectionDetailsInfo !=null){
      if(driverList[index]["car-details"]["type"].toString() == "Bike"){

        fareAmount = (AssistantsMethods.calculateFairAmountFromOriginToDestinatation(tripDirectionDetailsInfo!) / 1.5).toStringAsFixed(1);


      }
      if(driverList[index]["car-details"]["type"].toString() == "Uber-X"){

        fareAmount = (AssistantsMethods.calculateFairAmountFromOriginToDestinatation(tripDirectionDetailsInfo!)).toStringAsFixed(1);

      }
      if(driverList[index]["car-details"]["type"].toString() == "Uber-go"){
        fareAmount = (AssistantsMethods.calculateFairAmountFromOriginToDestinatation(tripDirectionDetailsInfo!).toString());

      }
    }
    return fareAmount;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black45,
        title: const Text("Nearest Online Drivers" ,
        style: TextStyle(fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: (){
            // we have to delete a request from database
            widget.refRideRequest!.remove();
            Fluttertoast.showToast(msg: "You Have Canceled Your Request ...");
            SystemNavigator.pop();

          },
        ),

      ),
      body: ListView.builder(
        itemCount: driverList.length,
        itemBuilder: (BuildContext context , int index){
          return GestureDetector(
            onTap: (){
              setState(() {
                chosenDriverId = driverList[index]["id"].toString();
              });
              Navigator.pop(context, "driverChoosed");
            },
            child: Card(
              color: Colors.grey,
              elevation: 3,
              shadowColor: Colors.grey,
              margin: EdgeInsets.all(8),
              child: ListTile(
                leading: Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Image.asset(
                      "images/" + driverList[index]["car-details"]["type"].toString() + ".png"
                  ),
                ),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      driverList[index]["name"],
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.white,
                      ),
                    ),
                  Text(
                    driverList[index]["car-details"]["car-Moder"],
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.white,
                      )
                  ),
                    SmoothStarRating(
                      rating: driverList[index]["ratings"] == null ? 0.0 : double.parse(driverList[index]["ratings"]),                      color: Colors.amber,
                      borderColor: Colors.black26,
                      allowHalfRating: true,
                      starCount: 5,
                      size: 15,
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //Fair amount doller
                     Text(
                         "\₪ " + getFareAmountByCarType(index),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2,),
                    //the space km
                    Text(
                     tripDirectionDetailsInfo != null ? tripDirectionDetailsInfo!.duration_text! :"",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      tripDirectionDetailsInfo != null ? tripDirectionDetailsInfo!.distance_text! :"",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                  ],
                ),
              ),
            ),
          );
        },

      ),
    );
  }
}
