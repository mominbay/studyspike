import 'package:flutter/material.dart';
import 'package:spike_plan/db/database.dart';
import 'package:spike_plan/db/task.dart';
import 'package:spike_plan/addEvent.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:spike_plan/taskview.dart';
import 'package:spike_plan/dayview.dart';
import 'package:spike_plan/tileHelpers.dart';

enum Choice {update, delete, reverse}

class TaskList extends StatefulWidget {
  final void Function() updateAction;
  const TaskList({Key key, this.updateAction}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TaskListState();
  }
}

class TaskListState extends State<TaskList> {
  DBProvider dbProvider = new DBProvider();
  DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final currentTasks = ParentProvider.of(context).allTasks;
    DateFormat format = new DateFormat("MM.dd.yyyy");
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(0, 0),
                blurRadius: 10.0,
                spreadRadius: 0.1
              ),
            ]
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Pending today: " + format.format(DateTime.now()),
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black38
              ),
            ),
          ),
        ),
        pendingList(Task.filterByDone(false, Task.filterByDate(now, currentTasks))),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(0, 1),
                blurRadius: 10.0,
                spreadRadius: 0.1
              ),
            ]
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Completed",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black38
              ),
            ),
          ),
        ),
        completedList(Task.filterByDone(true, Task.filterByDate(now, currentTasks)))
      ],
    );
  }

  void _goToEdit(Task task) async {
    DateTime date = DateTime.parse(task.date);
    await Navigator.push(context,
      MaterialPageRoute(builder: (builder) =>
        AddEventScreen(
          task: task,
          todayTasks: Task.filterByDate(date, ParentProvider
            .of(context)
            .allTasks),
        date: date,
      ))
    ).then((value) {
      widget.updateAction();
    });
  }

  void _goToDay() async {
    Navigator.push(context,
        MaterialPageRoute(builder: (builder) => DayView(
          updateAction: widget.updateAction,
          date: now.subtract(Duration(hours: 8)),
        ))
    ).then((value) => widget.updateAction);
  }

  Widget markSkippedBackground(){
    return Container(
      color: Colors.red,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 20.0,
          ),
          Icon(
            Icons.close,
            color: Colors.white,
          ),
          SizedBox(
            width: 10.0,
          ),
          Text(
            "Skipped",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0
            ),
          )
        ],
      ),
    );
  }

  Widget markDoneBackground(){
    return Container(
      color: Colors.green,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            "Completed",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16.0
            ),
          ),
          SizedBox(
            width: 10.0,
          ),
          Icon(
            Icons.check,
            color: Colors.white,
          ),
          SizedBox(
            width: 20.0,
          ),
        ],
      ),
    );
  }

  Future<bool> rateTask(Task task) async {
    int _rating = 3;
    bool res = false;
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
                res = true;
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
                ));
                Navigator.pop(context);
              },
              child: Text("RATE"),
            )
          ],
        );
      }
    );
    return res;
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
              dbProvider.delete(task.id).then((value)=>widget.updateAction());
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
                  )).then((value) => widget.updateAction());
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

  void _select(Choice choice, Task task){
    switch(choice){
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

  Widget pendingList(List<Task> tasks){
    if(tasks.length == 0){
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon( //TODO return a proper image
                Icons.insert_emoticon,
                size: 64.0,
              ),
              SizedBox(height: 8.0),
              Text(
                "No more tasks for today!",
                style: TextStyle(
                  fontSize: 16.0
                ),
              ),
              SizedBox(height: 8.0),
              RaisedButton(
                color: Colors.blue,
                textColor: Colors.white,
                padding: const EdgeInsets.all(0.0),
                onPressed: (){
                  _goToDay();
                },
                child: Text(
                  "ADD MORE?"
                ),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      separatorBuilder: (context, index){
        return Divider(height: 2.0);
      },
      itemCount: tasks.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index){
        return Dismissible(
          key: Key(UniqueKey().toString()),
          background: markSkippedBackground(),
          secondaryBackground: markDoneBackground(),
          onDismissed: (direction) async {
            Task toRemove = tasks[index];
            int removeIndex = tasks.indexWhere((task) => task.id == toRemove.id);
            tasks.removeAt(removeIndex);
            if(direction == DismissDirection.endToStart) {
              rateTask(toRemove).then((value) => widget.updateAction());
            }
            if(direction == DismissDirection.startToEnd) {
              dbProvider.update(new Task.withId(
                toRemove.id,
                toRemove.name,
                toRemove.desc,
                toRemove.type,
                toRemove.date,
                toRemove.start,
                toRemove.end,
                -1,
                0
              )).then((value) => widget.updateAction());
            }

          },
          child: ListTile(
            leading: Icon(
              Icons.face,
              size: 44.0,
            ),
            title: Text(tasks[index].name),
            subtitle: Text(tasks[index].formDuration()),
            trailing: PopupMenuButton(
              onSelected: (choice){_select(choice, tasks[index]);},
              itemBuilder: (context){
                return <PopupMenuEntry<Choice>>[
                  PopupMenuItem<Choice>(
                    child: Text("Update task"),
                    value: Choice.update,
                  ),
                  PopupMenuItem<Choice>(
                    child: Text("Delete task"),
                    value: Choice.delete,
                  )
                ];
              },
            )
          ),
        );
      },
    );
  }

  Widget completedList(List<Task> tasks){
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      shrinkWrap: true,
      separatorBuilder: (context, index){
        return Divider(height: 2.0);
      },
      itemBuilder: (context, index){
        String _subtitle = tasks[index].start + " - " + tasks[index].end;
        return Stack(
          children: <Widget>[
            ListTile(
              leading: dictateLeading(tasks[index]),
              title: Text(tasks[index].name),
              subtitle: Text(_subtitle),
              trailing: PopupMenuButton(
                onSelected: (choice){_select(choice, tasks[index]);},
                itemBuilder: (context){
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
              )
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: ratingBar(tasks[index], 64, 16.0)
              ),
            )
          ]
        );
      },
    );
  }
}