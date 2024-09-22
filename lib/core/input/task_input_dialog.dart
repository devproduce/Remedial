import 'package:first_flutter/core/utils/modal_class_task.dart';
import 'package:first_flutter/databsemanager/databaseTask.dart';
import 'package:first_flutter/notification/notification_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class TaskInputDialog extends StatefulWidget {
  bool edit;
  String? title;
  String? description;
  int? urgency;
  bool isTaskUpdated;
  int? id;
  String? timeForTask;
  String? amountOfTime;

  TaskInputDialog({super.key})
      : edit = false,
        title = '',
        description = '',
        urgency = 1,
        isTaskUpdated = false,
        id = null;

  TaskInputDialog.forEdit(
      {required this.edit,
      this.title,
      this.description,
      this.urgency,
      this.id,
      this.timeForTask,
      this.amountOfTime})
      : isTaskUpdated = true;

  @override
  State<TaskInputDialog> createState() => _TaskInputDialogState();
}

class _TaskInputDialogState extends State<TaskInputDialog> {
  bool _showError = false;
  late String _title;
  String? _description = '';
  final List<String> _urgencyLevel = ['Normal', 'Urgent'];
  final List<String> _timeForTask = ['Free Slots', 'Custom..'];
  String timeForTask = 'Free Slots';
  final List<String> _amountOfTime = [
    '10 minutes',
    '30 minutes',
    "1 Hour",
    '2+ Hour'
  ];
  String amountOfTime = '30 minutes';
  int? urgency;
  late TextEditingController _titleText;
  late TextEditingController _descriptionText;
  final DatabaseHelper database = DatabaseHelper();
  String? customTimeInput;

  void scheduleNotification(TaskModalClass task) {}

  @override
  void initState() {
    super.initState();
    _titleText = TextEditingController(text: widget.title);
    _descriptionText = TextEditingController(text: widget.description);
    urgency = widget.urgency;
    if (widget.edit &&
        widget.timeForTask != null &&
        widget.timeForTask != 'Free Slots') {
      customTimeInput = widget.timeForTask;
      timeForTask = 'Custom..';
    } else {
      timeForTask =
          widget.edit ? (widget.timeForTask ?? 'Free Slots') : 'Free Slots';
    }
    amountOfTime =
        widget.edit ? (widget.amountOfTime ?? '30 minutes') : '30 minutes';
  }

  @override
  void dispose() {
    _titleText.dispose();
    _descriptionText.dispose();
    super.dispose();
  }

  int urgencyLevel(String urgency) {
    return urgency == 'Normal' ? 1 : 2;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(vertical: 100, horizontal: 40),
      elevation: 5,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      backgroundColor: Colors.lightBlue.shade100,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 7),
                Text(
                  widget.edit ? 'EDIT TASK' : 'ADD TASK',
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 25),
                            child: Text(
                              'Title: ',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 5, right: 25),
                              child: TextField(
                                maxLength: 80,
                                controller: _titleText,
                                autofocus: true,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color:
                                          _showError ? Colors.red : Colors.grey,
                                    ),
                                  ),
                                  hintText: 'Title...',
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 3),
                                  errorText: _showError
                                      ? 'Please enter a title'
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 25),
                                child: Text(
                                  'Discription:  ',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.only(left: 25),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0),
                                  decoration: BoxDecoration(
                                    color: Colors.lightBlue.shade50,
                                    border: Border.all(
                                        color: Colors.blue, width: 1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButton<String>(
                                    value: _urgencyLevel[urgency! - 1],
                                    icon: const Icon(Icons.arrow_drop_down,
                                        color: Colors.blue),
                                    underline: SizedBox(),
                                    items: _urgencyLevel.map((String urgency) {
                                      return DropdownMenuItem<String>(
                                        value: urgency,
                                        child: Text(urgency,
                                            style:
                                                TextStyle(color: Colors.blue)),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        urgency = urgencyLevel(value!);
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 0, right: 25),
                              child: TextField(
                                maxLines: 6,
                                controller: _descriptionText,
                                autofocus: true,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Description\n(Optional)',
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 0, horizontal: 3)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 25, top: 15),
                        child: Row(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                border:
                                    Border.all(color: Colors.blue, width: 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<String>(
                                  value: customTimeInput ?? timeForTask,
                                  icon: const Icon(Icons.arrow_drop_down,
                                      color: Colors.blue),
                                  underline: const SizedBox(),
                                  onChanged: (selectedItem) async {
                                    if (selectedItem == 'Custom..') {
                                      TimeOfDay? pickedTime =
                                          await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      );
                                      if (pickedTime != null) {
                                        setState(() {
                                          customTimeInput = pickedTime
                                              .format(context)
                                              .toString();
                                          //selectedItem = customTimeInput;
                                          timeForTask = customTimeInput!;
                                        });
                                      }
                                    } else {
                                      setState(() {
                                        customTimeInput = null;
                                        timeForTask = selectedItem!;
                                      });
                                    }
                                  },
                                  items: _timeForTask.map((String timeForTask) {
                                    return DropdownMenuItem<String>(
                                      value: timeForTask,
                                      child: Text(timeForTask,
                                          style: TextStyle(color: Colors.blue)),
                                    );
                                  }).toList()
                                    ..add(
                                      DropdownMenuItem<String>(
                                        value: customTimeInput,
                                        child: Text((customTimeInput) ?? '',
                                            style:
                                                TextStyle(color: Colors.blue)),
                                      ),
                                    )),
                            ),
                            const SizedBox(width: 28),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              decoration: BoxDecoration(
                                color: Colors.lightBlue.shade50,
                                border:
                                    Border.all(color: Colors.blue, width: 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<String>(
                                value: amountOfTime,
                                icon: const Icon(Icons.arrow_drop_down,
                                    color: Colors.blue),
                                underline: const SizedBox(),
                                items: _amountOfTime.map((String amountOfTime) {
                                  return DropdownMenuItem<String>(
                                    value: amountOfTime,
                                    child: Text(amountOfTime,
                                        style: const TextStyle(
                                            color: Colors.blue)),
                                  );
                                }).toList(),
                                onChanged: (selectedItem) {
                                  setState(() {
                                    amountOfTime = selectedItem!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              try {
                                _title = _titleText.text;
                                if (_title.isEmpty) {
                                  throw Exception('Title Cannot be Empty');
                                }

                                _description = _descriptionText.text;
                                final taskTime = customTimeInput ?? timeForTask;

                                final task = TaskModalClass.withId(
                                    widget.id,
                                    _title,
                                    _description,
                                    urgency!,
                                    taskTime,
                                    amountOfTime);
                                if (widget.edit) {
                                  await database.updateTask(task);
                                } else {
                                  await database.insertTask(task);
                                  NotificationManager.scheduleNotification(
                                      task);
                                }

                                Navigator.of(context).pop(true);
                              } catch (e) {
                                setState(() {
                                  _showError = true;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter a title'),
                                  ),
                                );
                              }
                            },
                            child: Text(widget.edit ? 'EDIT' : 'ADD'),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
