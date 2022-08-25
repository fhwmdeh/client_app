import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users/assistants/requestAssistant.dart';
import 'package:users/configMap.dart';
import 'package:users/global/global.dart';
import 'package:users/info_handler/app_info.dart';
import 'package:users/models/directions.dart';
import 'package:users/wedgets/progressDialog.dart';
import '../models/pridicted_places.dart';

class PlacePredictionTileDesign extends StatefulWidget {
 final PridictedPlaces ? pridictedPlaces;

 PlacePredictionTileDesign({this.pridictedPlaces});

  @override
  State<PlacePredictionTileDesign> createState() => _PlacePredictionTileDesignState();
}

class _PlacePredictionTileDesignState extends State<PlacePredictionTileDesign> {
 getPlaceDirectionDetails(String? place_id , context)async{
   showDialog(
       context: context,
       builder: (BuildContext context) => progressDialog(
            message: "please Wait..",
       ),
   );

   String placeDirectionDetailsUrl =
       "https://maps.googleapis.com/maps/api/place/details/json?place_id=$place_id&key=$mapKey";
   var resfromApi = await RequestAssistant.recieveRequest(placeDirectionDetailsUrl);
   Navigator.pop(context);
   if(resfromApi == "failed"){
     return;
   }
   if(resfromApi["status"] == "OK"){

     Directions directions = Directions();
     directions.locationId = place_id;
     directions.locationName= resfromApi["result"]["name"];
     directions.locationlatitude =resfromApi["result"]["geometry"]["location"]["lat"];
     directions.locationlongitude = resfromApi["result"]["geometry"]["location"]["lng"];

     Provider.of<AppInfo>(context , listen: false).updateDropoffLocationAddress(directions);

     setState(() {
       userDropOffAddress =  directions.locationName!;
     });

     Navigator.pop( context, "obtainedDropoff");


   }

 }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.white54,
        ),
        onPressed: (){
          getPlaceDirectionDetails(widget.pridictedPlaces!.place_id, context);
        },
        child:
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(children: [
              Icon(Icons.add_location_alt_rounded , color: Colors.black,),
              const SizedBox(width: 14.0,),
              Expanded(child:
              Column(
                  crossAxisAlignment: CrossAxisAlignment.center ,
                  children: [
                    const SizedBox(height: 8.0,),
                    Text(
                        widget.pridictedPlaces!.main_text!,
                        overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15.0,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2.0,),
                    Text(
                      widget.pridictedPlaces!.secondary_text!,
                      overflow: TextOverflow.ellipsis,
                      style: const  TextStyle(
                        fontSize: 11.0,
                        color: Colors.black45,
                      ),
                    ),
                    const SizedBox(height: 2.0,),
              ]),
              ),
            ],),
          ),
        )

    );
  }
}
