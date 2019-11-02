import 'package:flutter/material.dart';
import 'package:spike_plan/tasklist.dart';
import 'package:spike_plan/calendar.dart';

class TaskView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TaskViewState();
  }
}

class TaskViewState extends State<TaskView> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Study Planner"),
          bottom: TabBar(
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
        body: TabBarView(
          children: <Widget>[
            TaskList(),
            TaskCalendar(),
          ],
        ),
      ),
    );
  }
}