import 'package:flutter/material.dart';
import 'package:spike_plan/db/database.dart';
import 'package:spike_plan/db/task.dart';
import 'package:spike_plan/addEvent.dart';

class TaskList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TaskListState();
  }
}

class TaskListState extends State<TaskList> {
  DBProvider dbProvider = new DBProvider();
  Future<List<Task>> tasks;

  @override
  void initState() {
    tasks = dbProvider.getAllTasks();
    super.initState();
  }

  void update(){
    setState(() {
      tasks = dbProvider.getAllTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: tasks,
      builder: (context, snapshot){
        if(snapshot.hasError){
          return Text("Data has error.");
        } else if (!snapshot.hasData){
          return Text("Wait please...");
        } else {
          return taskList(snapshot.data);
        }
      },
    );
  }

  void _goToEdit(Task task) async {
    DateTime date = DateTime.parse(task.date);
    bool result = await Navigator.push(context,
        MaterialPageRoute(builder: (builder) => AddEventScreen(
          task: task,
          date: date,
          //TODO pass other tasks to addEvent
        ))
    ).then((value){
      update();
    });
  }

  Widget taskList(List<Task> tasks){
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index){
        String _subtitle = tasks[index].date + " " + tasks[index].start + "-" + tasks[index].end + " " + tasks[index].id.toString();
        return Card(
          elevation: 2.0,
          child: ListTile(
            leading: Icon(Icons.face),
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