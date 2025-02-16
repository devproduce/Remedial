// lib/screens/home_screen.dart
import 'package:first_flutter/provider/provider_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/input/task_input_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  @override
  void initState() {
    super.initState();
    // Fetch personal details and task status when screen loads
    Future.wait([
      Provider.of<UserProvider>(context, listen: false).fetchPersonalDetails(),
      Provider.of<TaskProvider>(context, listen: false).fetchTaskStatus(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: getTime(),
                        style: TextStyle(
                          fontSize: screenWidth * 0.1,
                          fontWeight: FontWeight.w500,
                          color: Colors.indigoAccent,
                        ),
                      ),
                      const TextSpan(
                        text: " ",
                        style: TextStyle(letterSpacing: -5.0),
                      ),
                      TextSpan(
                        text: userProvider.name,
                        style: TextStyle(
                          fontSize: screenWidth * 0.15,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: screenHeight * 0.01),
            Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      taskProvider.taskStatus,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.05,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    taskProvider.taskTitle.isNotEmpty
                        ? SizedBox(
                            height: screenHeight * 0.04,
                            child: Text(
                              taskProvider.taskTitle,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: screenWidth * 0.04,
                              ),
                            ),
                          )
                        : Text(
                            'No task available',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.04,
                            ),
                          ),
                  ],
                );
              },
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => TaskInputDialog(),
                  ).then((_) {
                    // After task input, refresh the task status
                    Provider.of<TaskProvider>(context, listen: false).fetchTaskStatus();
                  });
                },
                icon: Icon(
                  Icons.add_task_rounded,
                  size: screenWidth * 0.2,
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
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
