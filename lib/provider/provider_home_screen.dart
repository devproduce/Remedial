// lib/providers/task_provider.dart
import 'package:first_flutter/core/utils/modal_class_task.dart';
import 'package:first_flutter/databsemanager/databaseTask.dart';
import 'package:flutter/material.dart';
import '../task/taskManager.dart';
import '../databsemanager/databasePersonalDetails.dart';


class TaskProvider extends ChangeNotifier {
  String _taskStatus = 'Loading...';
  String _taskTitle = '';

  String get taskStatus => _taskStatus;
  String get taskTitle => _taskTitle;

  Future<void> fetchTaskStatus() async {
    var taskData = await TaskManager.getTheTask();
    _taskTitle = taskData.keys.first;
    _taskStatus = taskData.values.first == 0 ? 'Current Task' : 'Upcoming Task';
    notifyListeners();
  }
}



class UserProvider extends ChangeNotifier {
  PersonalDetails? _personalDetails;
  String? _name = 'Guest';

  String get name => _name ?? 'Guest';

  Future<void> fetchPersonalDetails() async {
    DatabasePersonalDetails database = DatabasePersonalDetails();
    try {
      _personalDetails = await database.getPersonalDetails();
      _name = _personalDetails?.name ?? 'Guest';
      notifyListeners();
    } catch (e) {
      _name = 'Guest';
      notifyListeners();
    }
  }
}







class TaskInputProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<TaskModalClass> _taskList = [];

  List<TaskModalClass> get taskList => _taskList;

  Future<void> fetchTasks() async {
    _taskList = await _databaseHelper.getSortedTask();
    notifyListeners();
  }

  Future<void> addTask(TaskModalClass task) async {
    await _databaseHelper.insertTask(task);
    await fetchTasks();
  }

  Future<void> updateTask(TaskModalClass task) async {
    await _databaseHelper.updateTask(task);
    await fetchTasks();
  }

  Future<void> deleteTask(int id) async {
    await _databaseHelper.deleteTask(id);
    await fetchTasks();
  }

  Future<bool> checkTimeAvailable(String timeForTaskToAdd) async {
    List<TaskModalClass> taskList = await _databaseHelper.getSortedTask();
    //DateTime now = DateTime.now();
    DateTime taskToAddTime = convertTo24HourFormat(timeForTaskToAdd);

    for (TaskModalClass task in taskList) {
      DateTime taskStartTime = convertTo24HourFormat(task.timeForTask);
      DateTime taskEndTime =
          taskStartTime.add(_amountOfTimeForTask(task.amountOfTime));

      if (taskToAddTime.isAfter(taskStartTime) && taskToAddTime.isBefore(taskEndTime)) {
        return false; 
      }
    }
    return true; // No task conflicts, time slot available.
  }

  DateTime convertTo24HourFormat(String time) {
    final format = time.split(" ");
    final timeParts = format[0].split(":");
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    String period = format[1].toUpperCase();

    if (period == "PM" && hour != 12) {
      hour += 12;
    } else if (period == "AM" && hour == 12) {
      hour = 0;
    }

    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  static Duration _amountOfTimeForTask(String time) {
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
        return const Duration(); // Default to zero duration
    }
  }
}

