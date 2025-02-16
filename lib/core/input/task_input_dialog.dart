import 'package:first_flutter/core/utils/modal_class_task.dart';
import 'package:first_flutter/databsemanager/databaseTask.dart';
import 'package:first_flutter/notification/notification_manager.dart';
import 'package:first_flutter/provider/provider_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  TaskInputDialog.forEdit({super.key, 
    required this.edit,
    this.title,
    this.description,
    this.urgency,
    this.id,
    this.timeForTask,
    this.amountOfTime,
  }) : isTaskUpdated = true;

  @override
  State<TaskInputDialog> createState() => _TaskInputDialogState();
}

class _TaskInputDialogState extends State<TaskInputDialog> {
  bool _showError = false;
  late String _title;
  final String? _description = '';
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
  String? customTimeInput;

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
    final taskInputProvider = Provider.of<TaskInputProvider>(context);
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.1,
        horizontal: screenWidth * 0.1,
      ),
      elevation: 5,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      backgroundColor: Colors.lightBlue.shade100,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: mediaQuery.viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: screenHeight * 0.02),
                Text(
                  widget.edit ? 'EDIT TASK' : 'ADD TASK',
                  style: TextStyle(
                    fontSize: screenHeight * 0.03,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.05),
                            child: Text(
                              'Title: ',
                              style: TextStyle(
                                fontSize: screenHeight * 0.025,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: screenWidth * 0.01,
                                  right: screenWidth * 0.05),
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
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.015,
                                    horizontal: screenWidth * 0.02,
                                  ),
                                  errorText: _showError
                                      ? 'Please enter a title'
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    EdgeInsets.only(left: screenWidth * 0.05),
                                child: Text(
                                  'Urgency:  ',
                                  style: TextStyle(
                                    fontSize: screenHeight * 0.025,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Padding(
                                padding:
                                    EdgeInsets.only(left: screenWidth * 0.05),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.03,
                                  ),
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
                                    underline: const SizedBox(),
                                    items: _urgencyLevel.map((String urgency) {
                                      return DropdownMenuItem<String>(
                                        value: urgency,
                                        child: Text(urgency,
                                            style:
                                                const TextStyle(color: Colors.blue)),
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
                                  EdgeInsets.only(right: screenWidth * 0.05),
                              child: TextField(
                                maxLines: 6,
                                controller: _descriptionText,
                                autofocus: true,
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  hintText: 'Description\n(Optional)',
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.015,
                                    horizontal: screenWidth * 0.02,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: screenWidth * 0.05),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.03,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                border: Border.all(color: Colors.blue, width: 1),
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
                                          style: const TextStyle(color: Colors.blue)),
                                    );
                                  }).toList()
                                    ..add(
                                      DropdownMenuItem<String>(
                                        value: customTimeInput,
                                        child: Text((customTimeInput) ?? '',
                                            style:
                                                const TextStyle(color: Colors.blue)),
                                      ),
                                    )),
                            ),
                            SizedBox(width: screenWidth * 0.07),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.03,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.lightBlue.shade50,
                                border: Border.all(color: Colors.blue, width: 1),
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
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('CANCEL'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          _title = _titleText.text;
                          if (_title.isEmpty) {
                            setState(() {
                              _showError = true;
                            });
                            return;
                          }

                          String selectedTimeForTask =
                              customTimeInput ?? timeForTask;

                          bool isTimeAvailable =
                              await taskInputProvider.checkTimeAvailable(
                                  selectedTimeForTask);

                          if (isTimeAvailable) {
                            TaskModalClass task = TaskModalClass(
                              _title,
                              _descriptionText.text,
                              urgency!,
                              selectedTimeForTask,
                              amountOfTime,
                            );
                            if (widget.edit) {
                              taskInputProvider.updateTask(task);
                            } else {
                              taskInputProvider.addTask(task);
                            }
                            NotificationManager.scheduleNotification(task);
                            Navigator.pop(context);
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Time Conflict'),
                                  content: const Text(
                                      'There is already a task scheduled during this time.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        child: const Text('SAVE'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
