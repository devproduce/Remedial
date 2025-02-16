//import 'dart:js_interop_unsafe';

import 'package:first_flutter/core/personal_task_design.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PersonalTask extends StatefulWidget {
  const PersonalTask({super.key});

  @override
  State<PersonalTask> createState() => _PersonalTaskState();
}

class _PersonalTaskState extends State<PersonalTask> {
  var arrPersonalTask = [
    const Text("Reading the Book: The power of now"),
    const Text("Completing the flutter tutorial"),
    const Text("Workout"),
    const Text("Music production: Am i wrong (remix)"),
    const Text("reading again the book"),
  ];
  @override
  Widget build(BuildContext context) {
    return const PersonalTaskDesign();
  }
}
