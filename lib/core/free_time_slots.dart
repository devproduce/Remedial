import 'package:first_flutter/core/home_screen.dart';
import 'package:first_flutter/core/input/time_slot_input.dart';
import 'package:first_flutter/core/utils/modal_class.dart';
import 'package:flutter/material.dart';

class FreeTimeSlots extends StatefulWidget {
  const FreeTimeSlots({super.key});

  @override
  State<FreeTimeSlots> createState() => _FreeTimeSlotsState();
}

class _FreeTimeSlotsState extends State<FreeTimeSlots> {
  int? dayIndex;
  List<FreeSlotsModalClass> freeSlotsForADay = [];
  DatabaseService database = DatabaseService();

  @override
  void initState() {
    super.initState();
    refreshTaskList();
  }

  Future<void> refreshTaskList() async {
    if (dayIndex != null) {
      final slots = await database.getTimeSlotsForDay(dayIndex!);
      setState(() {
        freeSlotsForADay = slots;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    final weekdays = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ];
    final List<Color> redShades = [
      Colors.red.shade100,
      Colors.red.shade200,
      Colors.red.shade300,
      Colors.red.shade400,
      Colors.red.shade500,
      Colors.red.shade600,
      Colors.red.shade700,
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      body: Column(
        children: [
          SizedBox(height: screenHeight * 0.05),
          const Icon(Icons.calendar_today, size: 30),
          SizedBox(height: screenHeight * 0.02),
          Text(
            'Select your free time slots',
            style: TextStyle(
              fontSize: screenHeight * 0.03,
              color: const Color(0xFF36454F),
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            '(Multiple per day allowed)',
            style: TextStyle(
              fontSize: screenHeight * 0.02,
              color: const Color(0xFF6A7B8A),
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            flex: 2,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.05,
                horizontal: screenWidth * 0.05,
              ),
              itemCount: weekdays.length,
              itemBuilder: (context, index) {
                final day = weekdays[index];
                final color = redShades[index];
                return Row(
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                      child: ElevatedButton(
                        onPressed: () async {
                          dayIndex = index;
                          await refreshTaskList();
                          showDialog(
                            context: context,
                            builder: (context) => TimeSlotInput(
                              dayIndex: index,
                            ),
                          ).then((_) async {
                            await refreshTaskList();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          fixedSize: Size(
                            screenWidth * 0.35,
                            screenHeight * 0.05,
                          ),
                        ),
                        child: Text(
                          day,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: screenHeight * 0.02,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              
            },
            style: ElevatedButton.styleFrom(
              elevation: 3,
              backgroundColor: Colors.blueAccent,
              alignment: Alignment.center,
              fixedSize: Size(
                screenWidth * 0.5,
                screenHeight * 0.06,
              ),
            ),
            child: Text(
              "DONE",
              style: TextStyle(
                color: Colors.black,
                fontSize: screenHeight * 0.02,
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.1),
        ],
      ),
    );
  }
}
