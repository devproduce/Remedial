import 'package:flutter/cupertino.dart';
import 'package:first_flutter/databsemanager/database_timeslot.dart';

class AppTimeSlot {
  final DateTime from;
  final DateTime to;

  AppTimeSlot({required this.from, required this.to});
}

class TimeSlotProvider with ChangeNotifier {
  final Map<int, List<AppTimeSlot>> _timeSlotsPerDay = {};
  final Map<int, int> _maxFreeSlotsPerDay = {}; 
  final TimeSlotDatabaseHelper _databaseHelper = TimeSlotDatabaseHelper();

  Map<int, List<AppTimeSlot>> get timeSlotsPerDay => _timeSlotsPerDay;

  int getMaxFreeSlots(int dayIndex) => _maxFreeSlotsPerDay[dayIndex] ?? 0;

  bool isColliding (DateTime from, DateTime to, List<AppTimeSlot> slots) {
    for (final slot in slots) {
      if ((from.isAfter(slot.from) && from.isBefore(slot.to)) ||
          (to.isAfter(slot.from) && to.isBefore(slot.to)) ||
          (from.isBefore(slot.from) && to.isAfter(slot.to))) {
        return true;
      }
    }
    return false;
  }


  Future<void> loadTimeSlotsFromDatabase() async {
    final timeSlots = await _databaseHelper.getTimeSlots();
    _timeSlotsPerDay.clear();
    for (var slot in timeSlots) {
      if (!_timeSlotsPerDay.containsKey(slot.dayIndex)) {
        _timeSlotsPerDay[slot.dayIndex] = [];
      }
      _timeSlotsPerDay[slot.dayIndex]!.add(AppTimeSlot(
        from: slot.fromTime,
        to: slot.toTime,
      ));
    }
    notifyListeners();
  }


  Future<void> initializeDaySlots(int dayIndex, List<AppTimeSlot> initialSlots) async {
    if (!_timeSlotsPerDay.containsKey(dayIndex)) {
      _timeSlotsPerDay[dayIndex] = initialSlots;

      for (final slot in initialSlots) {
        final newSlot = TimeSlot(dayIndex: dayIndex, fromTime: slot.from, toTime: slot.to);
        await _databaseHelper.insertTimeSlot(newSlot);
      }
      notifyListeners();
    }
  }


  Future<void> setMaxFreeSlots(int dayIndex, int maxSlots) async {
    _maxFreeSlotsPerDay[dayIndex] = maxSlots;

    if (!_timeSlotsPerDay.containsKey(dayIndex)) {
      _timeSlotsPerDay[dayIndex] = [];
    }

    final currentSlots = _timeSlotsPerDay[dayIndex]!;
    if (currentSlots.length > maxSlots) {
      for (int i = maxSlots; i < currentSlots.length; i++) {
        final slot = currentSlots[i];
        await _databaseHelper.deleteTimeSlot(
           dayIndex,
          slot.from,
          
        );
      }
      _timeSlotsPerDay[dayIndex] = currentSlots.sublist(0, maxSlots);
    } else if (currentSlots.length < maxSlots) {
      for (int i = currentSlots.length; i < maxSlots; i++) {
        final newSlot = AppTimeSlot(
          from: DateTime.now(),
          to: DateTime.now().add(const Duration(hours: 1)),
        );
        _timeSlotsPerDay[dayIndex]!.add(newSlot);
        final dbSlot = TimeSlot(dayIndex: dayIndex, fromTime: newSlot.from, toTime: newSlot.to);
        await _databaseHelper.insertTimeSlot(dbSlot);
      }
    }

    notifyListeners();
  }

  
  Future<void> addTimeSlot(int dayIndex, DateTime from, DateTime to) async {
    if (!_timeSlotsPerDay.containsKey(dayIndex)) {
      _timeSlotsPerDay[dayIndex] = [];
    }
    

    if (_timeSlotsPerDay[dayIndex]!.length < (_maxFreeSlotsPerDay[dayIndex] ?? 0)) {
      final newSlot = AppTimeSlot(from: from, to: to);
      _timeSlotsPerDay[dayIndex]!.add(newSlot);
      final dbSlot = TimeSlot(dayIndex: dayIndex, fromTime: from, toTime: to);
      await _databaseHelper.insertTimeSlot(dbSlot);
      notifyListeners();
    }
  }

  
  Future<void> updateTimeSlot(int dayIndex, int slotIndex, DateTime from, DateTime to) async {
  if (_timeSlotsPerDay.containsKey(dayIndex) &&
      slotIndex < _timeSlotsPerDay[dayIndex]!.length) {
    final oldSlot = _timeSlotsPerDay[dayIndex]![slotIndex];
    final updatedSlot = AppTimeSlot(from: from, to: to);
    _timeSlotsPerDay[dayIndex]![slotIndex] = updatedSlot;

    // Update in database
    await _databaseHelper.updateTimeSlot(
      
      
      
       // Use old from time to find the correct record
      TimeSlot(dayIndex: dayIndex, fromTime: from, toTime: to),
      dayIndex,
      oldSlot.from,
    );

    notifyListeners();
  }
}
  
  Future<void> removeTimeSlot(int dayIndex, int slotIndex) async {
    if (_timeSlotsPerDay.containsKey(dayIndex) &&
        slotIndex < _timeSlotsPerDay[dayIndex]!.length) {
      final slotToRemove = _timeSlotsPerDay[dayIndex]![slotIndex];
      _timeSlotsPerDay[dayIndex]!.removeAt(slotIndex);
      await _databaseHelper.deleteTimeSlot(
        dayIndex,
        slotToRemove.from,
        
      );
      notifyListeners();
    }
  }
}
