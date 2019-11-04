import 'package:flutter/material.dart';
import 'package:spike_plan/db/database.dart';
import 'package:spike_plan/db/task.dart';
import 'package:spike_plan/addEvent.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class TaskList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TaskListState();
  }
}

class TaskListState extends State<TaskList> {
  DBProvider dbProvider = new DBProvider();
  DateTime now = DateTime.now();
  Future<List<Task>> allTasks;

  @override
  void initState() {
    allTasks = dbProvider.getAllTasks();
    super.initState();
  }

  void update(){
    setState(() {
      allTasks = dbProvider.getAllTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "PENDING TODAY " + now.toString(),
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
        FutureBuilder(
          future: allTasks,
          builder: (context, snapshot){
            if(snapshot.hasError){
              return Text("Data has error.");
            } else if (!snapshot.hasData){
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return pendingList(Task.filterByDone(false, Task.filterByDate(now, snapshot.data)));
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "COMPLETED",
            style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold
            ),
          ),
        ),
        FutureBuilder(
          future: allTasks,
          builder: (context, snapshot){
            if(snapshot.hasError){
              return Text("Data has error.");
            } else if (!snapshot.hasData){
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return pendingList(Task.filterByDone(true, snapshot.data));
            }
          },
        ),
      ],
    );
  }

  void _goToEdit(Task task) async {
    DateTime date = DateTime.parse(task.date);
    await Navigator.push(context,
        MaterialPageRoute(builder: (builder) =>
            AddEventScreen(
              task: task,
              date: date,
              //TODO pass other tasks to addEvent
            ))
    ).then((value) {
      update();
    });
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
    int _rating = 0;
    bool res = false;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Rating " + task.name),
          content: RatingBar(
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
          actions: <Widget>[
            FlatButton(
              onPressed: (){
                print(_rating);
                Navigator.pop(context);
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
              },
              child: Text("RATE"),
            )
          ],
        );
      }
    );
    return res;
  }

  Widget pendingList(List<Task> tasks){
    return ListView.separated(
      separatorBuilder: (context, index){
        return Divider(height: 2.0);
      },
      itemCount: tasks.length,
      shrinkWrap: true,
      itemBuilder: (context, index){
        String _subtitle = tasks[index].date + " " + tasks[index].start + "-" + tasks[index].end + " " + tasks[index].done.toString();
        return Dismissible(
          key: Key(UniqueKey().toString()),
          background: markSkippedBackground(),
          secondaryBackground: markDoneBackground(),
          confirmDismiss: (direction) async {
            if(direction == DismissDirection.endToStart){
              final res = await rateTask(tasks[index]);
              print(res);
              return res;
            }
            dbProvider.update(new Task.withId(
                tasks[index].id,
                tasks[index].name,
                tasks[index].desc,
                tasks[index].type,
                tasks[index].date,
                tasks[index].start,
                tasks[index].end,
                -1,
                0
            ));
            return true;
          },
          onDismissed: (direction){update();},
          child: ListTile(
            leading: Icon(
              Icons.face,
              size: 44.0,
            ),
            title: Text(tasks[index].name),
            subtitle: Text(_subtitle),
            onTap: (){_goToEdit(tasks[index]);},
            trailing: IconButton(
              icon: Icon(Icons.close),
              onPressed: (){
                dbProvider.delete(tasks[index].id);
                update();
              },
            ),
          ),
        );
      },
    );
  }
}