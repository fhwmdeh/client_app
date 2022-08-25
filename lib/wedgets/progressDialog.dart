import 'package:flutter/material.dart';


class progressDialog extends StatelessWidget {

   String? message;
   progressDialog({this.message});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: Container(
        margin: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              const SizedBox(width: 6.0,),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
              const SizedBox(width: 26.0,),

              Text(message!,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,

                ),
              ),


            ],
          ),
        ),
      ),
    );
  }
}
