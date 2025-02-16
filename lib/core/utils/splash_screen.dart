import 'package:first_flutter/core/home_screen.dart';
import 'package:first_flutter/core/nav_bar.dart';
import 'package:first_flutter/databsemanager/databasePersonalDetails.dart';
import 'package:first_flutter/login/login.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  DatabasePersonalDetails database = DatabasePersonalDetails();
  bool isUserLoggedIn = false;
  PersonalDetails? personalDetails;

Future<void> getPersonalDetails() async {
    personalDetails = await database.getPersonalDetails();
    if (personalDetails == null) {
       

      print('No personal details found.');
      isUserLoggedIn = false;
    } else {

      print('Personal details fetched: ${personalDetails?.isUserLoggedIn}');
      isUserLoggedIn = true;
      
    }
  }

  @override
  void initState() {
    super.initState();
    initializeApp();
  }

  Future<void> initializeApp() async {
    await database.initializeDatabase();
    await getPersonalDetails();

    Timer(const Duration(seconds: 1), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => isUserLoggedIn ? const navBar() : LoginScreen(false)));
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900], // Dark blue background
      body:const Center(
        child: Text(
          'Remedial',
          style: TextStyle(
            fontSize: 48.0,
            color: Colors.white, // Contrasting white text
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
