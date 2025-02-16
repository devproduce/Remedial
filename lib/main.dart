import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:first_flutter/core/utils/splash_screen.dart';
import 'package:first_flutter/notification/notification_manager.dart';
import 'package:first_flutter/provider/provider_home_screen.dart';
import 'package:first_flutter/provider/timeslot_provider.dart';
//import 'package:first_flutter/login/login.dart';
//import 'package:first_flutter/notification/notification_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//import 'core/nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final provider = TimeSlotProvider();
  
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelGroupKey: "Task_Reminder_channel_group",
        channelKey: "Task_Reminder_channel",
        channelName: "Task_Reminder Notification",
        channelDescription: "Task_Reminder notifications channel",
      )
    ],
    channelGroups: [
      NotificationChannelGroup(
        channelGroupKey: "Task_Reminder_channel_group",
        channelGroupName: "Task_Reminder Group",
      )
    ],
  );

  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
  if (!isAllowed) {
  
    AwesomeNotifications().requestPermissionToSendNotifications();
  }
});

  runApp(
    MultiProvider(
    
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => TimeSlotProvider()),
        ChangeNotifierProvider(create: (_) => TaskInputProvider()),

        
      ],
      child: const MyApp(),
    ),
  );
}



class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:
            NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:
            NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:
            NotificationController.onDismissActionReceivedMethod);
    super.initState();
  }


 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFE0E0E0),
        ),
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          body: SplashScreen(),
        ));
  }
}
