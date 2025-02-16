import 'package:first_flutter/core/nav_bar.dart';
import 'package:first_flutter/core/schedule.dart';
import 'package:first_flutter/core/user_profile.dart';
import 'package:first_flutter/core/utils/modal_class.dart';
import 'package:first_flutter/databsemanager/databasePersonalDetails.dart';
import 'package:first_flutter/databsemanager/databaseTask.dart';
import 'package:first_flutter/login/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui';

import 'package:sqflite/sqflite.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  DatabasePersonalDetails database = DatabasePersonalDetails();
  PersonalDetails? personalDetails;
  DatabaseHelper databaseTask = DatabaseHelper();
  DatabaseService databaseTimeSlot = DatabaseService();

  String name = "";
  String profession = '';

  void refreshPersonalDetails() async {
    PersonalDetails details = (await database.getPersonalDetails())!;
    setState(() {
      personalDetails = details;
    });
  }

  bool isItStudent() {
    if (profession == 'Student') {
      return true;
    } else {
      return false;
    }
  }

  Future<void> getPersonalDetails() async {
    try {
      personalDetails = await database.getPersonalDetails();
      print('Personal details retrieved: ${personalDetails?.name}');

      if (personalDetails?.name == null) {
        setState(() {
          name = 'Guest';
        });
      } else {
        setState(() {
          name = (personalDetails?.name)!;
          profession = (personalDetails?.profession)!;
        });
      }
    } catch (e) {
      print('Error retrieving personal details: $e');
      setState(() {
        name = 'Guest'; // Fallback value in case of error
      });
    }
  }

  @override
  void initState() {
    super.initState();
    refreshPersonalDetails();
    getPersonalDetails();
    isItStudent();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundImage = isItStudent()
        ? 'assets/image/student.jpg'
        : 'assets/image/working_professional.jpg';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Stack(
            children: [
              Container(
                height: 200, // Height of the UserAccountsDrawerHeader
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(backgroundImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  height: 200,
                  color: Colors.black.withOpacity(0.3), // Optional: add a tint
                ),
              ),
              UserAccountsDrawerHeader(
                accountName: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                accountEmail: Text(
                  profession,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                currentAccountPicture: GestureDetector(
                  child: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    backgroundImage: AssetImage(backgroundImage),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LoginScreen(true)));
                  },
                ),
                decoration: const BoxDecoration(
                  color: Colors
                      .transparent, // Transparent to show the blurred image
                ),
              ),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today, color: Colors.blueAccent),
            title: const Text(
              "Schedule",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const MySchedule()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              "Logout",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            onTap: () async {

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen(false)),
                (Route<dynamic> route) => false,
              );
              await database.deleteAllPersonalDetails();
              await databaseTask.deleteAllTasks();
              await databaseTimeSlot.deleteAllTimeSlots();

              
            },
          ),
          const ListTile(
            leading: Icon(Icons.settings, color: Colors.grey),
            title: Text(
              "Settings",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            contentPadding: EdgeInsets.only(left: 16, top: 450),
          ),
        ],
      ),
    );
  }
}
