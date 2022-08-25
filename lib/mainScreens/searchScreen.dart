import 'package:flutter/material.dart';
import 'package:users/assistants/requestAssistant.dart';
import 'package:users/configMap.dart';
import 'package:users/models/pridicted_places.dart';
import 'package:users/wedgets/placePredictionTile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<PridictedPlaces> placePredictedList = [];

  void findPlaceAutocomleteSearch(String  inputText) async {
    if(inputText.length > 1) // must write tow character
    {
      String urlAutocompleteSearch =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapKey&components=country:PS";
      var resAutocompleteSearch = await RequestAssistant.recieveRequest(urlAutocompleteSearch);
      if(resAutocompleteSearch == "failed"){
        return;
      }
      if(resAutocompleteSearch["status"] == "OK"){
        var placePrediction = resAutocompleteSearch["predictions"];
        var placePredictionsList = (placePrediction as List).map((jsonData) => PridictedPlaces.fromjson(jsonData)).toList();

        setState(() {
          placePredictedList = placePredictionsList;
        });
      }

    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(children: [
        //search place ui

        Container(
          height: 250,
          decoration: const BoxDecoration(
            color: Colors.white54,
            boxShadow: [
              BoxShadow(
                color: Colors.white54,
                blurRadius: 8,
                spreadRadius: 0.5,
                offset: Offset(0.7,0.7),

              ),]
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(children: [
              const SizedBox(height: 80.0,),
              Stack(
                children: [
                  GestureDetector(
                    child: const Icon(Icons.arrow_back,
                    color: Colors.black,
                    ),
                    onTap: (){
                      Navigator.pop(context);
                    },
                  ),
                  const Center(
                    child: Text("Search Drop Off Location",
                      style: TextStyle(fontSize: 18.0 , color: Colors.black , fontWeight: FontWeight.bold),

                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0,),
              Row(children: [
                Icon(Icons.adjust_sharp , color: Colors.black,),
                const SizedBox(width: 16.0,),
               Expanded(
                 child:
                 Padding(
                   padding: const EdgeInsets.all(8.0),
                   child: TextField(
                     onChanged: (valueTyped){
                       findPlaceAutocomleteSearch(valueTyped);

                     },
                      decoration: const InputDecoration(
                        hintText: "Search Here",
                        fillColor: Colors.black12,
                        filled: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(
                          left: 18.0,
                          top: 8,
                          bottom: 8,
                        )
                      ),
                    ),
                 ),
               ),
              ],)

            ]),
          ),
        ),
        //display place prediction tile design
        (placePredictedList.length > 0)
            ? Expanded(
          child: ListView.separated(
              physics: const ClampingScrollPhysics(),

              itemBuilder: (context , index){
                return PlacePredictionTileDesign(
                  pridictedPlaces: placePredictedList[index],
                );
              },
              separatorBuilder: (BuildContext context , int index){
                return const Divider(
                  height: 1,
                  color: Colors.black,
                  thickness: 1,
                );
              },
              itemCount: placePredictedList.length,),
        )
            : Container(),
      ]),
    );
  }
}
