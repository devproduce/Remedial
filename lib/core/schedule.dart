import 'package:first_flutter/core/free_time_slots.dart';
import 'package:flutter/material.dart';

class MySchedule extends StatefulWidget {
  const MySchedule({super.key});

  @override
  State<MySchedule> createState() => _MyScheduleState();
}

class _MyScheduleState extends State<MySchedule> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.08, // Dynamic horizontal padding
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: screenWidth * 0.9, // Dynamic width for the text
                child: Text(
                  "To optimize your task schedule, would you like to share your free time slots or your full schedule for today?",
                  style: TextStyle(
                    fontSize: screenWidth * 0.06, // Scaled font size
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Roboto',
                    height: 1.5, // Increased line height for readability
                  ),
                  softWrap: true,
                  overflow: TextOverflow.clip,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: screenHeight * 0.05), // Increased dynamic spacing
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FreeTimeSlots(),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      fixedSize: Size(
                        screenWidth * 0.4, // Scaled button width
                        screenHeight * 0.07, // Scaled button height
                      ),
                      elevation: 3,
                    ),
                    child: Text(
                      'Free Time Slots',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.040, // Scaled button text
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Define action for "Schedule"
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      fixedSize: Size(
                        screenWidth * 0.4, // Scaled button width
                        screenHeight * 0.07, // Scaled button height
                      ),
                      elevation: 3,
                    ),
                    child: Text(
                      'Schedule',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.040, // Scaled button text
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
