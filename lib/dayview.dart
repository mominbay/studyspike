import 'package:flutter/material.dart';
import 'package:spike_plan/db/task.dart';
import 'package:spike_plan/db/database.dart';
import 'package:intl/intl.dart';
import 'package:spike_plan/addEvent.dart';
import 'package:spike_plan/tileHelpers.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

enum Choice {update, delete, reverse}

class DayView extends StatefulWidget {
  final void Function() updateAction;
  final DateTime date;

  DayView({
    Key key,
    this.updateAction,
    this.date,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DayViewState();
  }
}

class DayViewState extends State<DayView> {
  DBProvider dbProvider = new DBProvider();
  List<Task> todayTasks;

  void update() async {
    Future<List<Task>> futureTasks = dbProvider.getByDate(widget.date);
    futureTasks.then((data) {
      List<Task> tasks = new List<Task>();
      for (int i = 0; i < data.length; i++) {
        tasks.add(data[i]);
      }
      setState(() {
        todayTasks = tasks;
      });
    });
  }

  void _select(Choice choice, Task task){
    switch(choice) {
      case Choice.delete:
        _confirmDelete(task);
        return;
      case Choice.update:
        _goToEdit(task);
        return;
      case Choice.reverse:
        _confirmReverse(task);
        return;
      default:
        return;
    }
  }

