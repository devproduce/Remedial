import 'package:first_flutter/core/free_time_slots.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MySchedule extends StatefulWidget {
  const MySchedule({super.key});

  @override
  State<MySchedule> createState() => _MyScheduleState();
}

class _MyScheduleState extends State<MySchedule> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 300,
            child: Text(
          
  "To optimize your task schedule, would you like to share your free time slots or your full schedule for today?",
  style:  TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold,
  fontStyle: FontStyle.italic,
  fontFamily: 'Roboto',
  
  ),

  softWrap: true,
  overflow: TextOverflow.clip,
  textAlign: TextAlign.center,
  
),


          ),
          const SizedBox(
            height: 10,
          ),
          

Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  crossAxisAlignment: CrossAxisAlignment.center, // Evenly distribute buttons
  children: [
    ElevatedButton(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FreeTimeSlots())), // Define action for "Free Time Slots"
      child: const Text('Free Time Slots', style: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 15,


      ),),
      style:  const ButtonStyle(
        backgroundColor:  WidgetStatePropertyAll(Colors.blueAccent),
        fixedSize: WidgetStatePropertyAll(Size(160, 10))
        

      ),
    ),
    ElevatedButton(
      onPressed: () => null, // Define action for "Schedule"
      child: const Text('Schedule',style: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 15,
        


      ),),
      style:  const ButtonStyle(
        backgroundColor:  WidgetStatePropertyAll(Colors.blueAccent),
        fixedSize: WidgetStatePropertyAll(Size(160, 10))
        

      ),

    ),
  ],
),
           
        ],
      )
    );
  }
}