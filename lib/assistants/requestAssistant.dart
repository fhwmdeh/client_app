import 'dart:convert';

import 'package:http/http.dart' as http;

class RequestAssistant{
  static Future<dynamic> recieveRequest(String url)async{
    http.Response httpRespose = await http.get(Uri.parse(url));
    try{
      if(httpRespose.statusCode == 200){
        String resData = httpRespose.body; // from json response data
        var decodeResponseData = jsonDecode(resData);
        return decodeResponseData;
      }else{
        return "failed";
      }
    }catch(exp){
      return "failed";
    }
  }
}