  void _rateTask(Task task) async {
    int _rating = 3;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Rating " + task.name),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("Rate your overall experience with " + task.name),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: RatingBar(
                  initialRating: 3,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  unratedColor: Colors.grey[200],
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    _rating = rating.toInt();
                  },
                ),
              ),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: (){
                dbProvider.update(new Task.withId(
                  task.id,
                  task.name,
                  task.desc,
                  task.type,
                  task.date,
                  task.start,
                  task.end,
                  1,
                  _rating
                )).then((value) {
                  widget.updateAction();
                  update();
                });
                Navigator.pop(context);
              },
              child: Text("RATE"),
            )
          ],
        );
      }
    );
  }

  void _confirmDelete(Task task) async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Deleting " + task.name),
            content: Text(
                "Are you sure you want to delete " + task.name + "?"
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: (){
                  dbProvider.delete(task.id)
                    .then((value) {
                      widget.updateAction();
                      update();
                    });
                  Navigator.pop(context);
                },
                child: Text("DELETE"),
              ),
              FlatButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text("CANCEL"),
              )
            ],
          );
        }
    );
  }

  void _confirmReverse(Task task) async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Retrieving " + task.name),
            content: Text(
                task.name + " will be marked as not completed."
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: (){
                  dbProvider.update(new Task.withId(
                      task.id,
                      task.name,
                      task.desc,
                      task.type,
                      task.date,
                      task.start,
                      task.end,
                      0,
                      0
                  )).then((value) {
                    widget.updateAction();
                    update();
                  });
                  Navigator.pop(context);
                },
                child: Text("CONFIRM"),
              ),
              FlatButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text("CANCEL"),
              )
            ],
          );
        }
    );
  }

  void _goToEdit(Task task) async {
    DateTime date = DateTime.parse(task.date);
    await Navigator.push(context,
      MaterialPageRoute(builder: (builder) =>
        AddEventScreen(
          task: task,
          todayTasks: todayTasks,
          date: date,
        ))
    ).then((value) {
      widget.updateAction();
      update();
    });
  }

  //Navigate to event add
  void _goToAdd() async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (builder) =>
            AddEventScreen(
              date: widget.date,
              todayTasks: todayTasks,
            ))
    ).then((value) {
      widget.updateAction();
      update();
    });
  }

  double stackHeight() {
    DateTime zero = todayTasks[0].formStartDate();
    DateTime end = todayTasks[todayTasks.length - 1].formEndDate();
    Duration total = end.difference(zero);
    double height = total.inMinutes.toDouble();
    return height;
  }

  //Generate dynamic list
  List<Widget> makeTaskCards() {
    List<Widget> result = new List<Widget>();
    DateTime zero = todayTasks[0].formStartDate();
    for (int i = 0; i < todayTasks.length; i++) {
      //dictate card height
      DateTime startTime = todayTasks[i].formStartDate();

      //dictate card offset
      Duration taskDelay = startTime.difference(zero);
      double taskOffset = taskDelay.inMinutes.toDouble() * 39 / 20;
      result.add(new Positioned(
        top: taskOffset,
        right: 0,
        width: MediaQuery
          .of(context)
          .size
          .width * 17 / 20,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(0, 0),
                blurRadius: 10.0,
                spreadRadius: 0.1
              ),
            ]
          ),
          child: taskCard(todayTasks[i])
        )
      ));
    }
    result.add(background());
    result = result.reversed.toList();
    return result;
  }

  Widget taskCard(Task task) {
    return ExpansionTile(
      leading: dictateLeading(task),
      title: Text(task.name),
      trailing: PopupMenuButton(
        onSelected: (choice) {
          _select(choice, task);
        },
        itemBuilder: (context) {
          return <PopupMenuEntry<Choice>>[
            PopupMenuItem<Choice>(
              child: Text("Update task"),
              value: Choice.update,
            ),
            PopupMenuItem<Choice>(
              child: Text("Delete task"),
              value: Choice.delete,
            ),
            PopupMenuItem<Choice>(
              child: Text("Mark task undone"),
              value: Choice.reverse,
            )
          ];
        },
      ),
      children: <Widget>[
        Divider(
          indent: 24.0,
          endIndent: 24.0,
          height: 1.0,
        ),
        SizedBox(height: 16.0),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 24.0),
            child: Text(
              "Duration: " + task.formDuration(),
              style: TextStyle(
                color: Colors.black45,
                fontSize: 16.0
              ),
            ),
          )
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 24.0),
            child: Text(
              "Type: " + task.type,
              style: TextStyle(
                color: Colors.black45,
                fontSize: 16.0
              ),
            ),
          )
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0, left: 24.0),
            child: Text(
              task.desc != "" ? task.desc : "No details annotated",
              style: TextStyle(
                color: Colors.black45,
                fontSize: 16.0
              ),
            ),
          )
        ),
        Divider(
          indent: 24.0,
          endIndent: 24.0,
          height: 1.0,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: taskCardEnd(task)
        )
      ],
    );
  }

  Widget taskCardEnd(Task task) {
    if(task.done != 0){
      return ratingBar(task, 0, 24.0);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Material(
          color: Colors.white,
          child: IconButton(
            tooltip: "Mark as complete",
            splashColor: Colors.black12,
            icon: Icon(
              Icons.check,
              color: Colors.black45,
              size: 32.0,
            ),
            onPressed: (){
              _rateTask(task);
            },
          ),
        ),
        SizedBox(width: 32.0,),
        Material(
          color: Colors.white,
          child: IconButton(
            tooltip: "Mark as skipped",
            splashColor: Colors.black12,
            icon: Icon(
              Icons.close,
              color: Colors.black45,
              size: 32.0,
            ),
            onPressed: (){
              dbProvider.update(new Task.withId(
                task.id,
                task.name,
                task.desc,
                task.type,
                task.date,
                task.start,
                task.end,
                -1,
                0
              )).then((value) {
                widget.updateAction();
                update();
              });
            },
          ),
        )
      ],
    );
  }

  Widget dayStack() {
    if (todayTasks.length == 0) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 220.0,),
            Text(
              "You don't have any tasks for today",
              style: TextStyle(
                fontSize: 22.0,
                color: Colors.black54
              ),
            ),
            SizedBox(height: 20.0,),
            Text(
              "Add some tasks with the buttons below",
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.cyan
              ),
            )
          ],
        ),
      );
    }
    return Container(
      child: Stack(
       children: makeTaskCards()
      ),
    );
  }

  Widget background() {
    DateTime rawZero = todayTasks[0].formStartDate();
    DateTime rawEnd = todayTasks[todayTasks.length - 1].formEndDate();
    List<String> times = new List<String>();
    int rawZeroDiff = (60 - rawZero.minute) % 30;

    bool first = true;
    while(rawZero.isBefore(rawEnd) || times.length < 12){
      String hr = rawZero.hour.toString();
      if(hr.length == 1){
        hr = "0" + hr;
      }
      String mn = rawZero.minute.toString();
      if(mn.length == 1) {
        mn = "0" + mn;
      }
      times.add(hr + ":" + mn);
      if(first) {
        rawZero = rawZero.add(Duration(minutes: rawZeroDiff));
        first = false;
        continue;
      }
      rawZero = rawZero.add(Duration(minutes: 30));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: times.length + 1,
      itemBuilder: (context, index){
        if(index == 0){
          return Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(
                color: Colors.black12,
                width: 1.0
              ))
            ),
            height: rawZeroDiff.toDouble() * 39 / 20,
          );
        }
        if(index == times.length) {
          return SizedBox(height: 200.0);
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(
                color: Colors.black26,
                width: 1.0
              ))
            ),
            height: 30 * 39 / 20,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                times[index],
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black38
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (todayTasks == null) {
      update();
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    DateFormat viewFormat = new DateFormat("MM.dd.yyyy");
    String dateString = viewFormat.format(widget.date);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Schedule for " + dateString,
        )
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: dayStack()
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FloatingActionButton(
            heroTag: null,
            tooltip: "Add manually",
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              _goToAdd();
            },
          ),
          SizedBox(height: 16.0),
          FloatingActionButton(
            heroTag: null,
            backgroundColor: Colors.greenAccent,
            tooltip: "AISSP suggestion",
            child: Icon(
              Icons.live_help,
              color: Colors.white,
            ),
            onPressed: () {
              print("IMPLEMENT AI");
            },
          ),
        ],
      ),
    );
  }
}