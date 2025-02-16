import 'package:first_flutter/core/input/task_input_dialog.dart';
import 'package:first_flutter/core/utils/modal_class_task.dart';
import 'package:first_flutter/databsemanager/databaseTask.dart';
import 'package:flutter/material.dart';

class PersonalTaskDesign extends StatefulWidget {
  const PersonalTaskDesign({super.key});

  @override
  State<PersonalTaskDesign> createState() => _PersonalTaskDesignState();
}

class _PersonalTaskDesignState extends State<PersonalTaskDesign> {
  final DatabaseHelper database = DatabaseHelper();
  late Future<List<TaskModalClass>> tasklist = database.getTasks();

  void refreshTasks() {
    setState(() {
      tasklist = database.getTasks();
      sortTask();
    });
  }

  void sortTask() {
    tasklist.then((tasks) {
      tasks.sort((b, a) => a.priority.compareTo(b.priority));
      setState(() {
        tasklist = Future.value(tasks);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    refreshTasks();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
            child: Center(
              child: Text(
                'TASKS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.06, // Dynamically calculated font size
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<TaskModalClass>>(
              future: tasklist,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045, // Dynamic font size
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No Task Available',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045, // Dynamic font size
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final task = snapshot.data![index];
                      final color = task.priority == 2
                          ? Colors.red.shade500
                          : Colors.red.shade100;

                      return Card(
                        elevation: 5,
                        color: color,
                        margin: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.03, // Dynamic horizontal margin
                          vertical: screenHeight * 0.01, // Dynamic vertical margin
                        ),
                        child: ListTile(
                          leading: IconButton(
                            onPressed: () async {
                              final updateTask = TaskInputDialog.forEdit(
                                edit: true,
                                title: task.title,
                                description: task.description,
                                urgency: task.priority,
                                id: task.id,
                                timeForTask: task.timeForTask,
                                amountOfTime: task.amountOfTime,
                              );
                              final bool? result = await showDialog(
                                context: context,
                                builder: (BuildContext context) => updateTask,
                              );
                              if (result == true) {
                                refreshTasks();
                              }
                            },
                            icon: Icon(
                              Icons.edit,
                              size: screenWidth * 0.06, // Dynamic icon size
                            ),
                            tooltip: 'Edit Task',
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              fontSize: screenWidth * 0.05, // Dynamic font size
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: task.description != null
                              ? Text(
                                  task.description!,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.04, // Dynamic font size
                                  ),
                                )
                              : null,
                          trailing: IconButton(
                            onPressed: () async {
                              await database.deleteTask(task.id!);
                              refreshTasks();
                            },
                            icon: Icon(
                              Icons.delete,
                              size: screenWidth * 0.06, // Dynamic icon size
                            ),
                            tooltip: 'Delete Task',
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
