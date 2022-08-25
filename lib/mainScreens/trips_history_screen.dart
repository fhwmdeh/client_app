import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../info_handler/app_info.dart';
import '../wedgets/history_design_ui.dart';
import 'mainScreen.dart';


class TripsHistoryScreen extends StatefulWidget
{
  @override
  State<TripsHistoryScreen> createState() => _TripsHistoryScreenState();
}




class _TripsHistoryScreenState extends State<TripsHistoryScreen>
{
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Trips History",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close , color: Colors.black,),
          onPressed: ()
          {
            Navigator.push(context, MaterialPageRoute(builder: (context) => mainScreen()));
          },
        ),
      ),
      body: ListView.separated(
        separatorBuilder: (context, i)=> const Divider(
          color: Colors.black,
          thickness: 2,
          height: 2,
        ),
        itemBuilder: (context, i)
        {
          return Card(
            color: Colors.black26,
            child: HistoryDesignUIWidget(
              tripsHistoryModel: Provider.of<AppInfo>(context, listen: false).allTripsHistoryInformationList[i],
            ),
          );
        },
        itemCount: Provider.of<AppInfo>(context, listen: false).allTripsHistoryInformationList.length,
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
      ),
    );
  }
}
