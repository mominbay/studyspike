import 'package:intl/intl.dart';

class Task {
  int _id;
  String _name;
  String _desc;
  String _type;
  String _date;
  String _start;
  String _end;
  int _done;
  int _rating;

  Task.withId(
    this._id,
    this._name,
    this._desc,
    this._type,
    this._date,
    this._start,
    this._end,
    this._done,
    this._rating
  );

  Task(
    this._name,
    this._desc,
    this._type,
    this._date,
    this._start,
    this._end,
    this._done,
    this._rating
  );

  int get id =>_id;
  String get name => _name;
  String get desc => _desc;
  String get type => _type;
  String get date => _date;
  String get start => _start;
  String get end => _end;
  int get done => _done;
  int get rating => _rating;


  Map<String, dynamic> toMap(){
    var map = Map<String, dynamic>();
    map["name"] = _name;
    map["desc"] = _desc;
    map["type"] = _type;
    map["date"] = _date;
    map["start"] = _start;
    map["end"] = _end;
    map["done"] = _done;
    map["rating"] = _rating;
    if(_id != null){
      map["id"] = _id;
    }
    return map;
  }

  Task.fromObject(dynamic o){
    this._id = o["id"];
    this._name = o["name"];
    this._desc = o["desc"];
    this._type = o["type"];
    this._date = o["date"];
    this._start = o["start"];
    this._end = o["end"];
    this._done = o["done"];
    this._rating = o["rating"];
  }

  //Return DateTime of the task's start
  DateTime formStartDate() {
    String date = this.date;
    String time = this.start;
    return DateTime.parse(date + " " + time);
  }

  //Return DateTime of the task's end
  DateTime formEndDate() {
    String date = this.date;
    String time = this.end;
    return DateTime.parse(date + " " + time);
  }

  String formDuration() {
    String start = this.start;
    String end = this.end;
    return start + " - " + end;
  }

  //Sorts task by their time. Prerequisite: Tasks should not be coinciding.
  static void sortByTime(List<Task> tasks) {
    tasks.sort((a, b) => a.formStartDate().compareTo(b.formStartDate()));
  }

  //Only returns the tasks with a given completion status
  static List<Task> filterByDone(bool done, List<Task> tasks){
    List<Task> result = new List<Task>();
    if(done) {
      for(int i = 0; i < tasks.length; i++) {
        if (tasks[i].done == 1 || tasks[i].done == -1) {
          result.add(tasks[i]);
        }
      }
    } else {
      for(int i = 0; i < tasks.length; i++) {
        if (tasks[i].done == 0) {
          result.add(tasks[i]);
        }
      }
    }
    sortByTime(result);
    return result;
  }

  //Only returns the tasks with a given date.
  static List<Task> filterByDate(DateTime date, List<Task> tasks) {
    DateFormat format = new DateFormat("yyyy-MM-dd");
    List<Task> result = new List<Task>();

    String key = format.format(date);
    for(int i = 0; i < tasks.length; i++) {
      DateTime taskDate = tasks[i].formStartDate();
      String toCompare = format.format(taskDate);
      if(key.compareTo(toCompare) == 0) {
        result.add(tasks[i]);
      }
    }
    sortByTime(result);
    return result;
  }
}