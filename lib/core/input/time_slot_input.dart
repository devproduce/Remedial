import 'package:first_flutter/provider/timeslot_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TimeSlotInput extends StatefulWidget {
  final int dayIndex;

  const TimeSlotInput({super.key, required this.dayIndex});

  @override
  State<TimeSlotInput> createState() => _TimeSlotInputState();
}

class _TimeSlotInputState extends State<TimeSlotInput> {
  int? selectedFreeSlots;

  @override
  void initState() {
    super.initState();
    Provider.of<TimeSlotProvider>(context, listen: false)
      .loadTimeSlotsFromDatabase();
    
  
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TimeSlotProvider>(context, listen: false);
      if (!provider.timeSlotsPerDay.containsKey(widget.dayIndex)) {
        provider.initializeDaySlots(widget.dayIndex, []);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final timeSlotProvider = Provider.of<TimeSlotProvider>(context);
    final timeSlots = timeSlotProvider.timeSlotsPerDay[widget.dayIndex] ?? [];
    final maxFreeSlots = timeSlotProvider.getMaxFreeSlots(widget.dayIndex);

    return Dialog(
      elevation: 5,
      insetPadding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.25,
        horizontal: screenWidth * 0.1,
      ),
      alignment: Alignment.center,
      backgroundColor: Colors.lightBlue.shade100,
      child: Column(
        children: [
          SizedBox(height: screenHeight * 0.01),
          Text(
            "Time Slots",
            style: TextStyle(
              fontSize: screenWidth * 0.065,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Row(
            children: [
              SizedBox(width: screenWidth * 0.02),
              Text(
                "Max Free Slots:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.04,
                ),
              ),
              DropdownButton<int>(
                value: selectedFreeSlots,
                items: List.generate(10, (index) => index + 1).map((slot) {
                  return DropdownMenuItem<int>(
                    value: slot,
                    child: Text(slot.toString()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedFreeSlots = value;
                  });
                  timeSlotProvider.setMaxFreeSlots(widget.dayIndex, value!);
                },
              ),
            ],
          ),
          Expanded(
            flex: 2,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: timeSlots.length,
              itemBuilder: (context, index) {
                final slot = timeSlots[index];
                return TimeSlotWidget(
                  fromTime: slot.from,
                  toTime: slot.to,
                  onTimesChanged: (from, to) async {
                    if (_isCollidingWithOtherSlots(
                        List.from(timeSlots), from, to, index)) {
                      _showCollisionError(context);
                    } else {
                      await timeSlotProvider.updateTimeSlot(
                        widget.dayIndex,
                        index,
                        from,
                        to,
                      );
                    }
                  },
                  onRemove: () async{
                    await timeSlotProvider.removeTimeSlot(widget.dayIndex, index);
                  },
                );
              },

                    
              
            ),
          ),
          if (timeSlots.length < maxFreeSlots)
            ElevatedButton(
              onPressed: () {
                timeSlotProvider.addTimeSlot(
                  widget.dayIndex,
                  DateTime.now(),
                  DateTime.now().add(const Duration(hours: 1)),
                );
              },
              child: const Text('Add Slot'),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('SUBMIT'),
          ),
          SizedBox(height: screenHeight * 0.01),
        ],
      ),
    );
  }

  bool _isCollidingWithOtherSlots(
      List<AppTimeSlot> slots, DateTime from, DateTime to, int currentIndex) {
    for (int i = 0; i < slots.length; i++) {
      if (i == currentIndex) continue; // Skip the current slot
      final slot = slots[i];
      if (from.isBefore(slot.to) && to.isAfter(slot.from)) {
        // Collision detected
        return true;
      }
    }
    return false;
  }

  void _showCollisionError(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invalid Time Slot'),
        content: const Text(
            'The selected time slot is colliding with another slot. Please choose a different time.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class TimeSlotWidget extends StatelessWidget {
  final DateTime fromTime;
  final DateTime toTime;
  final void Function(DateTime from, DateTime to) onTimesChanged;
  final VoidCallback onRemove;

  const TimeSlotWidget({
    super.key,
    required this.fromTime,
    required this.toTime,
    required this.onTimesChanged,
    required this.onRemove,
  });

  Future<void> _selectTime(BuildContext context, bool isFromTime) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        isFromTime ? fromTime : toTime,
      ),
    );

    if (selectedTime != null) {
      final newDateTime = DateTime(
        fromTime.year,
        fromTime.month,
        fromTime.day,
        selectedTime.hour,
        selectedTime.minute,
      );
      if (isFromTime) {
        onTimesChanged(newDateTime, toTime);
      } else {
        onTimesChanged(fromTime, newDateTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: screenWidth * 0.025,
        horizontal: screenWidth * 0.025,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Time Slot",
            style: TextStyle(fontSize: screenWidth * 0.04),
          ),
          TextButton(
            onPressed: () => _selectTime(context, true),
            child: Text(
              TimeOfDay.fromDateTime(fromTime).format(context),
              style: TextStyle(
                color: Colors.teal.shade700,
                fontSize: screenWidth * 0.03,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _selectTime(context, false),
            child: Text(
              TimeOfDay.fromDateTime(toTime).format(context),
              style: TextStyle(
                color: Colors.teal.shade700,
                fontSize: screenWidth * 0.03,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }



  
}
