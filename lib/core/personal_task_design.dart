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
  DatabaseHelper database = DatabaseHelper();
  late Future<List<TaskModalClass>> tasklist = database.getTasks();

  void refreshTasks() {
    setState(() {
      tasklist = database.getTasks();
    });
  }

  void sortTask() {
    tasklist.then((tasks) {
      List<TaskModalClass> sortedTasks = List.from(tasks);
      sortedTasks.sort((b, a) => a.priority.compareTo(b.priority));
      setState(() {
        tasklist = Future.value(sortedTasks);
      });
    });
  }

  @override
  void initState() {
    
    sortTask();
    super.initState();


    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'TASKS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
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
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No Task Available'),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final task = snapshot.data![index];
                      var _title = task.title;
                      var _description = task.description;
                      var color = task.priority == 2
                          ? Colors.red.shade500
                          : Colors.red.shade100;

                      return Card(
                        elevation: 5,
                        color: color,
                        child: ListTile(
                          leading: IconButton(
                            onPressed: () async {
                              var updateTask = TaskInputDialog.forEdit(
                                edit: true,
                                title: task.title,
                                description: task.description,
                                urgency: task.priority,
                                id: task.id,
                                timeForTask: task.timeForTask,
                                amountOfTime: task.amountOfTime,
                                
                              );
                              bool? result = await showDialog(
                                context: context,
                                builder: (BuildContext context) => updateTask,
                              );
                              if (result == true) {
                                refreshTasks();
                                sortTask();
                              }
                            },
                            icon: const Icon(Icons.edit),
                          ),
                          title: Text(_title),
                          subtitle: Text(_description ?? ''),
                          trailing: IconButton(
                            onPressed: () {
                              database.deleteTask(task.id!);
                              refreshTasks();
                            },
                            icon: const Icon(Icons.delete),
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
