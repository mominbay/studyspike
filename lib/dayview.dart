import 'package:flutter/material.dart';
import 'package:spike_plan/db/task.dart';
import 'package:spike_plan/db/database.dart';
import 'package:intl/intl.dart';
import 'package:spike_plan/addEvent.dart';

class DayView extends StatefulWidget {
  final DateTime date;

  DayView({Key key, this.date}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DayViewState();
  }
}

class DayViewState extends State<DayView> {
  DBProvider dbProvider = new DBProvider();
  Future<List<Task>> tasks;

  //Get tasks of the day
  @override
  void initState() {
    tasks = dbProvider.getByDate(widget.date);
    super.initState();
  }

  void update(){
    setState(() {
      tasks = dbProvider.getByDate(widget.date);
    });
  }

  //Navigate to event add
  void _goToAdd() async {
    await Navigator.push(context,
      MaterialPageRoute(builder: (builder) => AddEventScreen(
        date: widget.date,
      ))
    ).then((value) => update());
  }
  //Generate dynamic list
  List<Widget> makeTaskCards(List<Task> tasks) {
    List<Widget> result = new List<Widget>();
    for(int i = 0; i < tasks.length; i++){
      //dictate card height
      String start = tasks[i].date + " " + tasks[i].start;
      DateTime startTime = DateTime.parse(start);
      String end = tasks[i].date + " " + tasks[i].end;
      DateTime endTime = DateTime.parse(end);
      Duration taskDuration = endTime.difference(startTime);
      double taskHeight = taskDuration.inMinutes.toDouble();

      //dictate card offset
      DateTime zero = DateTime.parse(tasks[i].date);
      Duration taskDelay = startTime.difference(zero);
      double taskOffset = taskDelay.inMinutes.toDouble();
      result.add(new Positioned(
        top: taskOffset,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: taskHeight,
          color: Colors.pinkAccent,
          child: Center(
            child: Text(tasks[i].name),
          ),
        )
      ));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    DateFormat viewFormat = new DateFormat("MM.dd.yyyy");
    String dateString = viewFormat.format(widget.date);
    return Scaffold(
      body: NestedScrollView(
        //TODO incorporate double scroll
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    "Schedule for " + dateString,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    )
                  ),
                  background: Image.network(
                    "https://images.pexels.com/photos/396547/pexels-photo-396547.jpeg?auto=compress&cs=tinysrgb&h=350",
                    fit: BoxFit.cover,
                  )),
            ),
          ];
        },
        body: FutureBuilder(
          future: tasks,
          builder: (context, snapshot){
            if(snapshot.hasError){
              return Text("Data has error");
            } else if (!snapshot.hasData) {
              return Text("Wait please...");
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  height: 2000,
                  color: Colors.yellow,
                  child: Stack(
                    children: makeTaskCards(snapshot.data),
                  ),
                ),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: (){_goToAdd();},
      ),
    );
  }
}