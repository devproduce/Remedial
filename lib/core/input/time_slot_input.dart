import 'package:first_flutter/core/free_time_slots.dart';
import 'package:first_flutter/core/utils/modal_class.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimeSlotInput extends StatefulWidget {
  final int? dayIndex;
  final List<FreeSlotsModalClass> initTimeSlots;

  TimeSlotInput.withIndex(this.dayIndex, this.initTimeSlots);

  @override
  State<TimeSlotInput> createState() => _TimeSlotInputState();
}

class _TimeSlotInputState extends State<TimeSlotInput> {
  String selectedItems = '0';
  final slotItems = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  List<TimeSlotData> timeSlotsData = [];
  List<FreeSlotsModalClass> freeTimeSlots = [];
  DatabaseService database = DatabaseService();
  var _initialSelection = '0';
  List<FreeSlotsModalClass> freeTime = [];

  void _setInitState() {
    if (widget.initTimeSlots.isNotEmpty) {
      var num = widget.initTimeSlots[0].numberOfFreeSlots;
      setState(() {
        _initialSelection = num.toString();
        selectedItems = _initialSelection;
        timeSlotsData = List.generate(
          int.parse(selectedItems),
          (index) => TimeSlotData(),
        );
      });
    }
  }

  bool isFreeTimeSlotsEmpty() {
    if (freeTimeSlots.isEmpty) {
      return true;
    } else{
      return false;

    }
      
  }

  @override
  void initState() {
    super.initState();
    _setInitState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 5,
      insetPadding: const EdgeInsets.symmetric(vertical: 250, horizontal: 40),
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      backgroundColor: Colors.lightBlue.shade100,
      child: Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            "Time Slots",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 10),
              const Text(
                "No. Of Free Time Slots",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigoAccent,
                ),
              ),
              const SizedBox(width: 10),
              DropdownMenu<String>(
                dropdownMenuEntries: slotItems.map((slot) {
                  return DropdownMenuEntry<String>(
                    value: slot,
                    label: slot,
                  );
                }).toList(),
                initialSelection: _initialSelection,
                hintText: 'No. of Time Slots',
                onSelected: (newItem) {
                  setState(() {
                    selectedItems = newItem!;
                    timeSlotsData = List.generate(
                      int.parse(selectedItems),
                      (index) => TimeSlotData(),
                    );
                  });
                },
              ),
            ],
          ),
          Expanded(
            flex: 2,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: timeSlotsData.length,
              itemBuilder: (context, index) {
                return TimeSlot(
                  onTimesChanged: (fromTime, toTime) {
                    timeSlotsData[index].fromTime = fromTime;
                    timeSlotsData[index].toTime = toTime;
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (isFreeTimeSlotsEmpty()) {
                freeTimeSlots = List.generate(
                    int.parse(selectedItems),
                    (index) => FreeSlotsModalClass(
                        widget.dayIndex,
                        int.parse(selectedItems),
                        timeSlotsData[index].fromTime,
                        timeSlotsData[index].toTime));
                        insertTimeSlotList(freeTimeSlots,true);
              } else {
                freeTimeSlots = List.generate(
                    int.parse(selectedItems),
                    (index) => FreeSlotsModalClass.withId(
                      widget.initTimeSlots[index].id,
                      widget.dayIndex,
                        int.parse(selectedItems),
                        timeSlotsData[index].fromTime,
                        timeSlotsData[index].toTime
                        ));
                        insertTimeSlotList(freeTimeSlots,false);
              }

              

              _initialSelection = selectedItems;

              Navigator.pop(context, true);
            },
            child: const Text('SUBMIT'),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void insertTimeSlotList(List<FreeSlotsModalClass> timeslots , bool addTimeSlot) {
    for (int i = 0; i < timeslots.length; i++) {
      if (addTimeSlot) {
        database.addTimeSlot(timeslots[i]);
      } else {
        database.updateTimeSlot(timeslots[i]);
      }
    }
  }
}

class TimeSlotData {
  String? fromTime;
  String? toTime;
}

class TimeSlot extends StatefulWidget {
  final void Function(String? fromTime, String? toTime) onTimesChanged;

  const TimeSlot({super.key, required this.onTimesChanged});

  @override
  State<TimeSlot> createState() => _TimeSlotState();
}

class _TimeSlotState extends State<TimeSlot> {
  String? fromTime;
  String? toTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Time Slot"),
          TextButton(
            onPressed: () async {
              TimeOfDay? selectedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );

              if (selectedTime != null) {
                setState(() {
                  fromTime = selectedTime.format(context);
                });
                widget.onTimesChanged(fromTime, toTime);
              }
            },
            child: Text(
              fromTime ?? 'From',
              style: TextStyle(
                color: Colors.teal.shade700,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              TimeOfDay? selectedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );

              if (selectedTime != null) {
                setState(() {
                  toTime = selectedTime.format(context);
                });
                widget.onTimesChanged(fromTime, toTime);
              }
            },
            child: Text(
              toTime ?? 'To',
              style: TextStyle(
                color: Colors.teal.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}