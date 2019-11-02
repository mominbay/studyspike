import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
show CalendarCarousel;
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:spike_plan/db/database.dart';
import 'package:spike_plan/db/task.dart';
import 'package:spike_plan/dayview.dart';

class TaskCalendar extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return TaskCalendarState();
  }
}

class TaskCalendarState extends State<TaskCalendar> {
  DBProvider dbProvider = new DBProvider();

  DateTime _currentDate = new DateTime.now();
  DateTime _currentDate2 = new DateTime.now();
  String _currentMonth = '';

  static Widget _eventIcon = new Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(1000)),
      border: Border.all(color: Colors.blue, width: 2.0),
    ),
    child: Icon(
      Icons.content_paste,
      color: Colors.amber,
    ),
  );

  Future<EventList<Event>> _setMarkedDates() async{
    List<Task> rawTasks = await dbProvider.getAllTasks();
    EventList<Event> _markedDates = new EventList<Event>();
    int count = rawTasks.length;
    for(int i = 0; i < count; i++){
      DateTime time = DateTime.parse(rawTasks[i].date);
      _markedDates.add(time, new Event(
        date: time,
        icon: _eventIcon
      ));
    }
    return _markedDates;
  }

  void _goToDay(DateTime date) async {
    bool result = await Navigator.push(context,
      MaterialPageRoute(builder: (builder) => DayView(date: date))
    );
  }

  Widget _calendarCarouselNoHeader(EventList<Event> events){
    return CalendarCarousel<Event>(
      onDayPressed: (DateTime date, List<Event> events) {
        this.setState(() => _currentDate2 = date);
        _goToDay(date);
      },
      selectedDayButtonColor: Colors.black,
      daysHaveCircularBorder: false,
      weekendTextStyle: TextStyle(
        color: Colors.red,
      ),
      thisMonthDayBorderColor: Colors.grey,
      weekFormat: false,
      markedDatesMap: events,
      markedDateIconMaxShown: 1,
      markedDateShowIcon: true,
      markedDateMoreShowTotal: false,
      markedDateIconBuilder: (event) {
        return event.icon;
      },
      height: 420.0,
      customGridViewPhysics: NeverScrollableScrollPhysics(),
      markedDateCustomTextStyle: TextStyle(
        fontSize: 18,
        color: Colors.blue,
      ),
      showHeader: false,
      selectedDateTime: _currentDate2,
      todayTextStyle: TextStyle(
        color: Colors.white,
      ),
      todayButtonColor: Colors.blueAccent[400],
      todayBorderColor: Colors.blueAccent[400],
      minSelectedDate: _currentDate.subtract(Duration(days: 360)),
      maxSelectedDate: _currentDate.add(Duration(days: 360)),
      prevDaysTextStyle: TextStyle(
        fontSize: 16,
        color: Colors.pinkAccent,
      ),
      inactiveDaysTextStyle: TextStyle(
        color: Colors.tealAccent,
        fontSize: 16,
      ),
      onCalendarChanged: (DateTime date) {
        this.setState(() => _currentMonth = DateFormat.yMMM().format(date));
      },
      onDayLongPressed: (DateTime date) {
        print('long pressed date $date');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _setMarkedDates(),
        builder: (context, snapshot) {
          if(snapshot.hasError){
            return Text("Data has error");
          } else if (!snapshot.hasData){
            return Text("Wait please...");
          } else {
            var data = snapshot.data;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(
                      top: 30.0,
                      bottom: 16.0,
                      left: 16.0,
                      right: 16.0,
                    ),
                    child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              _currentMonth,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24.0,
                              ),
                            ),
                          ),
                          FlatButton(
                            child: Text('PREV'),
                            onPressed: () {
                              setState(() {
                                _currentDate2 =
                                    _currentDate2.subtract(Duration(days: 30));
                                _currentMonth =
                                    DateFormat.yMMM().format(_currentDate2);
                              });
                            },
                          ),
                          FlatButton(
                            child: Text('NEXT'),
                            onPressed: () {
                              setState(() {
                                _currentDate2 =
                                    _currentDate2.add(Duration(days: 30));
                                _currentMonth =
                                    DateFormat.yMMM().format(_currentDate2);
                              });
                            },
                          ),
                        ]
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.0),
                    child: _calendarCarouselNoHeader(data),
                  ), //
                ],
              ),
            );
          }
        }
    );
  }
}