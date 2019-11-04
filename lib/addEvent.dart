import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:spike_plan/db/database.dart';
import 'package:spike_plan/db/task.dart';
import 'package:intl/intl.dart';

class AddEventScreen extends StatefulWidget {
  final DateTime date;
  final Task task;

  AddEventScreen({
    Key key,
    this.date,
    this.task,
  }) : super(key: key);

  @override
  State<AddEventScreen> createState() {
    return AddEventScreenState();
  }
}

class AddEventScreenState extends State<AddEventScreen> {
  DBProvider dbProvider = new DBProvider();

  Future<List<Task>> otherTasks;

  TextEditingController eventName = new TextEditingController();
  TextEditingController eventDesc = new TextEditingController();
  DateTime eventStart;
  DateTime eventEnd;
  String startDisplay = "Not set";
  String endDisplay = "Not set";
  String eventType;
  int eventDone = 0;
  int eventRating = 0;

  bool operating = false;

  //get other tasks. if called with another event, fill fields automatically.
  @override
  void initState() {
    otherTasks = dbProvider.getByDate(widget.date);
    super.initState();
    if(widget.task != null) {
      eventName.text = widget.task.name;
      eventDesc.text = widget.task.desc;
      startDisplay = widget.task.start;
      endDisplay = widget.task.end;
      eventType = widget.task.type;
      eventDone = widget.task.done;
      eventRating = widget.task.rating;
    }
  }


  //if called with another event, change header text
  String _headerText() {

    DateFormat format = new DateFormat("MM.dd.yyyy");
    String headerDate = format.format(widget.date);
    String result;
    if(widget.task != null) {
      result = widget.task.name + " (" + headerDate + ")";
    } else {
      result = "Creating new task for " + headerDate;
    }
    return result;
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    eventName.dispose();
    eventDesc.dispose();
    super.dispose();
  }

  final TextStyle labelStyle = new TextStyle(
      fontWeight: FontWeight.w500,
      color: Color.fromRGBO(64, 64, 64, 1.0),
      fontSize: 20.0
  );

  final TextStyle inputStyle = new TextStyle(
      fontSize: 20.0,
      color: Color.fromRGBO(64, 64, 64, 1),
      fontWeight: FontWeight.w400
  );

  bool _verify(){
    if(_formsAreComplete() && _timesAreValid()){
      return true;
    }
    return false;
  }

  bool _formsAreComplete(){
    if(eventName.text == "" || startDisplay == null ||  endDisplay == null || eventType == null){
      return false;
    }
    return true;
  }

  bool _timesAreValid(){
    if(eventStart != null && eventEnd != null){
      if(eventEnd.difference(eventStart).inMinutes < 30){
        return false;
      }
      return true;
    }
    return true;
  }

  /* bool _overlapping(){
    for(int i = 0; i < otherTasks.length; i++){
      DateTime otherTaskStart = DateTime.parse(widget.otherTasks[i].date + " " + widget.otherTasks[i].start);
      DateTime otherTaskEnd = DateTime.parse(widget.otherTasks[i].date + " " + widget.otherTasks[i].end);
      if(otherTaskStart.compareTo(eventStart) > 0 && otherTaskStart.compareTo(eventEnd) < 0){
        return false;
      } else if (otherTaskEnd.compareTo(eventStart) > 0 && otherTaskEnd.compareTo(eventEnd) < 0){
        return false;
      }
    }
    return true;
  } */

  void _post() async {
    setState(() {
      operating = true;
    });
    DateFormat format = new DateFormat("yyyy-MM-dd");
    String date = format.format(widget.date);
    //create new task if called without task
    if(widget.task == null) {
      Task newTask = new Task(
        eventName.text,
        eventDesc.text,
        eventType,
        date,
        startDisplay,
        endDisplay,
        eventDone,
        eventRating
      );
      dbProvider.insert(newTask).then((value){
        Navigator.pop(context, true);
        if (value != 0) {
          AlertDialog alertDialog = new AlertDialog(
            title: Text("Success"),
            content: Text("Created task: ${newTask.name}"),
          );
          showDialog(context: context, builder: (_) => alertDialog);
        }
      });

    } //update existing if called with task
    else if(widget.task != null) {
      Task newTask = new Task.withId(
        widget.task.id,
        eventName.text,
        eventDesc.text,
        eventType,
        date,
        startDisplay,
        endDisplay,
        eventDone,
        eventRating
      );
      dbProvider.update(newTask).then((value){
        Navigator.pop(context, true);
        if (value != 0) {
          AlertDialog alertDialog = new AlertDialog(
            title: Text("Success"),
            content: Text("Updated task: ${newTask.name}"),
          );
          showDialog(context: context, builder: (_) => alertDialog);
        }
      });
    }
  }


