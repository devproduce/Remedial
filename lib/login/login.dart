import 'package:first_flutter/core/home_screen.dart';
import 'package:first_flutter/core/nav_bar.dart';
import 'package:first_flutter/databsemanager/databasePersonalDetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  final bool? update;
  const LoginScreen(this.update, {super.key});

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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final backgroundImage = isItStudent()
        ? 'assets/image/student.jpg'
        : 'assets/image/working_professional.jpg';

    return Scaffold(
      backgroundColor: Colors.white70,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.update!
                  ? CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      backgroundImage: AssetImage(backgroundImage),
                      radius: screenWidth * 0.15, // Dynamic size
                      child: ClipOval(
                        child: Image.asset(
                          backgroundImage,
                          fit: BoxFit.cover,
                          width: screenWidth * 0.3,
                          height: screenWidth * 0.3,
                        ),
                      ),
                    )
                  : Text(
                      'Remedial',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.08, // Dynamic font size
                        fontFamily: 'Times New Roman',
                        shadows: [
                          Shadow(
                            offset: Offset(screenWidth * 0.005, screenHeight * 0.005),
                            blurRadius: screenWidth * 0.02,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                        ],
                        foreground: Paint()
                          ..shader = const LinearGradient(
                            colors: <Color>[Colors.grey, Colors.black],
                          ).createShader(
                            Rect.fromLTWH(
                              0.0,
                              0.0,
                              screenWidth * 0.8,
                              screenHeight * 0.1,
                            ),
                          ),
                      ),
                    ),
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: nameController,
                      showCursor: true,
                      maxLength: 20,
                      decoration: InputDecoration(
                        labelText: 'Enter your name',
                        labelStyle: TextStyle(
                          fontSize: screenWidth * 0.045, // Dynamic font size
                          color: Colors.black,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(screenWidth * 0.02),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: screenWidth * 0.005,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: screenWidth * 0.005,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.grey,
                          size: screenWidth * 0.06, // Dynamic size
                        ),
                        counterText: '',
                        errorText: showError ? 'Enter The Name' : null,
                      ),
                      style: TextStyle(
                        fontSize: screenWidth * 0.045, // Dynamic font size
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: screenWidth * 0.4,
                          child: DropdownMenu<String>(
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
                        ),
                        SizedBox(
                          width: screenWidth * 0.4,
                          child: DropdownMenu<String>(
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
                            onSelected: (profession) {
                              selectedProfession = profession;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
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
                              MaterialPageRoute(
                                  builder: (context) => const navBar()),
                            );
                          } catch (error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Error: $error"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 67, 171, 255),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.1,
                          vertical: screenHeight * 0.015,
                        ),
                        elevation: 5,
                        minimumSize:
                            Size(screenWidth * 0.8, screenHeight * 0.06),
                      ),
                      child: Text(
                        widget.update! ? 'Edit' : 'Let\'s Go',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.05, // Dynamic font size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.1),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
