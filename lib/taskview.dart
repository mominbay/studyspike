import 'package:flutter/material.dart';
import 'package:spike_plan/tasklist.dart';
import 'package:spike_plan/calendar.dart';
import 'package:extended_tabs/extended_tabs.dart';
import 'package:spike_plan/db/database.dart';
import 'package:spike_plan/db/task.dart';

class TaskView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TaskViewState();
  }
}

class ParentProvider extends InheritedWidget {
  final List<Task> allTasks;
  final Widget child;

  ParentProvider({this.allTasks, this.child});

  @override
  bool updateShouldNotify(ParentProvider oldWidget) {
    return true;
  }

  static ParentProvider of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(ParentProvider);
  }
}

class TaskViewState extends State<TaskView> with SingleTickerProviderStateMixin<TaskView>{

  DBProvider dbProvider = new DBProvider();

  TabController _controller;
  List<Task> tasks;

  void update() async {
    Future<List<Task>> futureTasks = dbProvider.getAllTasks();
    futureTasks.then((data){
      List<Task> tasks = new List<Task>();
      for(int i = 0; i < data.length; i++) {
        tasks.add(data[i]);
      }
      setState(() {
        this.tasks = tasks;
      });
    });
  }

  @override
  void initState() {
    _controller = TabController(
      length: 2,
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(tasks == null) {
      update();
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return ParentProvider(
      allTasks: tasks,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Study Planner"),
          bottom: TabBar(
            controller: _controller,
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.list),
                text: "List",
              ),
              Tab(
                icon: Icon(Icons.calendar_today),
                text: "Calendar",
              )
            ],
          ),
        ),
        body: ExtendedTabBarView(
          controller: _controller,
          physics: AlwaysScrollableScrollPhysics(),
          cacheExtent: 1,
          children: <Widget>[
            TaskList(
              updateAction: update,
            ),
            TaskCalendar(
              updateAction: update,
            ),
          ],
        ),
      ),
    );
  }
}