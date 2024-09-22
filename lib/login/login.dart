import 'package:first_flutter/core/home_screen.dart';
import 'package:first_flutter/core/nav_bar.dart';
import 'package:first_flutter/databsemanager/databasePersonalDetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  final bool? update;
  LoginScreen(this.update);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ageEntries = ['below 10', '10-18', '18-25', '25+'];
  final professionEntries = ['Student', 'Working Professional'];
  String? age = '';
  String? selectedProfession = '';
  PersonalDetails? personalDetails;
  final DatabasePersonalDetails database = DatabasePersonalDetails();
  final TextEditingController nameController = TextEditingController();
  bool showError = false;
  bool showAgeError = false;
  bool showProfessionError = false;

  @override
  void initState() {
    super.initState();
    initializeDatabase();
  }

  void initializeDatabase() async {
    await database.initializeDatabase();
    personalDetails = await database.getPersonalDetails();
    if (widget.update == true && personalDetails != null) {
      setState(() {
        nameController.text = personalDetails!.name ?? '';
        age = personalDetails!.ageRange;
        selectedProfession = personalDetails!.profession;
      });
    }
  }

  bool isItStudent() {
    return personalDetails?.profession == 'Student';
  }

  @override
  Widget build(BuildContext context) {
    final backgroundImage = isItStudent()
        ? 'assets/image/student.jpg'
        : 'assets/image/working_professional.jpg';
    return Scaffold(
      backgroundColor: Colors.white70,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.update!
                ? CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    backgroundImage: AssetImage(backgroundImage),
                    minRadius: 50,
                    maxRadius: 50,
                    child: ClipOval(
                      child: Image.asset(
                        backgroundImage,
                        fit: BoxFit.cover, // Ensures the image covers the avatar and stays centered
                      ),
                    ),
                  )
                : Text(
                    'Remedial',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 35,
                      fontFamily: 'Times New Roman', // Use the custom font
                      shadows: [
                        Shadow(
                          offset: const Offset(2.0, 2.0),
                          blurRadius: 3.0,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                      ],
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: <Color>[Colors.grey, Colors.black],
                        ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: nameController,
                    showCursor: true,
                    maxLength: 20,
                    decoration: InputDecoration(
                      labelText: 'Enter your name',
                      labelStyle: const TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Colors.grey,
                      ),
                      counterText: '',
                      errorText: showError ? 'Enter The Name' : null,
                    ),
                    style: const TextStyle(
                      fontSize: 18.0,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      DropdownMenu<String>(
                        dropdownMenuEntries: ageEntries.map((slot) {
                          return DropdownMenuEntry<String>(
                            value: slot,
                            label: slot,
                          );
                        }).toList(),
                        hintText: 'Age',
                        initialSelection:
                            widget.update! ? personalDetails?.ageRange : null,
                        errorText: showAgeError ? 'Enter The Age' : null,
                        onSelected: (slot) {
                          age = slot;
                        },
                      ),
                      const SizedBox(width: 25),
                      DropdownMenu<String>(
                        dropdownMenuEntries: professionEntries.map((profession) {
                          return DropdownMenuEntry<String>(
                            value: profession,
                            label: profession,
                          );
                        }).toList(),
                        hintText: 'Profession',
                        initialSelection:
                            widget.update! ? personalDetails?.profession : null,
                        errorText: showProfessionError ? 'Enter The Details' : null,
                        width: 200,
                        onSelected: (profession) {
                          selectedProfession = profession;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      if ((nameController.text).isEmpty ||
                          (age?.isEmpty)! ||
                          (selectedProfession?.isEmpty)!) {
                        setState(() {
                          showError = (nameController.text).isEmpty;
                          showAgeError = (age?.isEmpty)!;
                          showProfessionError = (selectedProfession?.isEmpty)!;
                        });
                      } else {
                        try {
                          personalDetails = widget.update!
                              ? PersonalDetails.withId(
                                  personalDetails?.id,
                                  nameController.text,
                                  age,
                                  selectedProfession,
                                )
                              : PersonalDetails(
                                  nameController.text, age, selectedProfession, 1);
                          if (widget.update!) {
                            await database.updatePersonalDetails(personalDetails!);
                          } else {
                            await database.addPersonalDetails(personalDetails!);
                          }

                          await Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const navBar()),
                          );
                        } catch (error) {
                          print("Error: $error");
                          // Handle navigation error (e.g., show a snackbar)
                        }
                      }
                    },
                    child: Text(
                      widget.update! ? 'Edit' : 'Let\'s Go',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 67, 171, 255),
                      textStyle: const TextStyle(color: Colors.white),
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      elevation: 5,
                      minimumSize: Size(MediaQuery.of(context).size.width, 50),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