  Widget nameInput(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Task name",
          style: labelStyle
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            onChanged: (text){
              setState(() {
                //This is here to update the button
              });
            },
            controller: eventName,
            maxLength: 30,
            maxLines: 1,
            style: inputStyle,
            decoration: InputDecoration(
              hintText: "Name of current task",
              contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(200, 200, 200, 1),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(4.0))
              ),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(16, 137, 255, 1),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(4.0))
              ),
            )
          ),
        ),
      ],
    );
  }

  Widget descInput(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Task details",
          style: labelStyle,
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            onChanged: (text){
              setState(() {
              });
            },
            controller: eventDesc,
            maxLength: 150,
            maxLines: 4,
            style: inputStyle,
            decoration: InputDecoration(
              hintText: "Any details you wish to note",
              contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(200, 200, 200, 1),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(4.0))
              ),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(16, 137, 255, 1),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(4.0))
              ),
            )
          ),
        )
      ],
    );
  }

  Widget startInput(){
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          children: <Widget>[
            Container(
              width: 120.0,
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.access_time),
                  ),
                  Text(
                    "Starts at: ",
                    style: labelStyle,
                  ),
                ],
              ),
            ),
            FlatButton(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: (){
                DatePicker.showTimePicker(
                  context,
                  theme: DatePickerTheme(
                    containerHeight: 210.0
                  ),
                  showTitleActions: true,
                  onConfirm: (time){
                    String hour = time.hour.toString();
                    String minute = time.minute.toString();
                    if(hour.length == 1){
                      hour = "0" + hour;
                    }
                    if(minute.length == 1){
                      minute = "0" + minute;
                    }
                    setState(() {
                      eventStart = time;
                      startDisplay =  hour + ":" + minute;
                    });
                    int index = eventStart.toString().indexOf(" ");
                    print(eventStart.toString().substring(0, index));
                  },
                  currentTime: DateTime.now(),
                  locale: LocaleType.en
                );
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  startDisplay,
                  style: TextStyle(
                    color: Color.fromRGBO(164, 164, 164, 1),
                    fontSize: 20.0
                  ),
                ),
              ),
            )
          ],
        ),
      );
  }

  Widget endInput(){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: <Widget>[
          Container(
            width: 120.0,
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.access_time),
                ),
                Text(
                  "Ends at: ",
                  style: labelStyle,
                ),
              ],
            ),
          ),
          FlatButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onPressed: (){
              DatePicker.showTimePicker(
                  context,
                  theme: DatePickerTheme(
                      containerHeight: 210.0
                  ),
                  showTitleActions: true,
                  onConfirm: (time){
                    String hour = time.hour.toString();
                    String minute = time.minute.toString();
                    if(hour.length == 1){
                      hour = "0" + hour;
                    }
                    if(minute.length == 1){
                      minute = "0" + minute;
                    }
                    setState(() {
                      eventEnd = time;
                      endDisplay = hour + ":" + minute;
                    });
                    print(eventEnd);
                  },
                  currentTime: DateTime.now(),
                  locale: LocaleType.en
              );
            },
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                endDisplay,
                style: TextStyle(
                    color: Color.fromRGBO(164, 164, 164, 1),
                    fontSize: 20.0
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget typeInput(){
    return Row(
      children: <Widget>[
        Container(
          width: 120.0,
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(Icons.palette),
              ),
              Text(
                "Type: ",
                style: labelStyle,
              ),
            ],
          ),
        ),
        DropdownButton<String>(
          value: eventType,
          onChanged: (newVal){
            setState(() {
              eventType = newVal;
            });
          },
          items: <String>['Exercise', 'Study', 'Recreational', 'Hobby']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(
                    color: Color.fromRGBO(164, 164, 164, 1),
                    fontSize: 20.0
                ),
              ),
            );
          })
              .toList(),
        ),
      ],
    );
  }

  Widget errorMessage(bool condition, String message){
    return Container(
      height: 40.0,
      child: Center(
        child: Text(
          !condition ? message : "",
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.red
          ),
        ),
      ),
    );
  }

  Widget submitButton(){
    if(operating){
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Container(
      width: double.infinity,
      child: RaisedButton(
        color: Colors.blue,
        textColor: Colors.white,
        disabledColor: Colors.grey,
        elevation: 8.0,
        disabledElevation: 2.0,
        child: Text(
          "SAVE TASK"
        ),
        onPressed: _verify() ? (){_post();} : null,
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _headerText()
        ),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(81, 218, 207, 1),
      ),
      resizeToAvoidBottomPadding: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20.0),
            nameInput(),
            descInput(),
            startInput(),
            endInput(),
            typeInput(),
            errorMessage(_formsAreComplete(), "Please complete all fields"),
            errorMessage(_timesAreValid(), "An activity must be at least 30 minutes"),
            submitButton()
          ],
        ),
      ),
    );
  }
}