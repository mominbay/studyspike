import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:spike_plan/db/database.dart';
import 'package:spike_plan/db/task.dart';
import 'package:intl/intl.dart';

class AddEventScreen extends StatefulWidget {
  final DateTime date;
  final List<Task> todayTasks;
  final Task task;

  AddEventScreen({
    Key key,
    this.date,
    this.todayTasks,
    this.task,
  }) : super(key: key);

  @override
  State<AddEventScreen> createState() {
    return AddEventScreenState();
  }
}

class AddEventScreenState extends State<AddEventScreen> {
  DBProvider dbProvider = new DBProvider();

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
    if(widget.task != null) {
      eventName.text = widget.task.name;
      eventDesc.text = widget.task.desc;
      eventStart = widget.task.formStartDate();
      eventEnd = widget.task.formEndDate();
      startDisplay = widget.task.start;
      endDisplay = widget.task.end;
      eventType = widget.task.type;
      eventDone = widget.task.done;
      eventRating = widget.task.rating;
    }
    super.initState();
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

  //Submit is disabled until all inputs are verified
  bool _verify(){
    if(_formsAreComplete() && _timesAreValid() && _overlapping()){
      return true;
    }
    return false;
  }
  //fields must be complete
  bool _formsAreComplete(){
    if(eventName.text == "" || startDisplay == null ||  endDisplay == null || eventType == null){
      return false;
    }
    return true;
  }
  //tasks must be over 30 minutes
  bool _timesAreValid(){
    if(eventStart != null && eventEnd != null){
      if(eventEnd.difference(eventStart).inMinutes < 30){
        return false;
      }
      return true;
    }
    return true;
  }
  //activity cannot coincide with other tasks
  bool _overlapping(){
    List<Task> withoutDuple = new List<Task>.from(widget.todayTasks);
    if(widget.task != null) {
      int index = withoutDuple.indexWhere((task) => task.id == widget.task.id);
      withoutDuple.removeAt(index);
    }
    if(eventStart != null && eventEnd != null) {
      for (int i = 0; i < withoutDuple.length; i++) {
        DateTime otherTaskStart = withoutDuple[i].formStartDate();
        DateTime otherTaskEnd = withoutDuple[i].formEndDate();
        if (eventStart.compareTo(otherTaskStart) == 0 ||
            eventEnd.compareTo(otherTaskStart) == 0) {
          return false;
        }
        if (eventStart.compareTo(otherTaskStart) > 0 &&
            eventStart.compareTo(otherTaskEnd) < 0) {
          return false;
        }
        if (eventEnd.compareTo(otherTaskStart) > 0 &&
            eventEnd.compareTo(otherTaskEnd) < 0) {
          return false;
        }
        if (eventStart.compareTo(otherTaskStart) < 0 &&
            eventEnd.compareTo(otherTaskEnd) > 0) {
          return false;
        }
      }
    }
    return true;
  }

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
            textInputAction: TextInputAction.done,
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
                      eventStart = time.subtract(Duration(seconds: time.second));
                      startDisplay =  hour + ":" + minute;
                    });
                  },
                  currentTime: eventStart != null ? eventStart: widget.date.add(Duration(hours: 8)),
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
                      eventEnd = time.subtract(Duration(seconds: time.second));
                      endDisplay = hour + ":" + minute;
                    });
                  },
                  currentTime: eventEnd != null ? eventEnd:
                  eventStart != null ? eventStart.add(Duration(minutes: 30)):
                  widget.date.add(Duration(hours: 8)),
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
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
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
              widget.todayTasks != null ? errorMessage(_overlapping(), "Activities cannot coincide") : CircularProgressIndicator(),
              widget.todayTasks != null ? submitButton() : SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
    );
  }
}