class TaskModalClass {
  int? _id;
  String _title;
  String? _description;
  int _priority;
  String _timeForTask;
  String _amountOfTime;

  TaskModalClass(this._title, this._description, this._priority,
      this._timeForTask, this._amountOfTime);

  TaskModalClass.withId(this._id, this._title, this._description,
      this._priority, this._timeForTask, this._amountOfTime);

  int? get id => _id;
  String get title => _title;
  String? get description => _description;
  int get priority => _priority;
  String get timeForTask => _timeForTask;
  String get amountOfTime => _amountOfTime;

  Map<String, dynamic> taskToMap() {
    Map<String, dynamic> taskMap = {};

    taskMap['id'] = _id;

    taskMap['title'] = _title;
    taskMap['description'] = _description;
    taskMap['priority'] = _priority;
    taskMap['timeForTask'] = _timeForTask;
    taskMap['amountOfTime'] = _amountOfTime;

    return taskMap;
  }

  static TaskModalClass mapToTask(Map<String, dynamic> map) {
    return TaskModalClass.withId(
      map['id'],
      map['title'],
      map['description'],
      map['priority'],
      map['timeForTask'],
      map['amountOfTime']
    );
  }
}
