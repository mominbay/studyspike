import 'package:flutter/material.dart';
import 'package:spike_plan/tasklist.dart';
import 'package:spike_plan/calendar.dart';
import 'package:extended_tabs/extended_tabs.dart';

class TaskView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TaskViewState();
  }
}

class ParentProvider extends InheritedWidget {
  final String title;
  final Widget child;

  ParentProvider({this.title, this.child});

  @override
  bool updateShouldNotify(ParentProvider oldWidget) {
    return true;
  }

  static ParentProvider of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(ParentProvider);
  }
}

class TaskViewState extends State<TaskView> with SingleTickerProviderStateMixin<TaskView>{

  TabController _controller;
  String myTitle = "My Parent Title";
  String updateChild2Title;

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

  void updateChild2(String text){
    print("I was called");
    setState(() {
      updateChild2Title = text;
    });
  }

  @override
  Widget build(BuildContext context) {
     return ParentProvider(
       title: updateChild2Title,
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
               child2Action: updateChild2,
             ),
             TaskCalendar(),
           ],
         ),
       ),
     );
  }
}