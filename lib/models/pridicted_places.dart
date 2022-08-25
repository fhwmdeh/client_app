import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PridictedPlaces{
  String ? place_id;
  String ? main_text;
  String ? secondary_text;

  PridictedPlaces({
    this.place_id,
    this.main_text,
    this.secondary_text,
});
  PridictedPlaces.fromjson(Map<String , dynamic> jsonData){
    place_id =jsonData["place_id"];
    main_text =jsonData["structured_formatting"]["main_text"];
    secondary_text =jsonData["structured_formatting"]["secondary_text"];
  }

}