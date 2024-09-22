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
          const SizedBox(height: 40),
          const Icon(Icons.calendar_today),
          const SizedBox(height: 10),
          const Text(
            'Select your free time slots',
            style: TextStyle(
              fontSize: 26,
              color: Color(0xFF36454F),
              fontWeight: FontWeight.w900,
            ),
          ),
          const Text(
            '(Multiple per day allowed)',
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFF6A7B8A),
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            flex: 2,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 50, left: 5, right: 100),
              itemCount: weekdays.length,
              itemBuilder: (context, index) {
                final day = weekdays[index];
                final color = redShades[index];
                return Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          dayIndex = index;
                          await refreshTaskList();
                          showDialog(
                            context: context,
                            builder: (context) => TimeSlotInput.withIndex(
                              dayIndex,
                              freeSlotsForADay,
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
                          fixedSize: const Size(130, 30),
                        ),
                        child: Text(
                          day,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
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
            onPressed: () {},
            child: const Text(
              "DONE",
              style: TextStyle(color: Colors.black),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 3,
              backgroundColor: Colors.blueAccent,
              alignment: Alignment.center,
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
