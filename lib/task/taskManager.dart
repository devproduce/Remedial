import 'package:first_flutter/core/utils/modal_class_task.dart';
import 'package:first_flutter/databsemanager/databaseTask.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskManager {
  // Function to parse a string time into a TimeOfDay object
  static TimeOfDay _parseTimeOfDay(String time) {
    try {
      final parsedTime = DateFormat.Hm().parse(time);
      return TimeOfDay(hour: parsedTime.hour, minute: parsedTime.minute);
    } catch (e) {
      print('Error parsing time: $e');
      return TimeOfDay.now(); // Fallback to current time
    }
  }

  // Function to convert a string duration to a Duration object
  static Duration _parseDuration(String time) {
    switch (time.toLowerCase()) {
      case '10 minutes':
        return const Duration(minutes: 10);
      case '30 minutes':
        return const Duration(minutes: 30);
      case '1 hour':
        return const Duration(hours: 1);
      case '2+ hours':
        return const Duration(hours: 2);
      default:
        
        return Duration.zero; // Default to zero duration
    }
  }

  // Function to get the current or next task
  static Future<Map<String, int>> getTheTask() async {
    DatabaseHelper database = DatabaseHelper();
    List<TaskModalClass> sortedTasks = await database.getSortedTask();
    DateTime now = DateTime.now();

    for (var task in sortedTasks) {
      TimeOfDay taskTime = _parseTimeOfDay(task.timeForTask);
      Duration taskDuration = _parseDuration(task.amountOfTime);

      DateTime taskStartTime = DateTime(now.year, now.month, now.day, taskTime.hour, taskTime.minute);
      DateTime taskEndTime = taskStartTime.add(taskDuration);

      if (now.isAfter(taskStartTime) && now.isBefore(taskEndTime)) {
        return {task.title: 0}; // Current task
      } else if (now.isBefore(taskStartTime)) {
        return {task.title: 1}; // Upcoming task
      }
    }

    return {'No task available': -1}; // No task found
  }
}
