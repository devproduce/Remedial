import 'package:first_flutter/core/utils/modal_class_task.dart';
import 'package:first_flutter/databsemanager/databaseTask.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskManager {
  // Function to parse a string time into a TimeOfDay object
  static TimeOfDay _parseTimeOfDay(String time) {
    try {
      final DateTime parsedTime = DateFormat.Hm().parse(time); // Expecting "HH:mm" format
      return TimeOfDay(hour: parsedTime.hour, minute: parsedTime.minute);
    } catch (e) {
      // Handle unexpected time format
      print('Error parsing time: $e');
      return TimeOfDay.now(); // Default fallback
    }
  }

  // Function to convert time duration strings to Duration objects
  static Duration _amountOfTime(String time) {
    switch (time.toLowerCase()) {
      case '10 minutes':
        return const Duration(minutes: 10);
      case '30 minutes':
        return const Duration(minutes: 30);
      case '1 hour':
        return const Duration(hours: 1);
      case '2+ hour':
        return const Duration(hours: 2);
      default:
        print('Unknown time duration: $time');
        return const Duration(); // Default to zero duration
    }
  }

  // Function to get the current or next task
  static Future<Map<String, int>> getTheTask() async {
    DatabaseHelper database = DatabaseHelper();

    // Fetch and sort tasks by time
    List<TaskModalClass> sortedTasks = await database.getSortedTask();
    TimeOfDay now = TimeOfDay.now();

    // Iterate through sorted tasks
    for (int i = 0; i < sortedTasks.length; i++) {
      TimeOfDay taskTime = _parseTimeOfDay(sortedTasks[i].timeForTask);
      Duration taskDuration = _amountOfTime(sortedTasks[i].amountOfTime);

      // Combine date with task and current times for comparison
      DateTime nowDateTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        now.hour,
        now.minute,
      );

      DateTime taskStartTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        taskTime.hour,
        taskTime.minute,
      );

      DateTime taskEndTime = taskStartTime.add(taskDuration);

      // Check if the current time is within the task's duration
      if (nowDateTime.isAfter(taskStartTime) && nowDateTime.isBefore(taskEndTime)) {
        return {sortedTasks[i].title: 0}; // Current Task
      } else if (nowDateTime.isBefore(taskStartTime)) {
        return {sortedTasks[i].title: 1}; // Upcoming Task
      }
    }

    return {'No task available': -1}; // No Task
  }
}
