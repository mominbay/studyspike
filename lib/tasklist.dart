import 'package:flutter/material.dart';
import 'package:spike_plan/db/database.dart';
import 'package:spike_plan/db/task.dart';

class TaskList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TaskListState();
  }
}

class TaskListState extends State<TaskList> {
  DBProvider dbProvider = new DBProvider();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: dbProvider.getAllTasks(),
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

  Widget taskList(List<Task> tasks){
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index){
        String _subtitle = tasks[index].date + " " + tasks[index].start + "-" + tasks[index].end;
        return Card(
          elevation: 2.0,
          child: ListTile(
            title: Text(tasks[index].name),
            subtitle: Text(_subtitle),
            onTap: (){print("Tapped");},
          ),
        );
      },
    );
  }
}