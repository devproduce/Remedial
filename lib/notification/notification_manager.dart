import 'package:awesome_notifications/awesome_notifications.dart';


import 'package:first_flutter/core/utils/modal_class_task.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationController {

  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
        
      }

  
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {}

  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {}

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {}
}




class NotificationManager {


  static TimeOfDay _parseTimeOfDay(String time) {
  final DateTime parsedTime = DateFormat.Hm().parse(time);
  return TimeOfDay(hour: parsedTime.hour, minute: parsedTime.minute);
  }
  
  static void scheduleNotification(TaskModalClass task) async {
    TimeOfDay timeForTask = _parseTimeOfDay(task.timeForTask);
    DateTime now = DateTime.now();



    DateTime scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      timeForTask.hour,
      timeForTask.minute,
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _createUniqueId(),
        channelKey: 'Task_Reminder_channel',
        title: 'Reminder: ${task.title}',
        body: 'This is your task reminder for ${task.title}',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar.fromDate(date: scheduledTime,
      allowWhileIdle: true,  // Ensure notifications show even if the device is idle
      preciseAlarm: true,), 
    );
  }

  // Private static method to generate a unique ID
  static int _createUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }
}

