import 'package:first_flutter/core/input/task_input_dialog.dart';
import 'package:first_flutter/databsemanager/databasePersonalDetails.dart';
import 'package:first_flutter/task/taskManager.dart';
//import 'package:first_flutter/databsemanager/task_manager.dart'; // Import TaskManager class
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:marquee/marquee.dart'; // Add marquee for scrolling text

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String greet = 'GOOD MORNING';
  String? name;
  String taskStatus = 'Loading...'; // For current or upcoming task
  String taskTitle = ''; // Task title to display

  String getTime() {
    final now = DateTime.now();
    if (now.hour > 12 && now.hour < 18) {
      return 'GOOD AFTERNOON\n';
    } else if (now.hour < 12) {
      return 'GOOD MORNING\n';
    } else {
      return 'GOOD EVENING\n';
    }
  }

  DatabasePersonalDetails database = DatabasePersonalDetails();
  PersonalDetails? personalDetails;

  void refreshPersonalDetails() async {
    PersonalDetails details = (await database.getPersonalDetails())!;
    setState(() {
      personalDetails = details;
    });
  }

  Future<void> getPersonalDetails() async {
    try {
      personalDetails = await database.getPersonalDetails();
      if (personalDetails?.name == null) {
        setState(() {
          name = 'Guest';
        });
      } else {
        setState(() {
          name = personalDetails?.name;
        });
      }
    } catch (e) {
      setState(() {
        name = 'Guest';
      });
    }
  }

  Future<void> getTaskStatus() async {
    var taskData = await TaskManager.getTheTask();
    setState(() {
      taskTitle = taskData.keys.first;
      taskStatus =
          taskData.values.first == 0 ? 'Current Task' : 'Upcoming Task';
    });
    print("$taskStatus");
  }

  @override
  void initState() {
    super.initState();

    Future.wait([
      getPersonalDetails(),
      getTaskStatus(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFE0E0E0),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: getTime(),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w500,
                      color: Colors.indigoAccent,
                    ),
                  ),
                  const TextSpan(
                    text: " ",
                    style: TextStyle(letterSpacing: -5.0),
                  ),
                  TextSpan(
                    text: name,
                    style: const TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text(
                  taskStatus,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
                SizedBox(height: 10),
                taskTitle.isNotEmpty
                    ? SizedBox(
                        height: 30,
                        child: Text(
                          taskTitle, // Rolling task title
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      )
                    : const Text(
                        'No task available',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
              ],
            ),
            const SizedBox(height: 200),
            Container(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => TaskInputDialog(),
                  ).then((_) {
                    getTaskStatus();
                  });
                },
                icon: const Icon(
                  Icons.add_task_rounded,
                  size: 80.0,
                  color: Colors.redAccent,
                ),
                label: const Text(''),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 0),
                  padding: EdgeInsets.zero,
                  backgroundColor: const Color(0xFFE0E0E0),
                  elevation: 5.0,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: const CircleBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
